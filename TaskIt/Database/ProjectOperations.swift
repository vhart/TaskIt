public protocol ProjectOperations {
    func replace(range: ClosedRange<Int>, with: [Task])
    func deleteTask(at: Int)
    func moveTask(from: Int, to: Int)
}


