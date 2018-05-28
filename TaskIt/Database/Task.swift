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
