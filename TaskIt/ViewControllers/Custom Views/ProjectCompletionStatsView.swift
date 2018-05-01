//
//  ProjectCompletionStatsView.swift
//  TaskIt
//
//  Created by C4Q on 4/30/18.
//  Copyright © 2018 vhart. All rights reserved.
//

import UIKit

class StatsView: UIView {
    
    let oneThird: CGFloat = 1/3
    
    lazy var leftView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var middleView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var rightView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var leftContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var middleContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var rightContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var leftImageView: UIImageView = {
        let photo = UIImageView()
        photo.image = #imageLiteral(resourceName: "calendar")
        photo.contentMode = .scaleAspectFit
        photo.layer.masksToBounds = true
        return photo
    }()
    
    lazy var middleImageView: UIImageView = {
        let photo = UIImageView()
        photo.image = #imageLiteral(resourceName: "check")
        photo.contentMode = .scaleAspectFit
        photo.layer.cornerRadius = photo.frame.width/2
        photo.layer.borderColor = UIColor.green.cgColor
        photo.backgroundColor = .green
        photo.layer.masksToBounds = true
        return photo
    }()
    
    lazy var rightImageView: UIImageView = {
        let photo = UIImageView()
        photo.image = #imageLiteral(resourceName: "time")
        photo.contentMode = .scaleAspectFit
        photo.layer.masksToBounds = true
        return photo
    }()
    
