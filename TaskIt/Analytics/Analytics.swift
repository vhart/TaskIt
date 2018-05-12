protocol AnalyticsTracker {
    func activate()
    func deactivate()
    func configure()
    func logEvent(_ name: String, parameters: [String: Any])
}
