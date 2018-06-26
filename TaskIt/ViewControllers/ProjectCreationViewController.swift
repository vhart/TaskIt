import UIKit
import RealmSwift
import RxSwift

class ProjectCreationViewController: UIViewController {

    class func fromStoryboard() -> ProjectCreationViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProjectCreationViewController") as! ProjectCreationViewController
        vc.viewModel = ViewModel()
        return vc
    }

    var viewModel: ViewModel!
    let disposeBag = DisposeBag()

    @IBOutlet weak var projectNameTextField: UITextField!

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var finishButton: UIButton!

    lazy var editBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped(_:)))
        return button
    }()

    lazy var noTasksView: NoTasksView = {
        let view = NoTasksView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.descriptionLabel.text = "Tap 'Add Task' below to add a task!"

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel()
        tableView.delegate = self
        tableView.dataSource = self
        projectNameTextField.delegate = self
        layoutNoTasksView()

        bindUiToViewModel()
        viewModel.view(.didLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        viewModel.view(.willAppear)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.view(.didAppear)
        if viewModel.shouldBeginEditingTitle {
            projectNameTextField.becomeFirstResponder()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.view(.didDisappear)
    }

    @IBAction func finishButtonTapped(_ sender: Any) {
        viewModel.finalize()
        navigationController?.popViewController(animated: true)
    }

    @objc func editButtonTapped(_ sender: Any) {
        viewModel.editButtonTapped()
    }

    func bindUiToViewModel() {
        viewModel.insert
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] path in
            self?.tableView.insertRows(at: [path], with: .automatic)
        }.disposed(by: disposeBag)

        viewModel.reload
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] path in
                self?.tableView.reloadRows(at: [path], with: .automatic)
        }.disposed(by: disposeBag)

        viewModel.projectName
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] name in
                if let name = name {
                    self?.navigationItem.title = name
                } else {
                    self?.navigationItem.title = "Create Project"
                }
        }.disposed(by: disposeBag)

        viewModel.hasTasks
            .distinctUntilChanged()
            .observeOn(MainScheduler.asyncInstance)
            .subscribeNext { [weak self] hasTasks in
                if hasTasks {
                    UIView.animate(withDuration: 0.3, animations: {
                        self?.addEditButton()
                        self?.noTasksView.alpha = 0
                    })
                } else {
                    self?.removeEditButton()
                    UIView.animate(withDuration: 0.3, animations: {
                        self?.noTasksView.alpha = 1
                    })
                }
        }.disposed(by: disposeBag)

        viewModel.isEditing
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] isEditing in
                self?.tableView.isEditing = isEditing
                self?.editBarButton.title = isEditing ? "Done" : "Edit"
        }.disposed(by: disposeBag)

        viewModel.finishEnabled
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] isEnabled in
                self?.finishButton.backgroundColor = isEnabled ? .ocean : .fog
                self?.finishButton.isEnabled = isEnabled
        }.disposed(by: disposeBag)
    }

    func addEditButton() {
        navigationItem.rightBarButtonItem = editBarButton
    }

    func removeEditButton() {
        navigationItem.rightBarButtonItem = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        switch id {
        case "TaskCreationSegue":
            let vc = segue.destination as! TaskUpdateViewController
            vc.mode = .create
            vc.onComplete = { [weak self] task in
                self?.viewModel.updateWith(task: task)
            }
        case "TaskEditingSegue":
            let vc = segue.destination as! TaskUpdateViewController
            guard let index = tableView.indexPathForSelectedRow?.row
                else { fatalError("invalid transition to editing") }
            vc.mode = .update(viewModel.tasks[index])
            vc.onComplete = { [weak self] task in
                self?.viewModel.updateWith(task: task)
            }
        default: break
        }
    }

    private func layoutNoTasksView() {
        view.addSubview(noTasksView)

        NSLayoutConstraint.activate([
            noTasksView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            noTasksView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            noTasksView.topAnchor.constraint(equalTo: tableView.topAnchor),
            noTasksView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
            ])
    }
}

