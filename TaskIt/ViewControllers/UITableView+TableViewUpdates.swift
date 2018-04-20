import UIKit

extension UITableView {
    func performBatchUpdates(with updates: [TableViewUpdates],
                             completion: ((Bool) -> Void)?) {
        let reloads = updates.flatMap { update in
            return update.reloads.map {
                IndexPath(row: $0, section: update.section)
            }
        }
        let deletions = updates.flatMap { update in
            return update.deletions.map {
                IndexPath(row: $0, section: update.section)
            }
        }
        let insertions = updates.flatMap { update in
            return update.inserts.map {
                IndexPath(row: $0, section: update.section)
            }
        }

        performBatchUpdates({
            deleteRows(at: deletions, with: .fade)
            insertRows(at: insertions, with: .automatic)
            reloadRows(at: reloads, with: .automatic)
        }, completion: completion)
    }
}
