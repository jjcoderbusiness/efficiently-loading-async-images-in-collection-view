//
//  ServerConnect.swift
//  AssignmentJagdish
//
//  Created by Jagdish Jangir on 21/04/24.
//

import Foundation
import Combine


enum NetworkError: Error {
    case unkown
    case invalidURL
}

final class ServerConnect {
    
    private let endpoint = "https://acharyaprashant.org/api/v2/content/misc/media-coverages?limit=200"
    
    static let shared = ServerConnect()
    
    private init() {}
    
    private var cancellables = Set<AnyCancellable>()
    
    func getData() -> Future<[Thumbnail],  Error> {
        return Future<[Thumbnail], Error> { [weak self]  promise in
            
            guard let self = self else {
                return promise(.failure(NetworkError.unkown))
            }
            
            guard let url = URL(string: self.endpoint) else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { (data,_) in
                    return data
                }
                .decode(type: [APIResponse].self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("Finised")
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } receiveValue: { data in
                    promise(.success(data.compactMap({$0.thumbnail})))
                }.store(in: &self.cancellables)
        }
    }
    
    func downloadImageDataTask(url: String, completion: @escaping (Data?) -> ()) -> URLSessionDataTask? {
        guard let url = URL(string: url) else {
            completion(nil)
            return nil
        }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { imageData,_,_ in
            completion(imageData)
        }
        return task
    }
    
}
