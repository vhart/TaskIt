import UIKit
import RealmSwift
import RxSwift

class DashboardBaseViewController: UIViewController {

    private var embedCoordinator: EmbedCoordinator!

    @IBOutlet weak var addProjectButton: UIButton!

    var viewModel = ViewModel()
    let disposeBag = DisposeBag()

    lazy var dashDetailContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        embedCoordinator = EmbedCoordinator(base: self)
        setUpDetailContainer()
        bindUiToViewModel()
        viewModel.view(.didLoad)
    }

    @IBAction func addProjectTapped(_ sender: Any) {

    }

    private func bindUiToViewModel() {
        viewModel.showDashDetail
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] showDetail in
                switch showDetail {
                case true:
                    self?.addProjectButton.alpha = 0
                    self?.dashDetailContainer.alpha = 1
                    self?.embedDetailViewController()
                    self?.view.backgroundColor = .fog
                case false:
                    self?.addProjectButton.alpha = 1
                    self?.dashDetailContainer.alpha = 0
                    self?.embedCoordinator.removeCurrentEmbeddedViewController()
                    self?.view.backgroundColor = .white
                }
        }.disposed(by: disposeBag)
    }

    private func setUpDetailContainer() {
        view.addSubview(dashDetailContainer)

        NSLayoutConstraint.activate([
            dashDetailContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            dashDetailContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            dashDetailContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            dashDetailContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
            ])
    }

    private func embedDetailViewController() {
        let detailVC = DashboardDetailViewController.fromStoryboard()
        detailVC.onFinishRequested = { [weak self] project in
            self?.flipToCompletionViewController(project: project)
        }
        embedCoordinator.embed(child: detailVC, in: dashDetailContainer)
    }

    private func embedProjectCompletionViewController(project: Project) {
        let completionVC = ProjectCompletionViewController.fromStoryboard(project: project)
        completionVC.onAction = { [weak self] action in
            switch action {
            case .cancel:
                self?.flipToDetailViewController()
            case .finish: break
            }
        }
        embedCoordinator.embed(child: completionVC, in: dashDetailContainer)
    }

    private func flipToCompletionViewController(project: Project) {
        UIView.transition(with: dashDetailContainer,
                          duration: 0.4,
                          options: .transitionFlipFromRight,
                          animations: {
                            self.embedProjectCompletionViewController(project: project)
        },
                          completion: nil)
    }

    private func flipToDetailViewController() {
        UIView.transition(with: dashDetailContainer,
                          duration: 0.4,
                          options: .transitionFlipFromLeft,
                          animations: {
                            self.embedDetailViewController()
        },
                          completion: nil)
    }
}

protocol DashboardBaseViewModel {
    var showDashDetail: Observable<Bool> { get }

    func view(_ state: ViewControllerLifeCycle)
}

extension DashboardBaseViewController {
    class ViewModel: DashboardBaseViewModel {
        private let realm: Realm
        private var notificationToken: NotificationToken?
        private let projects: Results<Project>

        private let showDashDetailSubject = PublishSubject<Bool>()
        var showDashDetail: Observable<Bool> {
            return showDashDetailSubject.asObservable()
        }

        init(realm: Realm = RealmFactory.realm()) {
            self.realm = realm
            self.projects = realm.objects(Project.self)
                .filter("state != \(ProjectState.finished.rawValue)")
            watchProjectCollection()
        }

        func view(_ state: ViewControllerLifeCycle) {
            switch state {
            case .didLoad, .willAppear:
                DispatchQueue.onMain { [weak self] in
                    self?.refreshUI()
                }
            default: break
            }
        }

        private func refreshUI() {
            showDashDetailSubject.onNext(!projects.isEmpty)
        }

        private func watchProjectCollection() {
            notificationToken = projects.observe({ [weak self] (changes: RealmCollectionChange) in
                DispatchQueue.onMain {
                    self?.refreshUI()
                }
            })
        }
    }
}
