import Foundation
import UIKit
import UserNotifications

class SprintConfirmationViewController: UIViewController {

    static func fromStoryboard(with project: Project, maxTime: Task.Minute) -> SprintConfirmationViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SprintConfirmationViewController") as! SprintConfirmationViewController
        let _ = vc.view
        vc.viewModel = ViewModel(project: project, maxTime: maxTime)
        return vc
    }

    var viewModel: ViewModel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Week \(viewModel.weekNumber)"
    }

    @IBAction func startSprintButtonTapped(_ sender: Any) {
        viewModel.confirmSprint()
        navigationController?.popToRootViewController(animated: true)
    }
}

extension SprintConfirmationViewController: UITableViewDelegate,
UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell",
                                                 for: indexPath) as! TaskTableViewCell
        let task = viewModel.prioritizedTasks[indexPath.row]
        cell.viewModel = TaskTableViewCellViewModel(task: task)

        return cell
    }
}

extension SprintConfirmationViewController {
    class ViewModel {
        private let project: Project
        private let unstartedTasks: [Task]
        private let maxTime: Task.Minute
        private let realm: DatabaseProxy

        var prioritizedTasks = [Task]()
        var weekNumber: Int { return project.sprints.count + 1 }
        
        var numberOfSections: Int { return 1 }
        var numberOfRows: Int { return prioritizedTasks.count }
        
        let localNotifications = LocalNotifications()

        init(project: Project,
             maxTime: Task.Minute,
             realmProxy: DatabaseProxy = RealmProxy(instance: .main)) {
            self.project = project
            self.maxTime = maxTime
            self.realm = realmProxy
            self.unstartedTasks = project.tasks
                .filter { $0.state != .finished }
            setUpTaskList()
        }
        
        func confirmSprint() {
            let sprint = Sprint()
            sprint.tasks.append(objectsIn: prioritizedTasks)
            realm.write {
                project.sprints.append(sprint)
            }
            
            localNotifications.addLocalNotification(title: "\(project.name)", body: "Your current sprint has ended. Tap to set up your next sprint!", date: sprint.endDate)
        }

        private func setUpTaskList() {
            guard unstartedTasks.count > 0 else {
                fatalError()
            }
            prioritizedTasks.append(unstartedTasks.first!)
            var currentTime = unstartedTasks.first!.estimatedDuration

            for i in 1..<unstartedTasks.count {
                let task = unstartedTasks[i]
                guard currentTime + task.estimatedDuration <= maxTime
                    else { break }
                prioritizedTasks.append(task)
                currentTime += task.estimatedDuration
            }
        }
    }
}
