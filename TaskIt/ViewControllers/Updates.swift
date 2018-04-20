enum TableViewUpdateType {
    case cellUpdates([TableViewUpdates])
    case reloadTable
}

struct TableViewUpdates {
    let section: Int
    let deletions: [Int]
    let inserts: [Int]
    let reloads: [Int]
}

struct GraphViewUpdate {
    let unstartedCount: Int
    let inProgressCount: Int
    let finishedCount: Int
}