    lazy var leftNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "12"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    lazy var middleNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "7"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    lazy var rightNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "56.5"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    lazy var leftTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Weeks"
        label.textColor = .gray
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    lazy var middleTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Tasks"
        label.textColor = .gray
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    lazy var rightTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Hours"
        label.textColor = .gray
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .white
        setupViews()
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
        leftContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftContainerView.topAnchor.constraint(equalTo: topAnchor),
            leftContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: oneThird),
            leftContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func setupLeftContainer() {
        leftView.addSubview(leftContainerView)
        leftContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftContainerView.centerXAnchor.constraint(equalTo: leftView.centerXAnchor),
            leftContainerView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor)
            ])
    }
    
    private func setupLeftImage() {
        leftContainerView.addSubview(leftImageView)
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftImageView.topAnchor.constraint(equalTo: leftContainerView.topAnchor),
            leftImageView.leadingAnchor.constraint(equalTo: leftContainerView.leadingAnchor),
            leftImageView.trailingAnchor.constraint(equalTo: leftContainerView.trailingAnchor),
            leftImageView.widthAnchor.constraint(equalTo: leftView.widthAnchor, multiplier: 0.6),
            leftImageView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor, multiplier: 1),
            leftImageView.centerXAnchor.constraint(equalTo: leftContainerView.centerXAnchor)
            ])
    }
    
    private func setupLeftNumberLabel() {
        leftContainerView.addSubview(leftNumberLabel)
        leftNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftNumberLabel.topAnchor.constraint(equalTo: leftImageView.bottomAnchor, constant: 10),
            leftNumberLabel.widthAnchor.constraint(equalTo: leftImageView.widthAnchor, multiplier: 1),
            leftNumberLabel.centerXAnchor.constraint(equalTo: leftContainerView.centerXAnchor)
            ])
    }
    
    private func setupLeftTextLabel() {
        leftContainerView.addSubview(leftTextLabel)
        leftTextLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftTextLabel.topAnchor.constraint(equalTo: leftNumberLabel.bottomAnchor, constant: 10),
            leftTextLabel.widthAnchor.constraint(equalTo: leftImageView.widthAnchor, multiplier: 1),
            leftTextLabel.bottomAnchor.constraint(equalTo: leftContainerView.bottomAnchor),
            leftTextLabel.centerXAnchor.constraint(equalTo: leftContainerView.centerXAnchor)
            ])
    }
    
    private func setupMiddleView() {
        addSubview(middleView)
        middleContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            middleContainerView.topAnchor.constraint(equalTo: topAnchor),
            middleContainerView.leadingAnchor.constraint(equalTo: leftContainerView.trailingAnchor),
            middleContainerView.trailingAnchor.constraint(equalTo: rightContainerView.leadingAnchor),
            middleContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: oneThird),
            middleContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func setupMiddleContainer() {
        middleView.addSubview(middleContainerView)
        middleContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            middleContainerView.centerXAnchor.constraint(equalTo: middleView.centerXAnchor),
            middleContainerView.centerYAnchor.constraint(equalTo: middleView.centerYAnchor)
            ])
    }
    
    private func setupMiddleImage() {
        middleContainerView.addSubview(middleImageView)
        middleImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            middleImageView.topAnchor.constraint(equalTo: middleContainerView.topAnchor),
            middleImageView.leadingAnchor.constraint(equalTo: middleContainerView.leadingAnchor),
            middleImageView.trailingAnchor.constraint(equalTo: middleContainerView.trailingAnchor),
            middleImageView.widthAnchor.constraint(equalTo: middleView.widthAnchor, multiplier: 0.6),
            middleImageView.heightAnchor.constraint(equalTo: middleImageView.widthAnchor, multiplier: 1),
            middleImageView.centerXAnchor.constraint(equalTo: middleContainerView.centerXAnchor)
            ])
    }
    
    private func setupMiddleNumberLabel() {
        middleContainerView.addSubview(middleNumberLabel)
        leftNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            middleNumberLabel.topAnchor.constraint(equalTo: middleImageView.bottomAnchor, constant: 10),
            middleNumberLabel.widthAnchor.constraint(equalTo: middleImageView.widthAnchor, multiplier: 1),
            middleNumberLabel.centerXAnchor.constraint(equalTo: middleImageView.centerXAnchor)
            ])
    }
    
    private func setupMiddleTextLabel() {
        middleContainerView.addSubview(middleTextLabel)
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            middleTextLabel.topAnchor.constraint(equalTo: middleNumberLabel.bottomAnchor, constant: 10),
            middleTextLabel.widthAnchor.constraint(equalTo: middleImageView.widthAnchor, multiplier: 1),
            middleTextLabel.bottomAnchor.constraint(equalTo: middleContainerView.bottomAnchor),
            middleTextLabel.centerXAnchor.constraint(equalTo: middleContainerView.centerXAnchor)
            ])
    }
    
    private func setupRightView() {
        addSubview(rightView)
        rightContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightContainerView.topAnchor.constraint(equalTo: topAnchor),
            rightContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: oneThird),
            rightContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func setupRightContainer() {
        rightView.addSubview(rightContainerView)
        rightContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightContainerView.centerXAnchor.constraint(equalTo: rightView.centerXAnchor),
            rightContainerView.centerYAnchor.constraint(equalTo: rightView.centerYAnchor)
            ])
    }
    
    private func setupRightImage() {
        rightContainerView.addSubview(rightImageView)
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightImageView.topAnchor.constraint(equalTo: rightContainerView.topAnchor),
            rightImageView.leadingAnchor.constraint(equalTo: rightContainerView.leadingAnchor),
            rightImageView.trailingAnchor.constraint(equalTo: rightContainerView.trailingAnchor),
            rightImageView.widthAnchor.constraint(equalTo: rightView.widthAnchor, multiplier: 0.6),
            rightImageView.heightAnchor.constraint(equalTo: rightImageView.widthAnchor, multiplier: 1),
            rightImageView.centerXAnchor.constraint(equalTo: rightContainerView.centerXAnchor)
            ])
    }
    
    private func setupRightNumberLabel() {
        rightContainerView.addSubview(rightNumberLabel)
        rightNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightNumberLabel.topAnchor.constraint(equalTo: rightImageView.bottomAnchor, constant: 10),
            rightNumberLabel.widthAnchor.constraint(equalTo: rightImageView.widthAnchor, multiplier: 1),
            rightNumberLabel.centerXAnchor.constraint(equalTo: rightContainerView.centerXAnchor)
            ])
    }
    
    private func setupRightTextLabel() {
        rightContainerView.addSubview(rightTextLabel)
        rightTextLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightTextLabel.topAnchor.constraint(equalTo: rightNumberLabel.bottomAnchor, constant: 10),
            rightTextLabel.widthAnchor.constraint(equalTo: rightImageView.widthAnchor, multiplier: 1),
            rightTextLabel.bottomAnchor.constraint(equalTo: rightContainerView.bottomAnchor),
            rightTextLabel.centerXAnchor.constraint(equalTo: rightContainerView.centerXAnchor)
            ])
    }
    
}

