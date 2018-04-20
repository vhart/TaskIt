import RxSwift

class TaskUpdateViewController: UIViewController {

    static func fromStoryboard(withMode mode: TaskEditingMode) -> TaskUpdateViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TaskUpdateViewController") as! TaskUpdateViewController
        vc.mode = mode
        return vc
    }

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

    lazy var tapView: TapRecognizingView = {
        let v = TapRecognizingView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    lazy var hoursTableView: UITableView = {
        let tbv = UITableView()
        tbv.register(HourSelectionTableViewCell.self, forCellReuseIdentifier: "HourSelectionCell")
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.alpha = 0
        tbv.layer.maskedCorners = [.layerMaxXMaxYCorner,
                                   .layerMaxXMinYCorner,
                                   .layerMinXMaxYCorner,
                                   .layerMinXMinYCorner]
        tbv.layer.cornerRadius = 5

        return tbv
    }()

    lazy var shuffleView: ShuffleView = {
        var state: TaskState = .unstarted
        switch self.mode! {
        case .create: state = .unstarted
        case .update(let task): state = task.state
        }

        let sv = ShuffleView(state: state)
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)

        return label
    }()

    private var tapViewAnimatableConstraints = AnimationConstraints()
    private var tableViewAnimatableConstraints = AnimationConstraints()

    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskDetailTextView: UITextView!
    @IBOutlet weak var completionButton: UIButton!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var hoursButton: UIButton!
    @IBOutlet weak var titleNavItem: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = true
        viewModel = ViewModel(mode: mode)

        setUpNavigationTitle()
        setUpPlaceholder()
        setUpShuffleView()
        setUpTapView()
        setUpHoursTable()

        taskDetailTextView.delegate = self
        taskTitleTextField.delegate = self

        styleTextView(selected: false)

        bindUiToViewModel()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    @IBAction func completionButtonTapped(_ sender: Any) {
        let updatedTask = viewModel.getTask()
        onComplete?(updatedTask)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func hoursButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        sender.isEnabled = false
        viewModel.willUpdateHours()
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
            .subscribeNext { [weak self] index in
                if index == 0 {
                    self?.hoursLabel.text = "--.- hrs"
                    self?.hoursLabel.textColor = .red
                } else {
                    let hrs = index == 2 ? " hr" : " hrs"
                    self?.hoursLabel.text = (self?.viewModel.title(for: index) ?? "") + hrs
                    self?.hoursLabel.textColor = .ocean
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

        viewModel.hoursSelectionStatus
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] status in
                switch status {
                case .editing: self?.revealTableViewEditing()
                case .none: self?.hideTableViewEditing()
                }
        }.disposed(by: disposeBag)

        viewModel.taskState
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] state in
                self?.stateLabel.text = state
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

    private func setUpNavigationTitle() {
        switch mode! {
        case .create: titleNavItem.title = "Add Task"
        case .update(_): titleNavItem.title = "Update Task"
        }
    }

    private func setUpPlaceholder() {
        taskDetailTextView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: taskDetailTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: taskDetailTextView.leadingAnchor, constant: 4)
            ])
    }

    private func setUpTapView() {
        view.addSubview(tapView)

        let width = tapView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CGFloat.leastNormalMagnitude)
        let height = tapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CGFloat.leastNormalMagnitude)
        tapViewAnimatableConstraints.constraints[.width] = width
        tapViewAnimatableConstraints.constraints[.height] = height

        NSLayoutConstraint.activate([
            width,
            height,
            tapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }

    private func setUpHoursTable() {
        view.addSubview(hoursTableView)

        let top = hoursTableView.topAnchor.constraint(equalTo: hoursButton.topAnchor)
        let bottom = hoursTableView.bottomAnchor.constraint(equalTo: hoursButton.topAnchor)
        let leading = hoursTableView.leadingAnchor.constraint(equalTo: hoursButton.leadingAnchor)
        let trailing = hoursTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)


        tableViewAnimatableConstraints.constraints[.top] = top
        tableViewAnimatableConstraints.constraints[.bottom] = bottom
        tableViewAnimatableConstraints.constraints[.leading] = leading
        tableViewAnimatableConstraints.constraints[.trailing] = trailing

        NSLayoutConstraint.activate([
            top,
            bottom,
            leading,
            trailing
            ])

        hoursTableView.delegate = self
        hoursTableView.dataSource = self
    }

    private func setUpShuffleView() {
        view.addSubview(shuffleView)
        view.addSubview(stateLabel)
        shuffleView.delegate = self

        NSLayoutConstraint.activate([
            shuffleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shuffleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shuffleView.topAnchor.constraint(equalTo: taskDetailTextView.bottomAnchor, constant: 16),
            shuffleView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            stateLabel.centerXAnchor.constraint(equalTo: shuffleView.centerXAnchor),
            stateLabel.topAnchor.constraint(equalTo: shuffleView.bottomAnchor, constant: -16)
            ])
    }

    private func revealTableViewEditing() {
        tapView.onTap = { [weak self] in
            self?.tapView.ignoreTaps = true
            self?.viewModel.endHoursEditing()
        }

        view.bringSubview(toFront: tapView)
        view.bringSubview(toFront: hoursTableView)

        expandTapViewConstraints()

        UIView.animate(withDuration: 0.01, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _  in
            self.expandTableViewConstraints()
            UIView.animate(withDuration: 0.3, animations: {
                self.tapView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                self.hoursTableView.alpha = 1.0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.tapView.ignoreTaps = false
                let selectedIndexPath = IndexPath(row:self.viewModel.selectedHoursRow(), section: 0)
                self.hoursTableView.scrollToRow(at: selectedIndexPath,
                                                at: .middle,
                                                animated: true)
                self.view.resignFirstResponder()
            })
        })
    }

    private func hideTableViewEditing() {
        shrinkTableViewConstraints()

        UIView.animate(withDuration: 0.3, animations: {
            self.view.bringSubview(toFront: self.hoursLabel)
            self.view.bringSubview(toFront: self.hoursButton)
            self.tapView.backgroundColor = .clear
            self.hoursTableView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.shrinkTapViewConstraints()
            self.hoursButton.isEnabled = true

            UIView.animate(withDuration: 0.01, animations: {
                self.view.layoutIfNeeded()
            })
        })
    }

    private func expandTapViewConstraints() {
        let prevWidth = tapViewAnimatableConstraints.constraints[.width]!
        let newWidth = NSLayoutConstraint.changeMultiplier(prevWidth, multiplier: 1.0)

        let prevHeight = tapViewAnimatableConstraints.constraints[.height]!
        let newHeight = NSLayoutConstraint.changeMultiplier(prevHeight, multiplier: 1.0)

        tapViewAnimatableConstraints.constraints[.width] = newWidth
        tapViewAnimatableConstraints.constraints[.height] = newHeight
    }

    private func shrinkTapViewConstraints() {
        let prevWidth = tapViewAnimatableConstraints.constraints[.width]!
        let newWidth = NSLayoutConstraint.changeMultiplier(prevWidth, multiplier: CGFloat.leastNormalMagnitude)

        let prevHeight = tapViewAnimatableConstraints.constraints[.height]!
        let newHeight = NSLayoutConstraint.changeMultiplier(prevHeight, multiplier: CGFloat.leastNormalMagnitude)

        tapViewAnimatableConstraints.constraints[.width] = newWidth
        tapViewAnimatableConstraints.constraints[.height] = newHeight
    }

    private func expandTableViewConstraints() {
        let top = tableViewAnimatableConstraints.constraints[.top]!
        let prevBottom = tableViewAnimatableConstraints.constraints[.bottom]!
        let prevLeading = tableViewAnimatableConstraints.constraints[.leading]!
        let trailing = tableViewAnimatableConstraints.constraints[.trailing]!

        top.constant = hoursButton.frame.height + 8
        trailing.constant = -1 * (hoursButton.frame.width - 8)

        let newLeading = hoursTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (hoursButton.frame.width - 8))
        let newBottom = hoursTableView.bottomAnchor.constraint(equalTo: completionButton.topAnchor, constant: -0.2 * (view.frame.height))

        tableViewAnimatableConstraints.constraints[.leading] = newLeading
        tableViewAnimatableConstraints.constraints[.bottom] = newBottom

        NSLayoutConstraint.deactivate([prevBottom, prevLeading])
        NSLayoutConstraint.activate([newLeading, newBottom])
    }

    private func shrinkTableViewConstraints() {
        let top = tableViewAnimatableConstraints.constraints[.top]!
        let prevBottom = tableViewAnimatableConstraints.constraints[.bottom]!
        let prevLeading = tableViewAnimatableConstraints.constraints[.leading]!
        let trailing = tableViewAnimatableConstraints.constraints[.trailing]!

        top.constant = 0
        trailing.constant = -8

        let newLeading = hoursTableView.leadingAnchor.constraint(equalTo: hoursButton.leadingAnchor, constant: 0)
        let newBottom = hoursTableView.bottomAnchor.constraint(equalTo: hoursButton.topAnchor)

        tableViewAnimatableConstraints.constraints[.leading] = newLeading
        tableViewAnimatableConstraints.constraints[.bottom] = newBottom

        NSLayoutConstraint.deactivate([prevBottom, prevLeading])
        NSLayoutConstraint.activate([newLeading, newBottom])
    }
}

