import RealmSwift

protocol RealmGetter {
    static func realm() -> Realm
    static func get(_ instanceType: RealmInstance) -> Realm
}
enum RealmInstance {
    case main
    case new
}

class RealmFactory: RealmGetter {
    static func realm() -> Realm {
        return try! Realm()
    }

    static func get(_ instanceType: RealmInstance) -> Realm {
        return RealmCache.get(instanceType)
    }
}

class RealmCache {
    private static let shared = RealmCache()

    private var instances = [RealmInstance: Realm]()

    static func get(_ instanceType: RealmInstance) -> Realm {
        if let instance = shared.instances[instanceType] {
            return instance
        } else {
            let newRealm = RealmFactory.realm()
            shared.instances[instanceType] = newRealm
            return newRealm
        }
    }
}

extension Array where Element: Object {
    func toList() -> List<Element> {
        let list = List<Element>()
        for obj in self {
            list.append(obj)
        }

        return list
    }
}
