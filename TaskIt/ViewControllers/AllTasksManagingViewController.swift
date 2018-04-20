import UIKit
import RxSwift

class AllTasksManagingViewController: UIViewController {
    var viewModel: ViewModel!
    private let disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!

    lazy var editButton: UIBarButtonItem = {
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        return edit
    }()

    lazy var doneButton: UIBarButtonItem = {
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        return done
    }()

    static func fromStoryBoard(project: Project) -> AllTasksManagingViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AllTasksViewController") as! AllTasksManagingViewController
        vc.viewModel = ViewModel(project: project)

        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedSectionHeaderHeight = 50
        bindUiToViewModel()
        navigationItem.title = "All Tasks"
        viewModel.view(.didLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isEditing = false
        navigationItem.rightBarButtonItem = editButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.view(.didAppear)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.view(.willDisappear)
        navigationItem.rightBarButtonItem = nil
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.view(.didDisappear)
    }

    func bindUiToViewModel() {
        viewModel.tableViewUpdates
            .observeOn(MainScheduler.asyncInstance)
            .subscribeNext { [weak self] updates in
                self?.tableView.performBatchUpdates(with: updates, completion: nil)
        }.disposed(by: disposeBag)
    }

    @IBAction func addTaskButtonTapped(_ sender: UIButton) {
        let vc = TaskUpdateViewController.fromStoryboard(withMode: .create)
        vc.onComplete = { [weak self] task in
            self?.viewModel.insert(newTask: task)
        }
    }

    @objc private func editButtonTapped() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItem = doneButton

        tableView.isEditing = true
    }

    @objc private func doneButtonTapped() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItem = editButton

        tableView.isEditing = false
    }

}

extension AllTasksManagingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as! TaskTableViewCell
        if let task = viewModel.task(for: indexPath) {
            cell.viewModel = TaskTableViewCellViewModel(task: task)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            self?.viewModel.removeTask(index: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        return [delete]
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let headerType: HeaderType

        switch section {
        case 0: headerType = .sprint(viewModel.weekNumber)
        case 1: headerType = .backlog
        case 2: headerType = .finished
        default: return nil
        }

        return headerType.description
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        viewModel.moveTask(from: sourceIndexPath, to: destinationIndexPath)
        viewModel.reload(destinationIndexPath)
    }
}

extension AllTasksManagingViewController {
    class ViewModel {
        private let project: Project
        private let realm: DatabaseProxy
        private let sprint: Sprint
        private let tableViewUpdatesSubject = PublishSubject<[TableViewUpdates]>()
        private let viewState = Variable<ViewControllerLifeCycle?>(nil)
        private var delayedUpdates = [TableViewUpdates]()

        var weekNumber: Int { return project.sprints.count + 1 }

        var currentTasks = [Task]()
        var backloggedTasks = [Task]()
        var finishedTasks = [Task]()

        var tableViewUpdates: Observable<[TableViewUpdates]> {
            return tableViewUpdatesSubject.asObservable()
        }

        init(project: Project, realm: DatabaseProxy = RealmProxy(instance: .main)) {
            guard let lastSprint = project.sprints.last
                else { fatalError("Cannot arrive here without at least one sprint") }
            self.project = project
            self.realm = realm
            self.sprint = lastSprint

            setUpTaskLists()
        }

        func numberOfRowsInSection(section: Int) -> Int {
            return dataSource(for: section)?.count ?? 0
        }

        func numberOfSections() -> Int {
            return 3
        }

        func view(_ state: ViewControllerLifeCycle) {
            viewState.value = state

            switch state {
            case .didAppear: purgeUpdates()
            default: break
            }
        }

        func didUpdateTask(_ task: Task) {
            realm.write(task)
        }

        func insert(newTask: Task) {
            let section: Int
            let row: Int
            let position: Int
            if newTask.state != .finished {
                position = backloggedTasks.count
                section = 1
                row = backloggedTasks.count
                backloggedTasks.append(newTask)

            } else {
                position = backloggedTasks.count + finishedTasks.count
                section = 2
                row = finishedTasks.count
                finishedTasks.append(newTask)
            }

            realm.write {
                project.tasks.insert(newTask, at: position)
            }

            let update = TableViewUpdates(section: section,
                                          deletions: [],
                                          inserts: [row],
                                          reloads: [])
            updateTableView(with: [update])
        }

