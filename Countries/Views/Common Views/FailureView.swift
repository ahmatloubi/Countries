//
//  FailureView.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/9/1401 AP.
//

import UIKit
import Combine

class FailureView: UIView {
    // MARK: - SubViews

    private var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Failed to load items"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private var retryButtonView: UIButton = {
        let button = UIButton()
        button.addTarget(nil, action: #selector(onTapRetryButton), for: .touchUpInside)
        button.setTitle("Retry", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(.label.withAlphaComponent(0.5), for: .highlighted)
        button.layer.borderColor = UIColor.systemGray3.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        return button
    }()
    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: FailureViewModel
    
    // MARK: - init

    init(frame: CGRect = .zero, viewModel: FailureViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setUpView()
        layoutViews()
        setErrorMessagePublisher()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Events

    @objc
    private func onTapRetryButton() {
        viewModel.onRetry()
    }
    // MARK: - Helpers

    private func setUpView() {
        backgroundColor = .systemBackground
    }
    
    private func layoutViews() {
        addSubview(errorMessageLabel)
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorMessageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorMessageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorMessageLabel.widthAnchor.constraint(equalToConstant: 200),
            errorMessageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        addSubview(retryButtonView)
        retryButtonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            retryButtonView.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 10),
            retryButtonView.centerXAnchor.constraint(equalTo: errorMessageLabel.centerXAnchor),
            retryButtonView.widthAnchor.constraint(equalToConstant: 100),
            retryButtonView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setErrorMessagePublisher() {
        viewModel
            .errorMessagePublisher
            .sink(receiveValue: { newMessage in
                self.errorMessageLabel.text = newMessage
            })
            .store(in: &cancellables)
    }
}
