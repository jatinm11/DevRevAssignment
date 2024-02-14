//
//  Movie.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 09/02/24.
//

import Foundation

struct Movie: Codable {
    let adult: Bool
    let backdropPath: String
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let posterPath: String
    let releaseDate: String
    let title: String
    let voteAverage: Double
}

struct MovieListResponse: Codable {
    let page: Int
    let results: [Movie]
}


struct MovieDetail: Codable {
    let adult: Bool
    let budget: Int
    let genres: [Genre]
    let homepage: String
    let id: Int
    let overview: String
    let posterPath: String
    let backdropPath: String
    let releaseDate: String
    let revenue: Int
    let runtime: Int
    let title: String
    let voteAverage: Double
    let voteCount: Int
    let tagline: String?
    let imdbId: String?
    
    func genresNames() -> String {
        let genreNames = genres.map { $0.name }
        return genreNames.joined(separator: ", ")
    }
}
