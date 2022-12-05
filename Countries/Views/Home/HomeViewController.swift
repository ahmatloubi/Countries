//
//  HomeViewController.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/9/1401 AP.
//

import UIKit
import Combine

class HomeViewController: BaseTableViewController {
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    
    private var homeViewModel: HomeViewModel
    
    private var selectCountryButtons: UIBarButtonItem!
    
    // MARK: - init
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        super.init(viewModel: homeViewModel)
        setBarButton()
        setPublisher()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = selectCountryButtons
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        homeViewModel.onAppear()
    }
    
    // MARK: - TableView delegates
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier) as! HomeTableViewCell
        let country = homeViewModel.getCountryForIndex(indexPath)
        cell.setDeta(country: country)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        homeViewModel.numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[weak self] action, view, handler in
            self?.onDelete(indexPath)
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Events
    private func onDelete(_ indexPath: IndexPath) {
        homeViewModel.onDeleteCountryAt(index: indexPath)
    }
    
    @objc
    func onSelectCountriesButton() {
        homeViewModel.onTapSelectCountries()
    }
    
    // MARK: - Helper methods
    private func setupTableView() {
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.allowsSelection = false
    }
    
    private func setPublisher() {
        homeViewModel.isSelectCountryViewPresentPublisher
            .sink { isPresented in
                if isPresented {
                    let selectCountriesViewModel = self.homeViewModel.getSelectCountryViewModel()
                    let selectCountriesViewController = UINavigationController(
                        rootViewController: CountryListTableViewController(viewModel: selectCountriesViewModel))
                    selectCountriesViewController.modalPresentationStyle = .fullScreen
                    self.present(selectCountriesViewController, animated: true)
                }
            }
            .store(in: &cancellables)
        
        homeViewModel.deleteCountryPublisher
            .sink { indexPath in
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
            .store(in: &cancellables)
    }
    
    private func setBarButton() {
        selectCountryButtons = UIBarButtonItem(title: "Select",
                                               style: .plain,
                                               target: self,
                                               action: #selector(onSelectCountriesButton))
    }
    
}
