//
//  ViewModel.swift
//  MechtaTask
//
//  Created by Lazzat Seiilova on 10.03.2022.
//

import Foundation
import UIKit

class ViewModel: ViewModelProtocol {
    
    func fetchRockets(completion: @escaping (Result<Rocket, NetworkError>) -> Void) {
        let urlString = "https://api.spacexdata.com/v4/rockets"
//        let urlString = "ooo"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                completion(.failure(.transportError(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               !(200...299).contains(response.statusCode) {
                completion(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let rockets = try JSONSerialization.jsonObject(with: data,
                                                               options: []) as? [Any]
                guard let rockets = rockets else { return }
                
                for rocket in rockets {
                    guard let rocket = rocket as? [String:Any] else { return }
                    
                    let rocketName = self?.parse(rocket, into: .name)
                    let rocketCountry = self?.parse(rocket, into: .country)
                    let rocketImages = self?.parse(rocket, into: .flickr_images)
                    let rocketDescription = self?.parse(rocket, into: .description)
                    let rocketWikipedia = self?.parse(rocket, into: .wikipedia)
                    
                    let spaceXRocket = Rocket(name: rocketName as? String ?? "Unknown name",
                                              country: rocketCountry as? String ?? "Unknown country",
                                              flickr_images: rocketImages as? [String] ?? ["No images"],
                                              description: rocketDescription as? String ?? "No description",
                                              wikipedia: rocketWikipedia as? String ?? "No wikipedia info")
                    
                    completion(.success(spaceXRocket))
                }
            }
            catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    private func parse(_ rocketDict: [String:Any], into rocketParameters: RocketParameters) -> Any? {
        
        for (key, _) in rocketDict {
            if key == rocketParameters.rawValue {
                return rocketDict[key]
            }
        }
        
        return "Unknown"
    }
    
    func showMessage(for networkError: NetworkError) {
        switch networkError {
        case .transportError(let error):
            print("transport error \(error.localizedDescription)")
        case .serverError(let statusCode):
            print("server error \(statusCode)")
        case .noData:
            print("no data")
        case .decodingError(let error):
            print("decoding error \(error.localizedDescription)")
        }
    }
    
}

protocol ViewModelProtocol: AnyObject {
    func fetchRockets(completion: @escaping (Result<Rocket, NetworkError>) -> Void)
    func showMessage(for networkError: NetworkError)
}

enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
}
