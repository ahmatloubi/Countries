//
//  CountriesFetchHelper.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/9/1401 AP.
//

import Foundation

enum EndPoint: String {
    case all = "/all"
}

struct CountriesFetchHelper: Networkable {
    private let server = "https://restcountries.com/v3.1"
    
    func getCountries() async throws -> [Country]  {
        guard let url = getURLOf(.all) else { throw NetworkingError.invalidURL }
        let countries = try await fetchListOf(type: Country.self, from: url)
        return countries
    }
    
    private func getURLOf(_ endPoint: EndPoint) -> URL? {
        URL(string: server + endPoint.rawValue)
    }
}
