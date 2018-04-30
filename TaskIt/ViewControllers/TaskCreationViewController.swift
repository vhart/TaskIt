import RxSwift

enum TaskEditingMode {
    case create
    case update(Task)
}

class TaskCreationViewController: UIViewController {

    var mode: TaskEditingMode!
    var viewModel: ViewModel!
    var onComplete: ((Task) -> Void)?

    let disposeBag = DisposeBag()

    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = taskDetailTextView.font
        label.text = "Notes"
        label.textColor = .lightGray
        label.isHidden = true

        return label
    }()

    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskDetailTextView: UITextView!
    @IBOutlet weak var hoursPicker: UIPickerView!
    @IBOutlet weak var completionButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPlaceholder()
        viewModel = ViewModel(mode: mode)
        taskDetailTextView.delegate = self
        taskTitleTextField.delegate = self
        hoursPicker.delegate = self
        hoursPicker.dataSource = self
        styleTextView(selected: false)

        bindUiToViewModel()
    }

    @IBAction func completionButtonTapped(_ sender: Any) {
        onComplete?(viewModel.getTask())
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private func bindUiToViewModel() {
        viewModel.completionButtonEnabled
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] enabled in
                self?.completionButton.backgroundColor = enabled ? .ocean : .fog

                self?.completionButton.isEnabled = enabled
            }.disposed(by: disposeBag)

        viewModel.selectedHoursIndex
            .observeOn(MainScheduler.instance)
            .take(1)
            .subscribeNext { [weak self] index in
                if self?.hoursPicker.selectedRow(inComponent: 0) != index {
                    self?.hoursPicker.selectRow(index, inComponent: 0, animated: true)
                }
            }.disposed(by: disposeBag)

        viewModel.title
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] title in
                self?.taskTitleTextField.text = title
            }.disposed(by: disposeBag)

        viewModel.details
            .observeOn(MainScheduler.instance)
            .filter({ text in
                let validCharacters = CharacterSet.whitespacesAndNewlines.inverted
                return text.rangeOfCharacter(from: validCharacters) != nil
            })
            .subscribeNext { [weak self] details in
                self?.taskDetailTextView.text = details
            }.disposed(by: disposeBag)

        viewModel.isPlaceholderVisibile
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] visible in
                self?.placeholderLabel.isHidden = !visible
        }.disposed(by: disposeBag)

        completionButton.setTitle(viewModel.completionButtonTitle, for: .normal)
    }

    func styleTextView(selected: Bool) {
        if selected {
            taskDetailTextView.layer.cornerRadius = 5
            taskDetailTextView.layer.borderColor = UIColor.grass.cgColor
            taskDetailTextView.layer.borderWidth = 2
        } else {
            taskDetailTextView.layer.cornerRadius = 5
            taskDetailTextView.layer.borderWidth = 1
            taskDetailTextView.layer.borderColor = UIColor.fog.cgColor
        }
    }

    private func setUpPlaceholder() {
        taskDetailTextView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: taskDetailTextView.topAnchor, constant: 4),
            placeholderLabel.leadingAnchor.constraint(equalTo: taskDetailTextView.leadingAnchor, constant: 4)
            ])
    }
}

extension TaskCreationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 101
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "No Selection"
        }

        if row % 2 == 0 {
            return String(format: "%.0f", Float(row) / 2.0)
        } else {
            return String(format: "%.1f", Float(row) / 2.0)
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.didSelect(row: row)
    }
}

extension TaskCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            if text.trimmingCharacters(in: .whitespaces).isEmpty
                && string.trimmingCharacters(in: .whitespaces).isEmpty {
                return false
            }
        }

        return string.rangeOfCharacter(from: .newlines) == nil
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.didEditTitle(title: textField.text)
    }
}

extension TaskCreationViewController: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        styleTextView(selected: true)

        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignTextView))

        toolbar.setItems([doneButton], animated: true)
        toolbar.sizeToFit()

        textView.inputAccessoryView = toolbar

        viewModel.willUpdateTextField()

        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        styleTextView(selected: false)
        viewModel.didEditDetails(details: textView.text)
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty
            && text.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        }

        return true
    }

    @objc func resignTextView() {
        taskDetailTextView.resignFirstResponder()
    }
}

extension TaskCreationViewController {
    struct TaskCreationValidations: OptionSet {
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }

        static let validTitle = TaskCreationValidations(rawValue: 1 << 0 )
        static let validHours = TaskCreationValidations(rawValue: 1 << 1)
        static let fullyValid: TaskCreationValidations = [.validHours, .validTitle]
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

        private var validationChecks: TaskCreationValidations = [] {
            didSet {
                completionEnabledSubject.value = validationChecks.contains(.fullyValid)
            }
        }

        var title: Observable<String?> { return titleSubject.asObservable() }
        var details: Observable<String> { return detailsSubject.asObservable() }
        var isPlaceholderVisibile: Observable<Bool> { return placeHolderVisibilitySubject.asObservable() }
        var selectedHoursIndex: Observable<Int> {
            return hoursIndexSubject.asObservable()
        }

        var completionButtonEnabled: Observable<Bool> {
            return completionEnabledSubject.asObservable()
        }

        init(mode: TaskEditingMode) {
            self.mode = mode

            var task: Task?
            switch mode {
            case .create:
                completionButtonTitle = "Add"
            case .update(let taskToUpdate):
                task = taskToUpdate
                completionButtonTitle = "Save"
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

        func getTask() -> Task {
            guard let title = titleSubject.value,
                hoursSelectedInMinutes > 0
                else { fatalError("Developer error") }

            let task: Task
            switch mode {
            case .create:
                task = Task()

            case .update(let taskToUpdate):
                task = taskToUpdate
            }

            task.title = title
            task.taskDetails = detailsSubject.value
            task.estimatedDuration = hoursSelectedInMinutes

            return task
        }

        func willUpdateTextField() {
            placeHolderVisibilitySubject.value = false
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

