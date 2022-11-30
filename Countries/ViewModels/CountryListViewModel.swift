//
//  CountryListViewModel.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/9/1401 AP.
//

import Foundation
import Combine

enum ViewState {
    case loading, loaded, failed, emptyList, none
}

class CountryListViewModel {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var countries: [Country] = []
    @Published var viewState: ViewState = .none
    
    let emptyMessage: String = "There is no country to show"
    
    private let countriesFetchHelper = CountriesFetchHelper()
    
    private func doSubscriptions() {
        $countries
            .map({ $0.isEmpty })
            .map({ $0 ? ViewState.emptyList : ViewState.loaded })
            .sink { newState in
                self.viewState = newState
            }
            .store(in: &cancellables)
    }
    
    func load() async {
        do {
            countries = try await countriesFetchHelper.getCountries()
            print(countries)
        } catch {
            viewState = .failed
        }
    }
}
