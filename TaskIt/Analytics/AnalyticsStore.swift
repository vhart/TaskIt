class AnalyticsStore {
    static let store = AnalyticsStore()
    private var tracker: AnalyticsTracker = FirebaseAnalyticsTracker()

    static func get() -> AnalyticsTracker { return store.tracker }
}

class Analytics {
    static func logEvent(_ name: String, parameters: [String: Any]) {
        AnalyticsStore.get().logEvent(name, parameters: parameters)
    }
}
