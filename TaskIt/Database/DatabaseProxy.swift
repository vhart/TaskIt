import RealmSwift

protocol DatabaseProxy {
    init(instance: RealmInstance)
    func write(_ obj: Object)
    func write(action: () -> Void)
    func delete(_ obj: Object)
    func objects<Element: Object>(_ type: Element.Type) -> Results<Element>
}

class RealmProxy: DatabaseProxy {
    private let realm: Realm

    required init(instance: RealmInstance) {
        self.realm = RealmFactory.get(instance)
    }

    func write(_ obj: Object) {
        try! realm.write {
            realm.add(obj)
        }
    }

    func delete(_ obj: Object) {
        try! realm.write {
            realm.delete(obj)
        }
    }

    func write(action: () -> Void) {
        try! realm.write(action)
    }

    func objects<Element: Object>(_ type: Element.Type) -> Results<Element> {
        return realm.objects(type)
    }
}