extension ProjectCreationViewController: UITableViewDelegate,
UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell",
                                                 for: indexPath) as! TaskTableViewCell
        cell.viewModel = TaskTableViewCellViewModel(task: viewModel.tasks[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            self?.viewModel.removeTask(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        return [delete]
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = viewModel.tasks[sourceIndexPath.row]
        viewModel.tasks.remove(at: sourceIndexPath.row)
        viewModel.tasks.insert(movedObject, at: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

extension ProjectCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.updateProjectName(textField.text)
        textField.layer.borderColor = UIColor.fog.cgColor
        textField.layer.borderWidth = 1
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.ocean.cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 5
    }
}

protocol ProjectCreationViewModel {}
extension ProjectCreationViewController {
    struct ProjectValidity: OptionSet {
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }

        static let validTitle = ProjectValidity(rawValue: 1 << 0)
        static let validTaskCount = ProjectValidity(rawValue: 1 << 1)
        static let fullyValid: ProjectValidity = [.validTitle, .validTaskCount]
    }

    class ViewModel: ProjectCreationViewModel {
        private var nameSubject = Variable<String?>(nil)
        private let insertSubject = PublishSubject<IndexPath>()
        private let reloadSubject = PublishSubject<IndexPath>()
        private let editingSubject = Variable<Bool>(false)
        private let showEditingSubject = Variable<Bool>(false)
        private let finishEnabledSubject = Variable<Bool>(false)
        private(set) var shouldBeginEditingTitle = false
        private var shouldDelayUIUpdates = false {
            didSet {
                if !shouldDelayUIUpdates {
                    flushUpdates()
                }
            }
        }

        private let hasTasksSubject = Variable<Bool>(false)

        private var delayedUIUpdates = [() -> Void]()
        private var validity: ProjectValidity = [] {
            didSet {
                finishEnabledSubject.value = validity.contains(.fullyValid)
            }
        }

        var insert: Observable<IndexPath> { return insertSubject.asObservable() }
        var reload: Observable<IndexPath> { return reloadSubject.asObservable() }
        var projectName: Observable<String?> { return nameSubject.asObservable() }
        var isEditing: Observable<Bool> { return editingSubject.asObservable() }
        var showEditingOption: Observable<Bool> {
            return showEditingSubject.asObservable()
        }
        var finishEnabled: Observable<Bool> {
            return finishEnabledSubject.asObservable()
        }

        var hasTasks: Observable<Bool> { return hasTasksSubject.asObservable() }

        let numberOfSections = 1
        var tasks = [Task]() {
            didSet {
                showEditingSubject.value = !tasks.isEmpty
                if tasks.isEmpty {
                    validity.remove(.validTaskCount)
                } else {
                    validity.insert(.validTaskCount)
                }

                hasTasksSubject.value = !tasks.isEmpty
            }
        }

        init() {
            let t1 = Task()
            t1.estimatedDuration = 90
            t1.title = "T1"
            t1.taskDetails = ""

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                t1.title = "T1 updated"
                t1.taskDetails = "Should update this label"
                self.updateWith(task: t1)
            }
        }

        func view(_ state: ViewControllerLifeCycle) {
            switch state {
            case .didLoad:
                shouldBeginEditingTitle = true
            case .didDisappear:
                shouldBeginEditingTitle = false
                shouldDelayUIUpdates = true
            case .didAppear:
                shouldDelayUIUpdates = false
            default: break
            }
        }

        func updateWith(task: Task) {
            if tasks.contains(task) {
                let index = tasks.index(of: task)!
                let path = IndexPath(row: index, section: 0)
                reload(indexPath: path)
            } else {
                tasks.append(task)
                insert(indexPath: IndexPath(row: tasks.count - 1, section: 0))
            }
        }

        func removeTask(index: Int) {
            tasks.remove(at: index)
        }

        func updateProjectName(_ name: String?) {
            let nonWhiteSpace = CharacterSet.whitespacesAndNewlines.inverted
            if name?.rangeOfCharacter(from: nonWhiteSpace) == nil {
                nameSubject.value = nil
                validity.remove(.validTitle)
                return
            } else {
                nameSubject.value = name
                validity.insert(.validTitle)
            }
        }

        func editButtonTapped() {
            editingSubject.value = !editingSubject.value
        }

        func finalize() {
            let project = makeProject()
            let realm = RealmFactory.get(.main)
            try! realm.write {
                realm.add(project)
            }
        }

        private func makeProject() -> Project {
            guard validity.contains(.fullyValid)
                else { fatalError("Validation has failed") }
            let project = Project()
            project.tasks.append(objectsIn: tasks)
            project.name = nameSubject.value!
            return project
        }

        private func reload(indexPath: IndexPath) {
            guard !shouldDelayUIUpdates else {
                let update: () -> Void = { [weak self] in
                    self?.reloadSubject.onNext(indexPath)
                }
                delayedUIUpdates.append(update)
                return
            }

            reloadSubject.onNext(indexPath)
        }

        private func insert(indexPath: IndexPath) {
            guard !shouldDelayUIUpdates else {
                let update: () -> Void = { [weak self] in
                    self?.insertSubject.onNext(indexPath)
                }
                delayedUIUpdates.append(update)
                return
            }

            insertSubject.onNext(indexPath)
        }

        private func flushUpdates() {
            for update in delayedUIUpdates {
                update()
            }
            delayedUIUpdates = []
        }
    }
}
