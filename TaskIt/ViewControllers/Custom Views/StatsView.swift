//
//  ProjectCompletionStatsView.swift
//  TaskIt
//
//  Created by C4Q on 4/30/18.
//  Copyright © 2018 vhart. All rights reserved.
//

import UIKit

class StatsView: UIView {
    
    var viewModel: ViewModel? {
        didSet {
            setStatsLabels()
        }
    }
    
    private let oneThird: CGFloat = 1/3
    
    private let imageViewMultiplier: CGFloat = 0.4
    
    lazy var leftView: UIView = {
        let view = UIView()
//        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var middleView: UIView = {
        let view = UIView()
//        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var rightView: UIView = {
        let view = UIView()
//        view.backgroundColor = .green
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var leftContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var middleContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var rightContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var leftImageView: UIImageView = {
        let photo = UIImageView()
        photo.image = #imageLiteral(resourceName: "calendar")
        photo.contentMode = .scaleAspectFit
        photo.layer.masksToBounds = true
        photo.translatesAutoresizingMaskIntoConstraints = false
        return photo
    }()
    
    lazy var middleImageView: UIImageView = {
        let photo = UIImageView()
        let image = #imageLiteral(resourceName: "finished-check").withRenderingMode(.alwaysTemplate)
        photo.image = image
        photo.tintColor = .white
        photo.contentMode = .center
        photo.backgroundColor = .spring
        photo.layer.masksToBounds = true
        photo.translatesAutoresizingMaskIntoConstraints = false
        return photo
    }()
    
    lazy var rightImageView: UIImageView = {
        let photo = UIImageView()
        photo.image = #imageLiteral(resourceName: "time")
        photo.contentMode = .scaleAspectFit
        photo.layer.masksToBounds = true
        photo.translatesAutoresizingMaskIntoConstraints = false
        return photo
    }()
    
    lazy var leftNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var middleNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var rightNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var leftTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Weeks"
        label.textColor = .gray
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var middleTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Tasks"
        label.textColor = .gray
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var rightTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Hours"
        label.textColor = .gray
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .white
        setupViews()
    }
    
    override func layoutSubviews() {
        let radius = (frame.width / 3) * imageViewMultiplier * 0.5
        middleImageView.layer.cornerRadius = radius
    }
    
    private func setupViews() {
        setupLeftView()
        setupLeftContainer()
        setupLeftImage()
        setupLeftNumberLabel()
        setupLeftTextLabel()
        setupMiddleView()
        setupMiddleContainer()
        setupMiddleImage()
        setupMiddleNumberLabel()
        setupMiddleTextLabel()
        setupRightView()
        setupRightContainer()
        setupRightImage()
        setupRightNumberLabel()
        setupRightTextLabel()
    }
    
    private func setupLeftView() {
        addSubview(leftView)
        NSLayoutConstraint.activate([
            leftView.topAnchor.constraint(equalTo: topAnchor),
            leftView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: oneThird),
            leftView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func setupLeftContainer() {
        leftView.addSubview(leftContainerView)
        NSLayoutConstraint.activate([
            leftContainerView.centerXAnchor.constraint(equalTo: leftView.centerXAnchor),
            leftContainerView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor)
            ])
    }
    
    private func setupLeftImage() {
        leftContainerView.addSubview(leftImageView)
        NSLayoutConstraint.activate([
            leftImageView.topAnchor.constraint(equalTo: leftContainerView.topAnchor),
            leftImageView.leadingAnchor.constraint(greaterThanOrEqualTo: leftContainerView.leadingAnchor),
            leftImageView.trailingAnchor.constraint(lessThanOrEqualTo: leftContainerView.trailingAnchor),
            leftImageView.widthAnchor.constraint(equalTo: leftView.widthAnchor, multiplier: imageViewMultiplier),
            leftImageView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor, multiplier: 1),
            leftImageView.centerXAnchor.constraint(equalTo: leftContainerView.centerXAnchor)
            ])
    }
    
    private func setupLeftNumberLabel() {
        leftContainerView.addSubview(leftNumberLabel)
        NSLayoutConstraint.activate([
            leftNumberLabel.topAnchor.constraint(equalTo: leftImageView.bottomAnchor, constant: 10),
            leftNumberLabel.leadingAnchor.constraint(equalTo: leftContainerView.leadingAnchor),
            leftNumberLabel.trailingAnchor.constraint(equalTo: leftContainerView.trailingAnchor),
            ])
    }
    
    private func setupLeftTextLabel() {
        leftContainerView.addSubview(leftTextLabel)
        NSLayoutConstraint.activate([
            leftTextLabel.topAnchor.constraint(equalTo: leftNumberLabel.bottomAnchor, constant: 10),
            leftTextLabel.leadingAnchor.constraint(equalTo: leftContainerView.leadingAnchor),
            leftTextLabel.trailingAnchor.constraint(equalTo: leftContainerView.trailingAnchor),
            leftTextLabel.bottomAnchor.constraint(equalTo: leftContainerView.bottomAnchor),
            ])
    }
    
