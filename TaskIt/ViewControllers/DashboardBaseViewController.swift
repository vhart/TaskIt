import UIKit
import RealmSwift
import RxSwift

enum ViewControllerLifeCycle {
    case didLoad
    case willAppear
    case willDisappear
    case didAppear
    case didDisappear
}

class DashboardBaseViewController: UIViewController {

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
        embedDetailViewController()
        bindUiToViewModel()
        viewModel.view(.didLoad)
    }

    @IBAction func addProjectTapped(_ sender: Any) {
    }

    private func bindUiToViewModel() {
        viewModel.showDashDetail
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] showDetail in
                switch showDetail {
                case true:
                    self?.dashDetailContainer.alpha = 1.0
                case false:
                    self?.dashDetailContainer.alpha = 0.0
                }
        }.disposed(by: disposeBag)
    }

    private func embedDetailViewController() {
        view.addSubview(dashDetailContainer)
        let child = UIViewController()
        child.view.backgroundColor = .purple
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.layer.cornerRadius = 5
        addChildViewController(child)
        dashDetailContainer.addSubview(child.view)
        NSLayoutConstraint.activate([
            dashDetailContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            dashDetailContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            dashDetailContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            dashDetailContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            child.view.topAnchor.constraint(equalTo: dashDetailContainer.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: dashDetailContainer.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: dashDetailContainer.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: dashDetailContainer.trailingAnchor)
            ])
        child.willMove(toParentViewController: self)
        child.didMove(toParentViewController: self)
    }
}

protocol DashboardBaseViewModel {
    var showDashDetail: Observable<Bool> { get }

    func view(_ state: ViewControllerLifeCycle)
}

extension DashboardBaseViewController {
    class ViewModel: DashboardBaseViewModel {
        private let realm: Realm

        private let showDashDetailSubject = PublishSubject<Bool>()
        var showDashDetail: Observable<Bool> {
            return showDashDetailSubject.asObservable().distinctUntilChanged()
        }

        init(realm: Realm = RealmFactory.realm()) {
            self.realm = realm
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
            let incompleteProjects = realm.objects(Project.self)
                .filter("state != \(ProjectState.finished.rawValue)")
            showDashDetailSubject.onNext(!incompleteProjects.isEmpty)
        }
    }
}
