import RealmSwift

@objc public enum TaskState: Int {
    case unstarted
    case inProgress
    case finished

    var text: String {
        switch self {
        case .unstarted: return "Unstarted"
        case .inProgress: return "In Progress"
        case .finished: return "Finished"
        }
    }
}

@objc public enum ProjectState: Int {
    case unstarted
    case inProgress
    case finished
}

public class Task: Object {
    typealias Minute = Int

    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var taskDetails: String = ""
    @objc dynamic var state: TaskState = .unstarted
    @objc dynamic var priority: Int = 0
    @objc dynamic var estimatedDuration: Minute = 0

    public override static func primaryKey() -> String? {
        return "id"
    }
}

extension Task.Minute {
    var asHourString: String {
        let hours = Float(self)/60.0
        if self % 60 == 0 {
            return String(format: "%.0f", hours)
        } else {
            return String(format: "%.1f", hours)
        }
    }
}


public class Sprint: Object {
    @objc dynamic var id: String = UUID().uuidString
    let tasks: List<Task> = List()
    @objc dynamic var startDate: Date = Date()
    var endDate: Date {
//        return Calendar.current.date(byAdding: .second, value: 30, to: startDate)!
        return Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
    }

    public override static func primaryKey() -> String? {
        return "id"
    }
}

public class Project: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var state: ProjectState = .unstarted

    let tasks: List<Task> = List()
    let sprints: List<Sprint> = List()

    public override static func primaryKey() -> String? {
        return "id"
    }
}

