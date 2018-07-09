import RxSwift
import RealmSwift
import UIKit

class DashboardDetailViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var graphContainer: UIView!
    @IBOutlet weak var projectProgressViewContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var tasksLabel: UILabel!

    var viewModel = ViewModel()
    let disposeBag = DisposeBag()
    var onFinishRequested: ((Project) -> Void)?

    lazy var graphView: SprintGraphView = {
        let view = SprintGraphView(unstarted:  viewModel.currentUnstarted,
                                   inProgress: viewModel.currentInProgress,
                                   finished:   viewModel.currentFinished)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    lazy var progressView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.gradientLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        view.gradientLayer?.colors = [UIColor.indigo.cgColor, UIColor.tomato.cgColor]//CGColor.purples 
        return view
    }()

    lazy var sprintSetUpView: SprintSetUpIndicatorView = {
        let view = SprintSetUpIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var allTasksButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        let image = #imageLiteral(resourceName: "forward_icon").withRenderingMode(.alwaysTemplate)
        b.setBackgroundImage(image, for: .normal)
        b.contentMode = .scaleAspectFit
        b.tintColor = .ocean
        b.addTarget(self, action: #selector(showAllTasks(sender:)), for: .touchUpInside)

        return b
    }()

    class func fromStoryboard() -> DashboardDetailViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashDetailViewController")
        return vc as! DashboardDetailViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        layoutGraph()
        layoutProgressBar()
        layoutSprintSetUpView()
        layoutAllTasksButton()
        bindUiToViewModel()

        navigationItem.title = "Dashboard"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.view(.didAppear)
    }

    private func bindUiToViewModel() {
        viewModel.overlayOptions
            .distinctUntilChanged()
            .observeOn(MainScheduler.asyncInstance)
            .subscribeNext { [weak self] overlayOptions in
                self?.showOverlay(options: overlayOptions)
        }.disposed(by: disposeBag)

        viewModel.graphUpdates
            .filter({ $0 != nil })
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] update in
                guard let update = update else { return }
                self?.graphView.updateTaskCounts(unstarted: update.unstartedCount,
                                                 inProgress: update.inProgressCount,
                                                 finished: update.finishedCount)
        }.disposed(by: disposeBag)

        viewModel.tableViewUpdates
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] update in
                switch update {
                case .reloadTable:
                    self?.tableView.reloadData()
                case .cellUpdates(let cellUpdates):
                    self?.tableView.performBatchUpdates(with: cellUpdates,
                                                        completion: nil)
                }
        }.disposed(by: disposeBag)

        viewModel.weeksLabelText
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] labelText in
                self?.weekLabel.text = labelText
        }.disposed(by: disposeBag)

        viewModel.showAllTasksButton
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] isVisibile in
                self?.allTasksButton.isHidden = !isVisibile
        }.disposed(by: disposeBag)

        projectNameLabel.text = viewModel.projectName
    }

    private func showOverlay(options: SprintSetUpIndicatorView.SprintOverlayActions) {
        let isVisible = !options.isEmpty
        sprintSetUpView.viewModel.setHidden(!isVisible)

        if isVisible {
            sprintSetUpView.viewModel.layout(style: options)
            sprintSetUpView.viewModel.setTitle("Set Up Week \(viewModel.weeksExisting + 1)")
            sprintSetUpView.onSetUpButtonTapped = { [weak self] in
                self?.showSprintSetUp()
            }
            sprintSetUpView.onFinishButtonTapped = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.onFinishRequested?(strongSelf.viewModel.project)
            }
        }
    }

    private func layoutGraph() {
        graphContainer.addSubview(graphView)
        NSLayoutConstraint.activate([
            graphView.topAnchor.constraint(equalTo: graphContainer.topAnchor),
            graphView.bottomAnchor.constraint(equalTo: graphContainer.bottomAnchor),
            graphView.leadingAnchor.constraint(equalTo: graphContainer.leadingAnchor),
            graphView.trailingAnchor.constraint(equalTo: graphContainer.trailingAnchor)
            ])
    }

    private func layoutProgressBar() {
        projectProgressViewContainer.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: projectProgressViewContainer.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: projectProgressViewContainer.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: projectProgressViewContainer.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: projectProgressViewContainer.trailingAnchor)
            ])
    }

    private func layoutSprintSetUpView() {
        view.addSubview(sprintSetUpView)
        NSLayoutConstraint.activate([
            sprintSetUpView.topAnchor.constraint(equalTo: tableView.topAnchor),
            sprintSetUpView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            sprintSetUpView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            sprintSetUpView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
            ])
    }

    private func layoutAllTasksButton() {
        view.addSubview(allTasksButton)
        NSLayoutConstraint.activate([
            allTasksButton.widthAnchor.constraint(equalTo: allTasksButton.heightAnchor),
            allTasksButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            allTasksButton.centerYAnchor.constraint(equalTo: tasksLabel.centerYAnchor),
            allTasksButton.heightAnchor.constraint(equalToConstant: 22)
            ])
    }

    private func showSprintSetUp() {
        let vc = viewModel.sprintSetUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func presentTaskUpdatingScreen(for task: Task) {
        let vc = TaskUpdateViewController.fromStoryboard(withMode: .update(task))
        present(vc, animated: true, completion: nil)
    }

    @objc private func showAllTasks(sender: UIButton) {
        defer { sender.isEnabled = true }
        sender.isEnabled = false

        let vc = AllTasksManagingViewController.fromStoryBoard(project: viewModel.project)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: UITableViewDelegate + UITableViewDatasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let task = viewModel.taskForIndex(indexPath.row)
            else { fatalError() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as! TaskTableViewCell
        cell.viewModel = TaskTableViewCellViewModel(task: task)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let task = viewModel.taskForIndex(indexPath.row) {
            presentTaskUpdatingScreen(for: task)
            viewModel.watchTask(at: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension DashboardDetailViewController {
    struct OverlayOptions: OptionSet {
        let rawValue: Int
        init(rawValue: Int) {
            self.rawValue = rawValue
        }

        static let setUpNextSprint = OverlayOptions(rawValue: 1 << 0)
        static let showFinished = OverlayOptions(rawValue: 1 << 1)
    }

    class ViewModel {
        let project: Project
        private var projectToken: NotificationToken?
        private var sprintToken: NotificationToken?
        private var taskMasterListToken: NotificationToken?
        private var taskUpdatingToken: NotificationToken?
        private var currentSprint: Sprint?
        private var currentSprintTasks: [Task] {
            return currentSprint?.tasks.map { $0 } ?? []
        }
        private let tableViewUpdatesSubject = PublishSubject<TableViewUpdateType>()
        private let graphUpdatesSubject = Variable<GraphViewUpdate?>(nil)
        private let showFinishOverlay = Variable<Bool>(false)
        private let overlayOptionsSubject = Variable<SprintSetUpIndicatorView.SprintOverlayActions>([])
        private let weekLabelSubject = Variable<String>("Week")
        private let showAllTasksButtonSubject = Variable<Bool>(false)

        var currentUnstarted: Int {
            return currentSprintTasks
                .filter({ $0.state == .unstarted })
                .count
        }
        var currentInProgress: Int {
            return currentSprintTasks
                .filter({ $0.state == .inProgress })
                .count
        }
        var currentFinished: Int {
            return currentSprintTasks
                .filter({ $0.state == .finished })
                .count
        }

        var weeksExisting: Int { return project.sprints.count }
        var projectName: String { return project.name }
        var shouldShowAllTasksButton: Bool { return project.sprints.count != 0 }

        var overlayOptions: Observable<SprintSetUpIndicatorView.SprintOverlayActions> {
            return overlayOptionsSubject.asObservable()
        }

        var graphUpdates: Observable<GraphViewUpdate?> {
            return graphUpdatesSubject
                .asObservable()
        }

        var tableViewUpdates: Observable<TableViewUpdateType> {
            return tableViewUpdatesSubject.asObservable()
        }

        var weeksLabelText: Observable<String> {
            return weekLabelSubject.asObservable()
        }

        var showAllTasksButton: Observable<Bool> {
            return showAllTasksButtonSubject.asObservable()
        }

        let numberOfSections: Int = 1
        var numberOfRows: Int { return currentSprint?.tasks.count ?? 0 }

        init(realm: Realm = RealmFactory.get(.main)) {
            if let project = realm.objects(Project.self)
                .filter("state != \(ProjectState.finished.rawValue)")
                .last {
                self.project = project
                update(with: project.sprints.last)
                updateGraphCounts()
                observe(project: project)
                updateAllTasksButtonVisibility()
            } else {
                fatalError("view cannot be presented without a project")
            }
        }

        func taskForIndex(_ index: Int) -> Task? {
            return currentSprint?.tasks[index]
        }

        func sprintSetUpViewController() -> UIViewController {
            return SprintSetUpViewController.fromStoryboard(with: project)
        }

        func view(_ state: ViewControllerLifeCycle) {
            if state == .didAppear {
                taskUpdatingToken = nil
                updateGraphCounts()
            }
        }

        func watchTask(at path: IndexPath) {
            guard let task = taskForIndex(path.row) else { return }
            taskUpdatingToken = task.observe { [weak self] changes in
                switch changes {
                case .change(_):
                    let reload = TableViewUpdates(section: 0, deletions: [], inserts: [], reloads: [path.row])
                    self?.tableViewUpdatesSubject.onNext(.cellUpdates([reload]))
                default: return
                }
            }
        }

        private func observe(project: Project) {
            projectToken = project.sprints.observe { [weak self] changes in
                switch changes {
                case .initial(_):
                    self?.updateWeekLabel()
                    self?.updateAllTasksButtonVisibility()
                case .update(let sprints, deletions: _, insertions: let inserted, modifications: _):
                    if let lastUpdated = inserted.last {
                        self?.update(with: sprints[lastUpdated])
                    }
                    self?.updateAllTasksButtonVisibility()
                default: break
                }
            }

            taskMasterListToken = project.tasks.observe { [weak self] changes in
                switch changes {
                case .update(_, deletions: _, insertions: _, modifications: _):
                    self?.updateOverlay()
                default: break
                }
            }
        }

        private func update(with sprint: Sprint?) {
            if currentSprint != sprint {
                currentSprint = sprint
                tableViewUpdatesSubject.onNext(.reloadTable)
                updateWeekLabel()
            }
            updateOverlay()
        }

        private func updateOverlay() {
            updateOverlay(sprint: currentSprint)
        }

        private func updateOverlay(sprint: Sprint?) {
            var overlayOptions: SprintSetUpIndicatorView.SprintOverlayActions = []
            let projectHasUnfinishedTasks = project.tasks.contains(where: { $0.state != .finished })
            if !projectHasUnfinishedTasks { overlayOptions.insert(.finish) }

            guard let sprint = sprint else {
                overlayOptions.insert(.setUp)
                overlayOptionsSubject.value = overlayOptions
                return
            }

            let timeLeft = sprint.endDate.timeIntervalSinceNow
            if timeLeft <= 0 {
                overlayOptions.insert(.setUp)
            }

            if timeLeft > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + timeLeft, execute: { [weak self] in
                    self?.updateOverlay()
                })
            }

            overlayOptionsSubject.value = overlayOptions
        }

        private func updateGraphCounts() {
            let graphUpdate = GraphViewUpdate(unstartedCount: currentUnstarted,
                                              inProgressCount: currentInProgress,
                                              finishedCount: currentFinished)
            graphUpdatesSubject.value = graphUpdate
        }

        private func updateWeekLabel() {
            weekLabelSubject.value = "Week \(weeksExisting)"
        }

        private func updateAllTasksButtonVisibility() {
            showAllTasksButtonSubject.value = project.sprints.count != 0
        }
    }
}