    private func setupMiddleView() {
        addSubview(middleView)
        NSLayoutConstraint.activate([
            middleView.topAnchor.constraint(equalTo: topAnchor),
            middleView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
            middleView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: oneThird),
            middleView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func setupMiddleContainer() {
        middleView.addSubview(middleContainerView)
        NSLayoutConstraint.activate([
            middleContainerView.centerXAnchor.constraint(equalTo: middleView.centerXAnchor),
            middleContainerView.centerYAnchor.constraint(equalTo: middleView.centerYAnchor)
            ])
    }
    
    private func setupMiddleImage() {
        middleContainerView.addSubview(middleImageView)
        NSLayoutConstraint.activate([
            middleImageView.topAnchor.constraint(equalTo: middleContainerView.topAnchor),
            middleImageView.leadingAnchor.constraint(equalTo: middleContainerView.leadingAnchor),
            middleImageView.trailingAnchor.constraint(equalTo: middleContainerView.trailingAnchor),
            middleImageView.widthAnchor.constraint(equalTo: middleView.widthAnchor, multiplier: imageViewMultiplier),
            middleImageView.heightAnchor.constraint(equalTo: middleImageView.widthAnchor, multiplier: 1),
            middleImageView.centerXAnchor.constraint(equalTo: middleContainerView.centerXAnchor)
            ])
    }
    
    private func setupMiddleNumberLabel() {
        middleContainerView.addSubview(middleNumberLabel)
        NSLayoutConstraint.activate([
            middleNumberLabel.topAnchor.constraint(equalTo: middleImageView.bottomAnchor, constant: 10),
            middleNumberLabel.leadingAnchor.constraint(equalTo: middleContainerView.leadingAnchor),
            middleNumberLabel.trailingAnchor.constraint(equalTo: middleContainerView.trailingAnchor),
            ])
    }
    
    private func setupMiddleTextLabel() {
        middleContainerView.addSubview(middleTextLabel)
        NSLayoutConstraint.activate([
            middleTextLabel.topAnchor.constraint(equalTo: middleNumberLabel.bottomAnchor, constant: 10),
            middleTextLabel.leadingAnchor.constraint(equalTo: middleContainerView.leadingAnchor),
            middleTextLabel.trailingAnchor.constraint(equalTo: middleContainerView.trailingAnchor),
            middleTextLabel.bottomAnchor.constraint(equalTo: middleContainerView.bottomAnchor),
            ])
    }
    
    private func setupRightView() {
        addSubview(rightView)
        NSLayoutConstraint.activate([
            rightView.topAnchor.constraint(equalTo: topAnchor),
            rightView.leadingAnchor.constraint(equalTo: middleView.trailingAnchor),
            rightView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: oneThird),
            rightView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func setupRightContainer() {
        rightView.addSubview(rightContainerView)
        NSLayoutConstraint.activate([
            rightContainerView.centerXAnchor.constraint(equalTo: rightView.centerXAnchor),
            rightContainerView.centerYAnchor.constraint(equalTo: rightView.centerYAnchor)
            ])
    }
    
    private func setupRightImage() {
        rightContainerView.addSubview(rightImageView)
        NSLayoutConstraint.activate([
            rightImageView.topAnchor.constraint(equalTo: rightContainerView.topAnchor),
            rightImageView.leadingAnchor.constraint(greaterThanOrEqualTo: rightContainerView.leadingAnchor),
            rightImageView.trailingAnchor.constraint(lessThanOrEqualTo: rightContainerView.trailingAnchor),
            rightImageView.widthAnchor.constraint(equalTo: rightView.widthAnchor, multiplier: imageViewMultiplier),
            rightImageView.heightAnchor.constraint(equalTo: rightImageView.widthAnchor, multiplier: 1),
            rightImageView.centerXAnchor.constraint(equalTo: rightContainerView.centerXAnchor)
            ])
    }
    
    private func setupRightNumberLabel() {
        rightContainerView.addSubview(rightNumberLabel)
        NSLayoutConstraint.activate([
            rightNumberLabel.topAnchor.constraint(equalTo: rightImageView.bottomAnchor, constant: 10),
            rightNumberLabel.leadingAnchor.constraint(equalTo: rightContainerView.leadingAnchor),
            rightNumberLabel.trailingAnchor.constraint(equalTo: rightContainerView.trailingAnchor),
            ])
    }
    
    private func setupRightTextLabel() {
        rightContainerView.addSubview(rightTextLabel)
        NSLayoutConstraint.activate([
            rightTextLabel.topAnchor.constraint(equalTo: rightNumberLabel.bottomAnchor, constant: 10),
            rightTextLabel.leadingAnchor.constraint(equalTo: rightContainerView.leadingAnchor),
            rightTextLabel.trailingAnchor.constraint(equalTo: rightContainerView.trailingAnchor),
            rightTextLabel.bottomAnchor.constraint(equalTo: rightContainerView.bottomAnchor),
            ])
    }
    
    private func setStatsLabels() {
        leftNumberLabel.text = viewModel?.numberOfSprints
        middleNumberLabel.text = viewModel?.numberOfTasks
        rightNumberLabel.text = viewModel?.numberOfHours
        
        leftTextLabel.text = viewModel?.weeksDescription
        middleTextLabel.text = viewModel?.tasksDescription
        rightTextLabel.text = viewModel?.hoursDescription
    }
}

extension StatsView {
    struct ViewModel {
        let numberOfSprints: String
        let numberOfTasks: String
        let numberOfHours: String
        let weeksDescription: String
        let tasksDescription: String
        let hoursDescription: String
        
        init(numberOfSprints: Int, numberOfTasks: Int, numberOfMinutes: Task.Minute) {
            self.numberOfSprints = "\(numberOfSprints)"
            self.numberOfTasks = "\(numberOfTasks)"
            self.numberOfHours = numberOfMinutes.asHourString
            self.weeksDescription = numberOfSprints == 1 ? "Week" : "Weeks"
            self.tasksDescription = numberOfTasks == 1 ? "Task" : "Tasks"
            self.hoursDescription = Double(numberOfMinutes) / 60 == 1 ? "Hour" : "Hours"
        }
    }
}
