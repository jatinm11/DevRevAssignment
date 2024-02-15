//
//  NetworkController.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 13/02/24.
//

import Foundation
import MarshmellowXC

class NetworkController {
    
    static let shared = NetworkController()

    private let baseURL = "api.themoviedb.org"
    private let baseImageURL = "https://image.tmdb.org/t/p/original/"
    
    private let method = MellowHttpMethod.get
    private let scheme = "https"
    private let headers: [String: String]
    
    // Bearer not hidden for the sake of simplicity.
    private init() {
        headers = [
            "accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2NGIyMzI4MGUwM2YwZTZkYWY0Y2UzMGFiNWU1ZWVkMCIsInN1YiI6IjY1YzUxNDBmMWM2YWE3MDE4MDk5Mjg3OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.KVIdTJVHdCH43vocSzXmG7p7wDluTRABTRsKC9ZYXf0"
        ]
    }
    
    func makeRequest<T: Codable>(endpoint: APIEndpoint, page: Int? = nil, movieId: String? = nil, completion: @escaping (Result<T, MellowError>) -> Void) {
        
        let requestEndpoint = movieId != nil ? endpoint.endPointWith(movieId: movieId!) : endpoint.rawValue
        
        let builder = MellowRequestBuilder(
            baseURL: URL(string: baseURL)!,
            path: requestEndpoint,
            method: method,
            scheme: scheme,
            headers: headers
        )
        
        if let page = page {
            builder.set(parameters: .url(["page": "\(page)"]))
        }
        
        Marshmellow().makeRequest(with: builder, type: T.self, completion: completion)
    }
    
    func posterImageURL(for movie: Movie) -> String {
        return "\(baseImageURL)\(movie.posterPath)"
    }
    
    func castImageURL(for cast: Cast) -> String {
        return "\(baseImageURL)\(cast.profilePath ?? "")"
    }
}

enum APIEndpoint: String {
    case popular = "/3/movie/popular"
    case topRated = "/3/movie/top_rated"
    case movieDetail
    case movieCast
    
    func endPointWith(movieId: String) -> String {
        switch self {
        case .popular, .topRated:
            return self.rawValue
        case .movieDetail:
            return "/3/movie/\(movieId)"
        case .movieCast:
            return "/3/movie/\(movieId)/credits"
        }
    }
}
