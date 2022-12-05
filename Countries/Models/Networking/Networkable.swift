//
//  NetworkHelper.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/9/1401 AP.
//

import Foundation
import Alamofire

enum NetworkingError: Error {
    case invalidURL
}

protocol Networkable { }

extension Networkable {
    func fetchListOf<Output: Codable>(type: Output.Type, from url: URL) async throws -> [Output] {
        let dataRequest = getDataRequest(url: url)
        let response = try await getDataResponseOf(type: [Output].self, dataRequest: dataRequest)
        return response
    }
    
    func getDataRequest(url: URL) -> DataRequest {
        return AF.request(url).validate()
    }
    
    func getDataResponseOf<Output: Codable>(type: Output.Type, dataRequest: DataRequest) async throws -> Output {
        let dataTask = dataRequest.serializingDecodable(Output.self)
        let response = await dataTask.response
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
