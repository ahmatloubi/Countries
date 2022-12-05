//
//  HomeViewModel.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/12/1401 AP.
//

import Foundation
import Combine

class HomeViewModel: BaseTableViewControllerTableViewModel {
    typealias ViewState = BaseTableViewControllerViewState
    
    enum CacheKey: String {
        case countries
    }
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var page: Int = 1
    private var countryListViewModel: CountryListViewModel?
    let cacheHelper = CacheHelper()
    var cachedCountries: [Country] = []
    
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

    var isSelectCountryViewPresentPublisher: AnyPublisher<Bool, Never> {
        isSelectCountryViewPresenetedSubject.eraseToAnyPublisher()
    }
    
    var deleteCountryPublisher: AnyPublisher<IndexPath, Never> {
        deleteCountrySubject.eraseToAnyPublisher()
    }
    
    private var deleteCountrySubject = PassthroughSubject<IndexPath, Never>()
    private var isSelectCountryViewPresenetedSubject = PassthroughSubject<Bool, Never>()
    @Published var countries: [Country] = []
    
    override init() {
        super.init()
        setPublisher()
    }
    // MARK: - HandleEvents

    func onAppear() {
        cachedCountries = loadCachedData().sorted(by: {$0.name.common < $1.name.common})
        countries = getCountryOf(page: 1)
        shouldReloadTableViewSubject.send(true)
    }
    
    func onDeleteCountryAt(index: IndexPath) {
        let deletedCountry = countries.remove(at: index.row)
        cachedCountries.removeAll(where: { $0 == deletedCountry })
        shouldUpdateCountriesCache(with: cachedCountries)
        deleteCountrySubject.send(index)
        
    }
    
    func onLoadMore() {
        page += 1
        countries.append(contentsOf: getCountryOf(page: page))
        shouldReloadTableViewSubject.send(true)
    }
    
    func dissmissSelectCountriesViewController() {
        isSelectCountryViewPresenetedSubject.send(false)
    }
    
    func onTapSelectCountries() {
        isSelectCountryViewPresenetedSubject.send(true)
    }
    
    private func didSelectCountries(_ countries: [Country]) {
        let setOfCountries = Set(countries + cachedCountries)
        shouldUpdateCountriesCache(with: Array(setOfCountries))
    }
    
    
    // MARK: - Fetch
    private func loadCachedData() -> [Country] {
        do {
            guard let cachedCountries: [Country] = try cacheHelper.fetch(key: CacheKey.countries.rawValue) else {
                return [] }
            return cachedCountries
        } catch {
            viewState = .failure
            failureViewModel?.errorMessageSubject.send("")
            return []
        }
    }
    
    // MARK: - Helpers
    
    func getSelectCountryViewModel() -> CountryListViewModel {
        let countryListViewModel = CountryListViewModel(isPresentedPublisher: isSelectCountryViewPresentPublisher)
        countryListViewModel
            .selectedCountriesPublisher
            .sink { selected in
                self.dissmissSelectCountriesViewController()
                self.didSelectCountries(selected)
            }
            .store(in: &cancellables)
        return countryListViewModel
    }

    private func getCountryOf(page: Int) -> [Country] {
        let startIndex = (page - 1) * pageSize
        let endIndex = page * pageSize
        guard startIndex >= 0, endIndex >= 0, cachedCountries.count > startIndex else { return [] }
        
        var arraySlice: ArraySlice<Country>
        if endIndex >= cachedCountries.count  {
            arraySlice = cachedCountries[startIndex...]
        } else {
            arraySlice = cachedCountries[startIndex..<endIndex]
        }
        return Array(arraySlice)
    }

    func getCountryForIndex(_ index: IndexPath) -> Country {
        countries[index.row]
    }
    
    private func setPublisher()  {
        $countries
            .dropFirst(1)
            .map({ $0.isEmpty })
            .map({ $0 ? ViewState.noItem : ViewState.content })
            .sink { newState in
                self.viewState = newState
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Cache

    private func shouldUpdateCountriesCache(with countries: [Country]) {
        if countries.isEmpty {
            try? cacheHelper.delete(key: CacheKey.countries.rawValue)
        } else {
            try? cacheHelper.addOrUpdate(value: countries, key: CacheKey.countries.rawValue)
        }
    }
}
