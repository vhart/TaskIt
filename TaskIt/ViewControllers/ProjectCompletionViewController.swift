import UIKit
import RealmSwift

class ProjectCompletionViewController: UIViewController {
    enum Action {
        case finish
        case cancel
    }

    var onAction: ((Action) -> Void)?
    var viewModel: ViewModel!

    static func fromStoryboard(project: Project) -> ProjectCompletionViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProjectCompletionViewController") as! ProjectCompletionViewController
        vc.viewModel = ViewModel(project: project)
        return vc
    }

    @IBOutlet weak var progressGradientView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var projectTitleLabel: UILabel!

    @IBOutlet weak var statsViewContainer: UIView!
    
    lazy var stats = StatsView()

    lazy var gradient: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.gradientLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        view.gradientLayer?.colors = CGColor.greens
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        styleCancelButton()
        setUpGradient()
        setupStatsView()
        projectTitleLabel.text = viewModel.projectTitle
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        defer { sender.isEnabled = true }
        sender.isEnabled = false
        viewModel.finishProject()
        onAction?(.finish)
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        defer { sender.isEnabled = true }
        sender.isEnabled = false

        onAction?(.cancel)
    }


    private func styleCancelButton() {
        let image = #imageLiteral(resourceName: "x-icon").withRenderingMode(.alwaysTemplate)
        cancelButton.setBackgroundImage(image, for: .normal)
        cancelButton.tintColor = .red
    }

    private func setUpGradient() {
        progressGradientView.addSubview(gradient)
        NSLayoutConstraint.activate([
            gradient.leadingAnchor.constraint(equalTo: progressGradientView.leadingAnchor),
            gradient.topAnchor.constraint(equalTo: progressGradientView.topAnchor),
            gradient.trailingAnchor.constraint(equalTo: progressGradientView.trailingAnchor),
            gradient.bottomAnchor.constraint(equalTo: progressGradientView.bottomAnchor)
            ])
    }
    
    private func setupStatsView() {
        stats.viewModel = viewModel.getStatsViewModel()
        statsViewContainer.addSubview(stats)
        stats.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stats.leadingAnchor.constraint(equalTo: statsViewContainer.leadingAnchor),
            stats.topAnchor.constraint(equalTo: statsViewContainer.topAnchor),
            stats.trailingAnchor.constraint(equalTo: statsViewContainer.trailingAnchor),
            stats.bottomAnchor.constraint(equalTo: statsViewContainer.bottomAnchor)
            ])
        
    }
    
}

extension ProjectCompletionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as! TaskTableViewCell
        cell.viewModel = viewModel.taskCellViewModel(row: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension ProjectCompletionViewController {
    class ViewModel {
        let project: Project
        let database: DatabaseProxy

        init(project: Project,
             database: DatabaseProxy = RealmProxy(instance: .main)) {
            self.project = project
            self.database = database
        }

        var numberOfSections: Int { return 1 }
        var numberOfRows: Int { return project.tasks.count }
        var projectTitle: String { return project.name }

        func taskCellViewModel(row: Int) -> TaskTableViewCellViewModel {
            let task = project.tasks[row]
            return TaskTableViewCellViewModel(task: task)
        }

        func getStatsViewModel() -> StatsView.ViewModel {
            let sprintCount = project.sprints.count
            let taskCount = project.tasks.count
            let totalMinutes = project.tasks.reduce(0) { (currentTotal, task) in
                let newTotal = currentTotal + task.estimatedDuration
                return newTotal
            }
            return StatsView.ViewModel.init(numberOfSprints: sprintCount,
                                            numberOfTasks: taskCount,
                                            numberOfMinutes: totalMinutes)
        }
        
        func finishProject() {
            database.write {
                project.finishProject()
            }
        }
    }
}
