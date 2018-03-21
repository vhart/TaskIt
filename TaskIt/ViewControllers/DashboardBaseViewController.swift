import UIKit
import RealmSwift
import RxSwift

class DashboardBaseViewController: UIViewController {

    private var detailViewController: UIViewController?

    var viewModel = ViewModel()
    let disposeBag = DisposeBag()

    lazy var dashDetailContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDetailContainer()
        bindUiToViewModel()
        viewModel.view(.didLoad)
    }

    @IBAction func addProjectTapped(_ sender: Any) {
//        let projectCreationVC = ProjectCreationViewController.fromStoryboard()
//        navigationController?.pushViewController(projectCreationVC, animated: true)
    }

    private func bindUiToViewModel() {
        viewModel.showDashDetail
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] showDetail in
                switch showDetail {
                case true:
                    self?.dashDetailContainer.alpha = 1.0
                    self?.embedDetailViewController()
                    self?.view.backgroundColor = .lightGray
                case false:
                    self?.dashDetailContainer.alpha = 0.0
                    self?.removeDetailViewController()
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
        let child = DashboardDetailViewController.fromStoryboard()
        child.view.backgroundColor = .white
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.layer.cornerRadius = 5

        addChildViewController(child)
        dashDetailContainer.addSubview(child.view)

        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: dashDetailContainer.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: dashDetailContainer.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: dashDetailContainer.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: dashDetailContainer.trailingAnchor)
            ])
        child.willMove(toParentViewController: self)
        child.didMove(toParentViewController: self)

        detailViewController = child
    }

    private func removeDetailViewController() {
        detailViewController?.willMove(toParentViewController: nil)
        detailViewController?.view.removeFromSuperview()
        detailViewController?.removeFromParentViewController()
        detailViewController = nil
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
            return showDashDetailSubject.asObservable().distinctUntilChanged()
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
