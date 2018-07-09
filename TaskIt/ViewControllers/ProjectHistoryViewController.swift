import UIKit
import RealmSwift
import RxSwift

class ProjectHistoryViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let viewModel = ViewModel()
    
    private let cellSpacing: CGFloat = 8
    @IBOutlet weak var noHistoryView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHistoryView()
        setUpNoHistoryView()
        historyCollectionView.delegate = self
        historyCollectionView.dataSource = self
        bindUiToViewModel()
        navigationItem.title = "History"
    }
    
    let cell = "Project History Cell"
    
    lazy var historyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .fog
        collectionView.register(HistoryCollectionViewCell.self, forCellWithReuseIdentifier: cell)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private func setupHistoryView() {
        view.addSubview(historyCollectionView)
        NSLayoutConstraint.activate([
            historyCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            historyCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            historyCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            historyCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            historyCollectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            ])
    }

    private func setUpNoHistoryView() {
        view.bringSubview(toFront: noHistoryView)
    }
    
    private func bindUiToViewModel() {
        viewModel.showNoHistory
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] showView in
                self?.noHistoryView.isHidden = !showView
        }.disposed(by: disposeBag)

        viewModel.collectionViewUpdates
            .observeOn(MainScheduler.asyncInstance)
            .subscribeNext { [weak self] update in
                switch update {
                case .reload:
                    self?.historyCollectionView.reloadData()
                }
        }.disposed(by: disposeBag)
    }

}

extension ProjectHistoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.projects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Project History Cell", for: indexPath) as! HistoryCollectionViewCell
        cell.viewModel = viewModel.historyCollectionViewCellViewModel(row: indexPath.row)
        return cell
    }
}

extension ProjectHistoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells: CGFloat = 1
        let numSpaces: CGFloat = numCells + 1
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        return CGSize(width: (screenWidth - (cellSpacing * numSpaces)) , height: screenHeight * 0.30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: 0, right: cellSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
}

extension ProjectHistoryViewController {
    enum CollectionViewUpdates {
        case reload
    }

    class ViewModel {
        private let collectionViewUpdatesSubject = Variable<CollectionViewUpdates>(.reload)
        private let showNoHistorySubject = Variable(true)

        var collectionViewUpdates: Observable<CollectionViewUpdates> {
            return collectionViewUpdatesSubject.asObservable()
        }
        var projectsNotificationToken: NotificationToken? {
            willSet {
                projectsNotificationToken?.invalidate()
            }
        }

        var showNoHistory: Observable<Bool> { return showNoHistorySubject.asObservable() }

        var projects = [Project]() {
            didSet {
                showNoHistorySubject.value = projects.isEmpty
                collectionViewUpdatesSubject.value = .reload
            }
        }
        
        private let database: Realm
        
        init(database: Realm = RealmFactory.get(.main)) {
            self.database = database
            watchForFinishedProjects()
        }
        
        func historyCollectionViewCellViewModel(row: Int) -> HistoryCollectionViewCell.ViewModel {
            let project = projects[row]
            let totalMinutes = project.tasks.reduce(0) { (currentTotal, task) in
                let newTotal = currentTotal + task.estimatedDuration
                return newTotal
            }
            let viewModel = HistoryCollectionViewCell.ViewModel(title: project.name,
                                                                weeksCount: project.sprints.count, tasksCount: project.tasks.count, totalMinutes: totalMinutes)
            return viewModel
        }
        
        private func watchForFinishedProjects() {
            projectsNotificationToken = database.objects(Project.self)
                .filter("state == \(ProjectState.finished.rawValue)")
                .observe { [weak self] (change) in
                    let newProjects: [Project]
                    switch change {
                    case .initial(let projects):
                        newProjects = projects.map { $0 }
                    case .update(let projects, _, _, _):
                        newProjects = projects.map { $0 }
                    case .error: fatalError()
                    }

                    self?.projects = newProjects.sorted(by: { return $0.endDate! > $1.endDate! })
            }
        }
    }
}