        func removeTask(index: IndexPath) {
            if let task = task(for: index) {
                removeFromDataSource(at: index)

                realm.delete(task)
            }
        }

        func reload(_ path: IndexPath) {
            let reload = TableViewUpdates(section: path.section,
                                          deletions: [],
                                          inserts: [],
                                          reloads: [path.row])
            updateTableView(with: [reload])
        }

        func moveTask(from original: IndexPath, to destination: IndexPath) {
            if let task = task(for: original) {
                updateTask(task: task, movedFrom: original.section, to: destination.section)
                moveProjectTask(from: original, to: destination)
                moveSprintTask(task: task, from: original, to: destination)
                removeFromDataSource(at: original)
                addToDataSource(task: task, path: destination)
            }
        }

        func task(for path: IndexPath) -> Task? {
            return dataSource(for: path.section)?[path.row]
        }

        private func setUpTaskLists() {
            currentTasks = Array(sprint.tasks)
            let currentSet = Set(currentTasks)
            let nonSprintTasks = Array(project.tasks).filter { !currentSet.contains($0) }

            backloggedTasks = nonSprintTasks.filter { $0.state != .finished }
            finishedTasks = nonSprintTasks.filter { $0.state == .finished }
        }

        private func dataSource(for section: Int) -> [Task]? {
            switch section {
            case 0: return currentTasks
            case 1: return backloggedTasks
            case 2: return finishedTasks
            default: return nil
            }
        }

        private func removeFromDataSource(at path: IndexPath) {
            switch path.section {
            case 0: currentTasks.remove(at: path.row)
            case 1: backloggedTasks.remove(at: path.row)
            case 2: finishedTasks.remove(at: path.row)
            default: break
            }
        }

        private func addToDataSource(task: Task, path: IndexPath) {
            switch path.section {
            case 0: currentTasks.insert(task, at: path.row)
            case 1: backloggedTasks.insert(task, at: path.row)
            case 2: finishedTasks.insert(task, at: path.row)
            default: break
            }
        }

        private func updateTask(task: Task, movedFrom from: Int, to: Int) {
            guard from != to else { return }
            guard !Set([to, from]).isSuperset(of: [0,1]) else { return }

            var state: TaskState!
            switch to {
            case 0, 1: state = .unstarted
            case 2: state = .finished
            default: return
            }

            realm.write {
                task.state = state
            }
        }

        private func moveProjectTask(from: IndexPath, to: IndexPath) {
            func offsetFor(section: Int) -> Int {
                switch section {
                case 0: return 0
                case 1: return currentTasks.count
                case 2: return currentTasks.count + backloggedTasks.count
                default: return 0
                }
            }

            let fromIndex = offsetFor(section: from.section) + from.row
            let toIndex   = offsetFor(section: to.section) + to.row - (to.section > from.section ? 1 : 0)
            realm.write {
                project.tasks.move(from: fromIndex, to: toIndex)
            }
        }

        private func moveSprintTask(task: Task, from: IndexPath, to: IndexPath) {
            switch (from.section, to.section) {
            case (0, 0):
                realm.write {
                    sprint.tasks.move(from: from.row, to: to.row)
                }
            case (_, 0):
                realm.write {
                    sprint.tasks.insert(task, at: to.row)
                }
            case (0, _):
                realm.write {
                    sprint.tasks.remove(at: from.row)
                }
            default: return
            }
        }

        private func updateTableView(with updates: [TableViewUpdates]) {
            guard viewState.value == .didAppear else {
                delayedUpdates.append(contentsOf: updates)
                return
            }

            tableViewUpdatesSubject.onNext(updates)
        }

        private func purgeUpdates() {
            tableViewUpdatesSubject.onNext(delayedUpdates)
            delayedUpdates = []
        }
    }
}
