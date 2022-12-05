//
//  CountryListViewModel.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/9/1401 AP.
//

import Foundation
import Combine

class CountryListViewModel: BaseTableViewControllerTableViewModel {
    typealias ViewState = BaseTableViewControllerViewState
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var page: Int = 1
    private var countryStore: [Country] = []
    private let countriesFetchHelper = CountriesFetchHelper()

    var pageSize: Int {
        20
    }
    
  
    var numberOfRows: Int {
        countries.count
    }
        
    override var noItemToShowMessage: String {
        "No country to show"
    }
    
    // MARK: - Publishers
    var isPresented: AnyPublisher<Bool, Never> {
        isPresentedSubject.eraseToAnyPublisher()
    }
    
    var selectedCountriesPublisher: AnyPublisher<[Country], Never> {
        selectedCountriesSubject.eraseToAnyPublisher()
    }
    
    var isActionsEnablePublisher: AnyPublisher<Bool, Never> {
        $isActionsEnable.eraseToAnyPublisher()
    }

    private var isPresentedSubject = PassthroughSubject<Bool, Never>()
    private var selectedCountriesSubject = PassthroughSubject<[Country], Never>()
    @Published private(set) var countries: [Country] = []
    @Published private var isActionsEnable: Bool = false
    
    // MARK: - init

    init(isPresentedPublisher: AnyPublisher<Bool, Never>) {
        super.init()
        failureViewModel = FailureViewModel(onRetry: onRetry)
        
        isPresentedPublisher
            .sink { isPresented in
                if !isPresented {
                    self.isPresentedSubject.send(false)
                }
            }
            .store(in: &cancellables)
        setPublishers()
    }
    // MARK: - Fetch

    private func load() async  {
        do {
            countryStore = try await countriesFetchHelper.getCountries()
        } catch let error as LocalizedError {
            setFailureView(message: error.localizedDescription)
        } catch {
            setFailureView(message: "Some thing bad happened during loading")
        }
    }
    
    // MARK: - Events
    func doneSelecting(with selection: [IndexPath]) {
        var selectedCountries: [Country] = []
        let indexes = selection.map { $0.row }
        for index in indexes {
            selectedCountries.append(countries[index])
        }
        selectedCountriesSubject.send(selectedCountries)
        isPresentedSubject.send(false)
    }
    
    func onAppear() {
        if viewState != .loading {
            viewState = .loading
        }
        
        Task {
            await load()
            page = 1
            countries = getCountryOf(page: page)
        }
    }
    
    func onRefresh() {
        Task {
            await load()
            page = 1
            countries = getCountryOf(page: 1)
        }
    }
    
    func onLoadMore() {
        page += 1
        countries.append(contentsOf: getCountryOf(page: page))
    }
    
    func onSearch(_ text: String) {
        if text.isEmpty {
            page = 1
            countries = getCountryOf(page: 1)
        } else {
            countries = countryStore.filter({$0.name.common.lowercased().contains(text.lowercased())})
        }
    }
    
    func onRetry() {
        onAppear()
    }
    
    func onCancel() {
        self.isPresentedSubject.send(false)
    }
    // MARK: - Helpers
    
    private func setFailureView(message: String) {
        viewState = .failure
        failureViewModel?.setErrorMessage(message: message)
    }
    
    private func setPublishers() {
        $countries
            .dropFirst(1)
            .map({ $0.isEmpty })
            .map({ $0 ? ViewState.noItem : ViewState.content })
            .sink { newState in
                self.viewState = newState
                self.shouldReloadTableViewSubject.send(true)
            }
            .store(in: &cancellables)
        
        $countries
            .combineLatest($viewState)
            .map({ coutries, viewState in
                return !coutries.isEmpty && viewState == .content
            })
            .assign(to: \.isActionsEnable, on: self)
            .store(in: &cancellables)
    }
    
    private func getCountryOf(page: Int) -> [Country] {
        let startIndex = (page - 1) * pageSize
        let endIndex = page * pageSize
        guard startIndex >= 0, endIndex >= 0, countryStore.count > startIndex else { return [] }
        
        var arraySlice: ArraySlice<Country>
        if endIndex >= countryStore.count  {
            arraySlice = countryStore[startIndex...]
        } else {
            arraySlice = countryStore[startIndex..<endIndex]
        }
        return Array(arraySlice)
    }
    
    
    func getCountryForIndex(_ index: IndexPath) -> Country {
        countries[index.row]
    }
}
