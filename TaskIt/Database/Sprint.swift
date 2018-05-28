import RealmSwift

public class Sprint: Object {
    @objc dynamic var id: String = UUID().uuidString
    let tasks: List<Task> = List()
    @objc dynamic var startDate: Date = Date()
    var endDate: Date {
        return Calendar.current.date(byAdding: .second, value: 60, to: startDate)!
        //        return Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        //        return Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
    }

    public override static func primaryKey() -> String? {
        return "id"
    }
}
