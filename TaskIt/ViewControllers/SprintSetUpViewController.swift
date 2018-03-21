import RealmSwift
import RxSwift

class SprintSetUpViewController: UIViewController {

    static func fromStoryboard() -> SprintSetUpViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SprintSetUpViewController") as! SprintSetUpViewController

        return vc
    }

    var viewModel: ViewModel!
    
}

extension SprintSetUpViewController: UIPickerViewDelegate,
UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 101
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "No Selection"
        }

        if row % 2 == 0 {
            return String(format: "%.0f", Float(row) / 2.0)
        } else {
            return String(format: "%.1f", Float(row) / 2.0)
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        viewModel.didSelect(row: row)
    }
}

extension SprintSetUpViewController: UITableViewDelegate,
UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell",
                                                 for: indexPath) as! TaskTableViewCell
        if let task = viewModel.task(for: indexPath) {
            cell.viewModel = TaskTableViewCellViewModel(task: task)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            self?.viewModel.removeTask(index: indexPath)
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

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 { return false }
        return true
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 { return false }
        return true
    }

    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        let movedObject = viewModel.task(for: [sourceIndexPath])

        viewModel.tasks.insert(movedObject, at: destinationIndexPath.row)
    }
}

extension SprintSetUpViewController {
    struct TableViewUpdates {
        let section: Int
        let deletions: [Int]
        let inserts: [Int]
        let reloads: [Int]
    }

    class ViewModel {
        private var unfinishedTasksToken: NotificationToken?
        private var finishedTasksToken: NotificationToken?

        private let viewState = Variable<ViewControllerLifeCycle!>(nil)
        private let unfinishedUpdates = PublishSubject<TableViewUpdates>()
        private let finishedUpdates = PublishSubject<TableViewUpdates>()

        private let unfinishedTasks: Results<Task>
        private let finishedTasks: Results<Task>

        private var delayedUiEvents: [() -> Void] = []

        private let realm: RealmProxy

        let project: Project

        init(project: Project, realm: RealmProxy = RealmProxy(instance: .main)) {
            self.project = project
            self.realm = realm

            unfinishedTasks = project.tasks.filter("state != \(TaskState.finished.rawValue)")
            finishedTasks = project.tasks.filter("state == \(TaskState.finished.rawValue)")

            watchForUpdates()
        }

        func numberOfRowsInSection(section: Int) -> Int {
            if section == 0 {
                return unfinishedTasks.count
            } else {
                return finishedTasks.count
            }
        }

        func numberOfSections() -> Int {
            return 2
        }

        func removeTask(index: IndexPath) {
            if let task = task(for: index) {
                realm.delete(task)
            }
        }

        func moveTask(from original: IndexPath, to destination: IndexPath) {
            if let task = task(for: original) {
                realm.write {
                    project.tasks.move(from: original.row, to: destination.row)
                }
            }
        }

        func task(for path: IndexPath) -> Task? {
            switch path.section {
            case 0: return unfinishedTasks[path.row]
            case 1: return finishedTasks[path.row]
            default: return nil
            }
        }

        func watchForUpdates() {
            unfinishedTasksToken = unfinishedTasks.observe { [weak self] change in
                switch change {
                case .update(_, let deletions, let insertions, let updates):
                    self?.updateUnfinishedSection(updates: TableViewUpdates(section: 0,
                                                 deletions: deletions,
                                                 inserts: insertions,
                                                 reloads: updates))
                default: break
                }
            }

            finishedTasksToken = finishedTasks.observe { [weak self] change in
                switch change {
                case .update(_, let deletions, let insertions, let updates):
                    self?.updateFinishedSection(updates: TableViewUpdates(section: 1,
                                                 deletions: deletions,
                                                 inserts: insertions,
                                                 reloads: updates))
                default: break
                }
            }
        }

        private func updateUnfinishedSection(updates: TableViewUpdates) {
            guard viewState.value == .didAppear else {
                delayedUiEvents.append { [weak self] in
                    self?.unfinishedUpdates.onNext(updates)
                }
                return
            }

            unfinishedUpdates.onNext(updates)
        }

        private func updateFinishedSection(updates: TableViewUpdates) {
            guard viewState.value == .didAppear else {
                delayedUiEvents.append { [weak self] in
                    self?.finishedUpdates.onNext(updates)
                }
                return
            }

            finishedUpdates.onNext(updates)
        }

        private func purgeUiUpdates() {
            for update in delayedUiEvents {
                update()
            }
            delayedUiEvents = []
        }
    }
}
