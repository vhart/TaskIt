import RxSwift
import RealmSwift
import UIKit

class DashboardDetailViewController: UIViewController {

    @IBOutlet weak var graphContainer: UIView!
    @IBOutlet weak var projectProgressViewContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!

    var viewModel = ViewModel()

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
        view.gradientLayer?.colors = CGColor.purples
        return view
    }()

    lazy var sprintSetUpView: SprintSetUpIndicatorView = {
        let view = SprintSetUpIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    class func fromStoryboard() -> DashboardDetailViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashDetailViewController")
        return vc as! DashboardDetailViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.layer.cornerRadius = 5
        tableView.delegate = self
        tableView.dataSource = self
        layoutGraph()
        layoutProgressBar()
        layoutSprintSetUpView()

        if viewModel.shouldOverlayWithSprintStart {
            sprintSetUpView.viewModel.setHidden(false)
            sprintSetUpView.viewModel.setTitle("Set Up Week X")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.graphView.updateTaskCounts(unstarted: 1, inProgress: 2, finished: 1)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.graphView.updateTaskCounts(unstarted: 4, inProgress: 1, finished: 3)
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
}

extension DashboardDetailViewController: UITableViewDelegate, UITableViewDataSource {
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

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

extension DashboardDetailViewController {
    class ViewModel {
        private let project: Project
        private var currentSprint: Sprint? { return project.sprints.last }
        private var currentSprintTasks: [Task] {
            return currentSprint?.tasks.map { $0 } ?? []
        }

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

        var week: Int { return project.sprints.count }
        var shouldOverlayWithSprintStart: Bool {
            guard let sprint = currentSprint else { return true }
            return sprint.endDate < Date()
        }

        let numberOfSections: Int = 1
        var numberOfRows: Int { return currentSprint?.tasks.count ?? 0 }

        init(realm: Realm = RealmFactory.get(.main)) {
            if let project = realm.objects(Project.self)
                .filter("state != \(ProjectState.finished.rawValue)")
                .last {
//                fatalError("view cannot be presented without a project") }
            self.project = project
            } else {
                self.project = Project()
                self.project.name = "Dummy Project"

                let t1 = Task()
                t1.estimatedDuration = 90
                t1.title = "T1"
                t1.taskDetails = ""

                let t2 = Task()
                t2.estimatedDuration = 30
                t2.title = "T2"
                t2.taskDetails = "blue lagoon is cool for you"
                t2.state = .inProgress

                let t3 = Task()
                t3.estimatedDuration = 30
                t3.title = "T3"
                t3.taskDetails = "winky"
                t3.state = .inProgress

                let sprint = Sprint()
                sprint.tasks.append(t1)
                sprint.tasks.append(t2)
                sprint.tasks.append(t3)

                self.project.sprints.append(sprint)

                self.project.tasks.append(t1)
                self.project.tasks.append(t2)
                self.project.tasks.append(t3)
            }
        }

        func taskForIndex(_ index: Int) -> Task? {
            return currentSprint?.tasks[index]
        }
    }
}
