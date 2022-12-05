//
//  CountryListTableViewController.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/12/1401 AP.
//

import UIKit
import Combine

class CountryListTableViewController: BaseTableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    // MARK: - SubViews
    
    private var cancelBarButton: UIBarButtonItem!
    private var doneBarButton: UIBarButtonItem!
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var isDonebuttonEnableCancellabel: AnyCancellable?
    private var countryListViewModel: CountryListViewModel
    
    // MARK: - init
    
    init(viewModel: CountryListViewModel) {
        self.countryListViewModel = viewModel
        super.init(viewModel: viewModel)
        setupBarButtonItems()
        setPublishers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
        setupSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        countryListViewModel.onAppear()
    }
    
    // MARK: - TableView delegates
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryTableViewCell.reuseIdentifier) as! CountryTableViewCell
        let country = countryListViewModel.getCountryForIndex(indexPath)
        cell.setData(name: country.name.common, flag: country.flag)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countryListViewModel.numberOfRows
    }
    
    // MARK: - SearchController delegates
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        removeRefreshControl()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        addRefreshControl()
    }
    
    // MARK: - Events
    
    @objc
    private func onDoneButton() {
        guard let indexPathForSelectedRows = tableView.indexPathsForSelectedRows else { return }
        countryListViewModel.doneSelecting(with: indexPathForSelectedRows)
    }
    
    @objc
    private func onCancelButton() {
        countryListViewModel.onCancel()
    }
    
    override func loadMore() {
        countryListViewModel.onLoadMore()
    }
    
    @objc
    private func onPullToRefresh() {
        countryListViewModel.onRefresh()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            countryListViewModel.onSearch(searchText)
        }
    }
    
    // MARK: - Helper methods
    
    private func setupBarButtonItems() {
        cancelBarButton = UIBarButtonItem(title: "Cancel",
                                          style: .plain,
                                          target: self,
                                          action: #selector(onCancelButton))
        doneBarButton = UIBarButtonItem(title: "Done",
                                        style: .done,
                                        target: self,
                                        action: #selector(onDoneButton))
        
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
        
    }
    
    private func setupTableView()  {
        tableView.rowHeight = 50
        tableView.register(CountryTableViewCell.self, forCellReuseIdentifier: CountryTableViewCell.reuseIdentifier)
        tableView.allowsMultipleSelection = true
    }
    
    private func setupRefreshControl() {
        tableViewRefreshControl = UIRefreshControl()
        tableViewRefreshControl?.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        addRefreshControl()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Countries"
        searchController.searchBar.delegate = self
    }
    
    private func showSearchController() {
        navigationItem.searchController = searchController
    }
    
    private func hideSearchController() {
        navigationItem.searchController = nil
    }
    
    private func setPublishers() {
        countryListViewModel.isPresented
            .sink { isPresented in
                if !isPresented {
                    self.dismiss(animated: true)
                }
            }
            .store(in: &cancellables)
        
        isDonebuttonEnableCancellabel = countryListViewModel
            .isActionsEnablePublisher
            .receive(on: OperationQueue.main)
            .sink { isEnabled in
                self.doneBarButton.isEnabled = isEnabled
                if isEnabled {
                    self.isDonebuttonEnableCancellabel = nil
                    self.showSearchController()
                }
            }
    }
    
    private func addRefreshControl() {
        guard refreshControl != nil else {
            refreshControl = tableViewRefreshControl
            return
        }
    }
    
    private func removeRefreshControl() {
        guard refreshControl == nil else {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.refreshControl = nil
            }
            return
        }
    }
}
