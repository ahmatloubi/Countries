//
//  Country.swift
//  Countries
//
//  Created by AmirHossein Matloubi on 9/9/1401 AP.
//

import Foundation

struct Country: Codable {
    let name: Name
    let capital: [String]?
    let region: String
    let flag: String
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(Name.self, forKey: .name)
        self.region = try container.decode(String.self, forKey: .region)
        self.flag = try container.decode(String.self, forKey: .flag)
        self.capital = try container.decodeIfPresent([String].self, forKey: .capital)
    }
}
