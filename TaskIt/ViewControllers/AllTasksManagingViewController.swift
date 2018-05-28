import UIKit
import RxSwift
import RealmSwift

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
        tableView.register(TasksTableViewSectionHeader.self,
                           forHeaderFooterViewReuseIdentifier: "Header")
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedRowHeight = 0
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "TaskUpdatingSegue":
            let vc = segue.destination as! TaskUpdateViewController
            guard let indexPath = tableView.indexPathForSelectedRow,
                let task = viewModel.task(for: indexPath)
                else { fatalError() }
            viewModel.watchForUpdates(taskPath: indexPath)
            vc.mode = .update(task)
        default: break
        }
    }

    func bindUiToViewModel() {
        viewModel.tableViewUpdates
            .observeOn(MainScheduler.asyncInstance)
            .subscribeNext { [weak self] updates in
                self?.tableView.performBatchUpdates(with: updates, completion: nil)
        }.disposed(by: disposeBag)
    }

    @IBAction func addTaskButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        let vc = TaskUpdateViewController.fromStoryboard(withMode: .create)
        vc.onComplete = { [weak self] task in
            self?.viewModel.insert(newTask: task)
        }
        present(vc, animated: true, completion: { sender.isEnabled = true })
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerType: TasksTableViewSectionHeader.State

        switch section {
        case 0: headerType = .currentSprint(viewModel.weekNumber)
        case 1: headerType = .remaining
        case 2: headerType = .finished
        default: return nil
        }

        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as? TasksTableViewSectionHeader
            else { return nil }
        view.state = headerType

        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
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
        private var tokensStore = [NotificationToken]()

        var weekNumber: Int { return project.sprints.count }

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

        // MARK: Internal methods

        func numberOfRowsInSection(section: Int) -> Int {
            return dataSource(for: section)?.count ?? 0
        }

        func numberOfSections() -> Int {
            return 3
        }

        func view(_ state: ViewControllerLifeCycle) {
            viewState.value = state

            switch state {
            case .didAppear:
                invalidateTokens()
                purgeUpdates()
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

        func watchForUpdates(taskPath: IndexPath) {
            guard let task = task(for: taskPath) else { return }
            let oldState = task.state
            let token = task.observe { [weak self] change in
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }
                    switch change {
                    case .change(let changes):
                        let stateChanges = changes.filter({$0.name == "state"})
                        let reloadCell: () -> Void = {
                            let reload = TableViewUpdates(section: taskPath.section,
                                                          deletions: [],
                                                          inserts: [],
                                                          reloads: [taskPath.row])
                            strongSelf.updateTableView(with: [reload])
                        }

                        guard !stateChanges.isEmpty && taskPath.section != 0 else {
                            reloadCell()
                            return
                        }

                        let change = stateChanges.first
                        guard let newValue = change?.newValue as? Int,
                            let newState = TaskState(rawValue: newValue)
                            else {
                                reloadCell()
                                return
                        }

                        if oldState == newState {
                            reloadCell()
                        } else if newState == .finished || oldState == .finished {
                            let newSection = newState == .finished ? 2 : 1
                            let newRow = strongSelf.dataSource(for: newSection)!.count

                            strongSelf.moveTask(from: taskPath,
                                                to: IndexPath(row: newRow, section: newSection))

                            let deletion = TableViewUpdates(section: taskPath.section,
                                                            deletions: [taskPath.row],
                                                            inserts: [],
                                                            reloads: [])

                            let insertion = TableViewUpdates(section: newSection,
                                                             deletions: [],
                                                             inserts: [newRow],
                                                             reloads: [])

                            strongSelf.updateTableView(with: [deletion, insertion])
                        } else {
                            reloadCell()
                        }

                    default: break
                    }
                }
            }
            tokensStore.append(token)
        }

        // MARK: Private methods

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
            let acceptableStates = validStates(forSection: to)

            guard !acceptableStates.contains(task.state) else { return }

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

        private func validStates(forSection section: Int) -> [TaskState] {
            switch section {
            case 0: return [.unstarted, .inProgress, .finished]
            case 1: return [.unstarted, .inProgress]
            case 2: return [.finished]
            default: fatalError("invalid section")
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

        private func invalidateTokens() {
            for token in tokensStore { token.invalidate() }
            tokensStore = []
        }
    }
}
