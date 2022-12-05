//
//  CountryLIstTableView.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/9/1401 AP.
//

import UIKit
import Combine

enum BaseTableViewControllerViewState {
    case content, loading, failure, noItem
}

class BaseTableViewController: UITableViewController {
    // MARK: - Subviews
    private lazy var loadingView: UIView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }()
    
    private lazy var noItemToShowView: UIView = {
        let label = UILabel()
        label.text = noItemToShowMessage
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private lazy var failureView: FailureView = {
        FailureView(viewModel: viewModel.failureViewModel ?? FailureViewModel(onRetry: {}))
    }()
    
    private let backGroundView = UIView()
    
    // MARK: - Properties
    private var viewModel: BaseTableViewControllerTableViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var noItemToShowMessage: String {
        "There is no item to show"
    }
    // MARK: - init

    init(viewModel: BaseTableViewControllerTableViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessorViews()
        setPublishers()
    }
    
    // MARK: - Scrollview delegates

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset <= 10) && maximumOffset > 0  {
            loadMore()
        }
    }

    // MARK: - Events

    func loadMore() { }
    
    // MARK: - Helpers

    private func setupAccessorViews() {
        noItemToShowView.translatesAutoresizingMaskIntoConstraints = false
        backGroundView.addSubview(noItemToShowView)
        
        NSLayoutConstraint.activate([
            noItemToShowView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            noItemToShowView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            noItemToShowView.widthAnchor.constraint(equalToConstant: 250),
            noItemToShowView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        backGroundView.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: backGroundView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor)
        ])
        
        failureView.translatesAutoresizingMaskIntoConstraints = false
        backGroundView.addSubview(failureView)
        NSLayoutConstraint.activate([
            failureView.topAnchor.constraint(equalTo: backGroundView.topAnchor),
            failureView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor),
            failureView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor),
            failureView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor)
        ])
        
        tableView.backgroundView = backGroundView
        tableView.backgroundView?.layer.zPosition -= 1
    }
    
    private func setPublishers() {
        viewModel.$viewState
            .sink { viewToShow in
                DispatchQueue.main.async {
                    self.handleViewToShow(viewToShow)
                }
            }
            .store(in: &cancellables)
        viewModel.shouldReloadTableViewPublisher
            .sink { shouldReload in
                if shouldReload {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleViewToShow(_ viewToShow: BaseTableViewControllerViewState) {
        tableView.backgroundView = (viewToShow == .content) ? nil : backGroundView
        loadingView.isHidden = !(viewToShow == .loading)
        noItemToShowView.isHidden = !(viewToShow == .noItem)
        failureView.isHidden = !(viewToShow == .failure)
    }
}
