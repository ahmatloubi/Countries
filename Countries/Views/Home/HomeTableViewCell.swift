//
//  HomeTableViewCell.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/14/1401 AP.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "HomeTableViewCell"
    
    private let countryCommonNameView: LabelWithTitleView = {
        let view = LabelWithTitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let countryOfficialNameView: LabelWithTitleView = {
        let view = LabelWithTitleView()
        view.setTitle("Official Name")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let countryCapitalView: LabelWithTitleView = {
        let view = LabelWithTitleView()
        view.setTitle("Capital")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let countryRegionView: LabelWithTitleView = {
        let view = LabelWithTitleView()
        view.setTitle("Region")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .secondarySystemBackground
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 6, left: 3, bottom: 6, right: 3)
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupStackView()
    }
    
    private func setupView() {
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(countryCommonNameView)
        stackView.addArrangedSubview(countryOfficialNameView)
        stackView.addArrangedSubview(countryRegionView)
        stackView.addArrangedSubview(countryCapitalView)
    }
    
    func setDeta(country: Country) {
        let commonName = country.name.common
        let officialName = country.name.official
        let flag = country.flag
        let region = country.region
        
        countryCommonNameView.setDetail(commonName)
        countryCommonNameView.setTitle(flag)
        countryOfficialNameView.setDetail(officialName)
        countryRegionView.setDetail(region)
        
        if let capitals = country.capital {
           let capitalsString = capitals.joined(separator: ", ")
            countryCapitalView.setDetail(capitalsString)
        } else {
            stackView.removeArrangedSubview(countryCapitalView)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
