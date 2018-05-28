import RealmSwift

@objc public enum ProjectState: Int {
    case unstarted
    case inProgress
    case finished
}

public class Project: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var state: ProjectState = .unstarted
    @objc dynamic var startDate: Date = Date()
    @objc dynamic var endDate: Date?

    let tasks: List<Task> = List()
    let sprints: List<Sprint> = List()

    public override static func primaryKey() -> String? {
        return "id"
    }

    public func finishProject() {
        guard state != .finished else { return }
        state = .finished
        endDate = Date()
    }
}