extension TaskUpdateViewController: ShuffleViewDelegate {
    func shuffleViewWillExpand(_ shuffleView: ShuffleView) {
        view.endEditing(true)
        stateLabel.alpha = 0
    }

    func shuffleViewWillCollapse(_ shuffleView: ShuffleView) {
        let state: TaskState
        switch shuffleView.selected {
        case .left: state = .unstarted
        case .middle: state = .inProgress
        case .right: state = .finished
        }
        viewModel.stateDidChange(to: state)
        stateLabel.alpha = 1
    }
}

extension TaskUpdateViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 101
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HourSelectionCell", for: indexPath) as! HourSelectionTableViewCell

        cell.label.text = viewModel.title(for: indexPath.row)

        if indexPath.row == 0 {
            cell.setUpForNoOption()
        } else if indexPath.row != viewModel.selectedHoursRow() {
            cell.setUpForNotSelected()
        } else {
            cell.setUpForSelection()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let previouslySelectedRow = viewModel.selectedHoursRow()

        viewModel.didSelect(row: indexPath.row)

        var reloads = [indexPath]
        if indexPath.row != previouslySelectedRow {
            reloads.append(IndexPath(row: previouslySelectedRow, section: 0))
        }

        tableView.performBatchUpdates({
            tableView.reloadRows(at: reloads, with: .automatic)
        }) { [weak self] (_) in
            self?.viewModel.endHoursEditing()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension TaskUpdateViewController: UITextFieldDelegate {
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
        textField.layer.borderColor = UIColor.fog.cgColor
        textField.layer.borderWidth = 1
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.grass.cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 5
    }
}

extension TaskUpdateViewController: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        styleTextView(selected: true)

        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignTextView))

        toolbar.setItems([flexSpace, doneButton], animated: true)
        toolbar.sizeToFit()

        textView.inputAccessoryView = toolbar

        viewModel.willUpdateTextField()

        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        styleTextView(selected: false)
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.didEditDetails(details: textView.text)
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
