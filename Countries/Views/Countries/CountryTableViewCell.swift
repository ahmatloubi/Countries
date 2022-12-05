//
//  CountryTableViewCell.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/12/1401 AP.
//

import UIKit
import Combine

class CountryTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CountryTableViewCell"
    private var cancellables = Set<AnyCancellable>()
        
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let flagLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupViews() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50)
        ])
        
        contentView.addSubview(flagLabel)
        flagLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            flagLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            flagLabel.heightAnchor.constraint(equalToConstant: 30),
            flagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            flagLabel.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setData(name: String, flag: String) {
        nameLabel.text = name
        flagLabel.text = flag
    }
}
