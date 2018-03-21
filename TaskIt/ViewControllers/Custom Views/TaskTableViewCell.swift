//
//  TaskTableViewCell.swift
//  TaskIt
//
//  Created by Varinda Hart on 2/22/18.
//  Copyright © 2018 vhart. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var stateIndicatorViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stateIndicatorView: UIView!

    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!

    var viewModel: TaskTableViewCellViewModel? = nil {
        didSet {
            updateUI()
        }
    }

    func updateUI() {
        guard let vm = viewModel else { return }

        taskTitleLabel.text = vm.title
        taskDescriptionLabel.text = vm.description
        timeLabel.text = vm.time

        stateIndicatorView.backgroundColor = vm.indicatorColor
    }
}

enum TaskIndicatorVisibility {
    case hide
    case show
}

struct TaskTableViewCellViewModel {
    let title: String
    let description: String
    let time: String
    let indicatorColor: UIColor

    init(task: Task) {
        self.title = task.title
        self.description = task.taskDetails

        self.time = task.estimatedDuration.asHourString + " hrs"

        switch task.state {
        case .unstarted:
            self.indicatorColor = .tangerine
        case .inProgress:
            self.indicatorColor = .ocean
        case .finished:
            self.indicatorColor = .lime
        }
    }
}
