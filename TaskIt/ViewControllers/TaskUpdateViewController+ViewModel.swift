import RxSwift

extension TaskUpdateViewController {
    struct TaskCreationValidations: OptionSet {
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }

        static let validTitle = TaskCreationValidations(rawValue: 1 << 0 )
        static let validHours = TaskCreationValidations(rawValue: 1 << 1)
        static let fullyValid: TaskCreationValidations = [.validHours, .validTitle]
    }

    enum HoursSelectionStatus {
        case editing
        case none
    }

    class ViewModel {

        let mode: TaskEditingMode
        let completionButtonTitle: String

        private var hoursSelectedInMinutes: Task.Minute = 0
        private let disposeBag = DisposeBag()
        private let titleSubject = Variable<String?>(nil)
        private let detailsSubject = Variable<String>("")
        private let hoursIndexSubject = Variable<Int>(0)
        private let completionEnabledSubject = Variable(false)
        private let placeHolderVisibilitySubject = Variable<Bool>(false)
        private let hoursSelectionSubject = PublishSubject<HoursSelectionStatus>()
        private let realm: DatabaseProxy
        private let taskStateSubject: Variable<TaskState>

        private(set) var shouldBeginEditingTaskTitle = false

        private var validationChecks: TaskCreationValidations = [] {
            didSet {
                completionEnabledSubject.value = validationChecks.contains(.fullyValid)
            }
        }

        var title: Observable<String?> { return titleSubject.asObservable() }
        var details: Observable<String> { return detailsSubject.asObservable() }

        var taskState: Observable<String> {
            return Observable<String>.create({ [weak self] (observer) -> Disposable in
                return self?.taskStateSubject.asObservable()
                    .distinctUntilChanged()
                    .subscribeNext(onNext: { state in
                        switch state {
                        case .unstarted: observer.onNext("Unstarted")
                        case .inProgress: observer.onNext("In Progress")
                        case .finished: observer.onNext("Finished")
                        }
                    }) ?? Disposables.create()
            })
        }

        var isPlaceholderVisibile: Observable<Bool> { return placeHolderVisibilitySubject.asObservable() }
        var selectedHoursIndex: Observable<Int> {
            return hoursIndexSubject.asObservable()
        }

        var completionButtonEnabled: Observable<Bool> {
            return completionEnabledSubject.asObservable()
        }

        var hoursSelectionStatus: Observable<HoursSelectionStatus> {
            return hoursSelectionSubject.asObservable()
        }

        init(mode: TaskEditingMode, realmProxy: DatabaseProxy = RealmProxy(instance: .main)) {
            self.mode = mode
            self.realm = realmProxy

            var task: Task?
            switch mode {
            case .create:
                completionButtonTitle = "Add"
                taskStateSubject = Variable(.unstarted)
            case .update(let taskToUpdate):
                task = taskToUpdate
                completionButtonTitle = "Save"
                taskStateSubject = Variable(taskToUpdate.state)
            }

            if let unwrappedTask = task {
                titleSubject.value = unwrappedTask.title
                detailsSubject.value = unwrappedTask.taskDetails
                hoursIndexSubject.value = unwrappedTask.estimatedDuration / 30
                hoursSelectedInMinutes = unwrappedTask.estimatedDuration

                validationChecks = .fullyValid
                completionEnabledSubject.value = true
            }
            watchDetailSubject()
        }

        func view(_ state: ViewControllerLifeCycle) {
            switch state {
            case .didLoad:
                if let title = titleSubject.value {
                    shouldBeginEditingTaskTitle = title.isEmpty
                } else {
                    shouldBeginEditingTaskTitle = true
                }
            case .willDisappear:
                shouldBeginEditingTaskTitle = false
            default: break
            }
        }

        func didSelect(row: Int) {
            hoursSelectedInMinutes = row * 30

            if row == 0 {
                validationChecks.remove(.validHours)
            } else {
                validationChecks.insert(.validHours)
            }

            hoursIndexSubject.value = row
        }

        func didEditTitle(title: String?) {
            let trimmed = title?.trimmingCharacters(in: .whitespacesAndNewlines)
            if isValidTitle(title: trimmed) {
                titleSubject.value = trimmed
                validationChecks.insert(.validTitle)
            } else {
                titleSubject.value = nil
                validationChecks.remove(.validTitle)
            }
        }

        func didEditDetails(details: String) {
            detailsSubject.value = details
        }

        func stateDidChange(to newState: TaskState) {
            taskStateSubject.value = newState
        }

        func getTask() -> Task {
            guard let _ = titleSubject.value,
                hoursSelectedInMinutes > 0
                else { fatalError("Developer error") }

            let task: Task
            switch mode {
            case .create:
                task = Task()
                getTaskUpdates()(task)
            case .update(let taskToUpdate):
                task = taskToUpdate
                realm.write {
                    getTaskUpdates()(task)
                }
            }

            return task
        }

        func getTaskUpdates() -> (Task) -> Void {
            guard let title = titleSubject.value,
                hoursSelectedInMinutes > 0
                else { fatalError("Developer error") }
            let details = detailsSubject.value
            let estimatedDuration = hoursSelectedInMinutes
            let state = taskStateSubject.value

            return { (task: Task) -> Void in
                task.title = title
                task.taskDetails = details
                task.estimatedDuration = estimatedDuration
                task.state = state
            }
        }

        func title(for row: Int) -> String {
            if row == 0 {
                return "No Selection"
            }

            if row % 2 == 0 {
                return String(format: "%.0f", Float(row) / 2.0)
            } else {
                return String(format: "%.1f", Float(row) / 2.0)
            }
        }

        func willUpdateTextField() {
            placeHolderVisibilitySubject.value = false
        }

        func willUpdateHours() {
            hoursSelectionSubject.onNext(.editing)
        }

        func endHoursEditing() {
            hoursSelectionSubject.onNext(.none)
        }

        func selectedHoursRow() -> Int {
            return hoursIndexSubject.value
        }

        private func watchDetailSubject() {
            details.subscribeNext { [weak self] text in
                let validCharacters = CharacterSet.whitespacesAndNewlines.inverted
                if text.rangeOfCharacter(from: validCharacters) != nil {
                    self?.placeHolderVisibilitySubject.value = false
                } else {
                    self?.placeHolderVisibilitySubject.value = true
                }
                }.disposed(by: disposeBag)
        }

        private func isValidTitle(title: String?) -> Bool {
            guard let title = title else { return false }
            let nonWhiteSpace = CharacterSet.whitespacesAndNewlines.inverted

            return title.rangeOfCharacter(from: nonWhiteSpace) != nil
        }
    }
}

