import UIKit
import RealmSwift
import RxSwift

class ProjectHistoryViewController: UIViewController {

    private let historyView = ProjectHistoryView()
    
    private let cellSpacing: CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(historyView)
        historyView.historyCollectionView.delegate = self
        historyView.historyCollectionView.dataSource = self
        
    }

}

extension ProjectHistoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20 // something like completedProjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Project History Cell", for: indexPath)
        cell.backgroundColor = .orange
        return cell
    }
}

extension ProjectHistoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells: CGFloat = 1
        let numSpaces: CGFloat = numCells + 1
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        return CGSize(width: (screenWidth - (cellSpacing * numSpaces)) , height: screenHeight * 0.25)
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
        var projects = [Project]()
        
        private let database: Realm
        
        init(database: Realm = RealmFactory.get(.main)) {
            self.database = database
        }
        
        private func watchForFinishedProjects() {
            database.objects(Project.self)
                .filter("state == \(ProjectState.finished.rawValue)")
                .observe { [weak self] (change) in
                    switch change {
                    case .initial(let projects): self?.projects = projects
                    }
            }
        }
    }
}
