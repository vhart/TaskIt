//
//  HistoryCollectionViewCell.swift
//  TaskIt
//
//  Created by C4Q on 5/7/18.
//  Copyright © 2018 vhart. All rights reserved.
//

import UIKit

class HistoryCollectionViewCell: UICollectionViewCell {
    
    var viewModel: ViewModel? {
        didSet {
            configureSubviews()
        }
    }
    
    lazy var projectNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontName: .avenirNextMedium, size: 20)
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var gradient: GradientView = {
        let view = GradientView()
        view.gradientLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        view.gradientLayer?.colors = CGColor.greens
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var statsView: StatsView = {
        let view = StatsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.white
        setupViews()
    }
    
    private func setupViews() {
        setupProjectNameLabel()
        setupGradient()
        setupStatsView()
    }
    
    private func setupProjectNameLabel() {
        addSubview(projectNameLabel)
        NSLayoutConstraint.activate([
            projectNameLabel.topAnchor.constraint(equalTo: topAnchor),
            projectNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            projectNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            projectNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }
    
    private func setupGradient() {
        addSubview(gradient)
        NSLayoutConstraint.activate([
            gradient.topAnchor.constraint(equalTo: projectNameLabel.bottomAnchor),
            gradient.widthAnchor.constraint(equalTo: widthAnchor),
            gradient.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.005),
            gradient.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }
    
    private func setupStatsView() {
        addSubview(statsView)
        NSLayoutConstraint.activate([
            statsView.topAnchor.constraint(equalTo: gradient.bottomAnchor),
            statsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            statsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            statsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            statsView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }
    
    private func configureSubviews() {
        projectNameLabel.text = viewModel?.title
        statsView.viewModel = viewModel?.getStatsViewModel()
    }
}

extension HistoryCollectionViewCell {
    class ViewModel {
        let title: String
        let weeksCount: Int
        let tasksCount: Int
        let totalMinutes: Int
        
        init(title: String, weeksCount: Int, tasksCount: Int, totalMinutes: Int) {
            self.title = title
            self.weeksCount = weeksCount
            self.tasksCount = tasksCount
            self.totalMinutes = totalMinutes
        }
        
        func getStatsViewModel() -> StatsView.ViewModel {
            let viewModel = StatsView.ViewModel(numberOfSprints: weeksCount,
                                                numberOfTasks: tasksCount,
                                                numberOfMinutes: totalMinutes)
            return viewModel
        }
    }
}
