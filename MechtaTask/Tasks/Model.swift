//
//  Model.swift
//  MechtaTask
//
//  Created by Lazzat Seiilova on 10.03.2022.
//

import Foundation

struct Rocket: Codable {
    var name: String
    var country: String
    var flickr_images: [String]
    var description: String
    var wikipedia: String
}

enum RocketParameters: String {
    case name, country, flickr_images, description, wikipedia
}
