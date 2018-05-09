//
//  HistoryView.swift
//  TaskIt
//
//  Created by C4Q on 5/7/18.
//  Copyright © 2018 vhart. All rights reserved.
//

import UIKit

class ProjectHistoryView: UIView {
    
    let cell = "Project History Cell"
    
    lazy var historyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.black
        collectionView.register(HistoryCollectionViewCell.self, forCellWithReuseIdentifier: cell)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
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
        setupHistoryCollectionView()
    }
    
    private func setupHistoryCollectionView() {
        addSubview(historyCollectionView)
        NSLayoutConstraint.activate([
            historyCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            historyCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            historyCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            historyCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            historyCollectionView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }
}

