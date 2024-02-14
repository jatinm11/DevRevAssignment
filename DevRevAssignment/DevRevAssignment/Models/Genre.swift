//
//  Genre.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 13/02/24.
//

import Foundation

struct Genre: Codable {
    var id: Int
    var name: String
}

struct GenresContainer: Codable {
    let genres: [Genre]
}

func getGenreNamesFromFile(movie: Movie) -> [String]? {
    
    guard let path = Bundle.main.path(forResource: "GenreList", ofType: "json") else { return nil }
    
    guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) else {
        print("Failed to read JSON data from file")
        return nil
    }
    
    guard let genresContainer = try? JSONDecoder().decode(GenresContainer.self, from: jsonData) else {
        print("Failed to decode JSON data")
        return nil
    }
    
    var genreNames: [String] = []
    for genreId in movie.genreIds {
        if let genre = genresContainer.genres.first(where: { $0.id == genreId }) {
            genreNames.append(genre.name)
        }
    }
    
    return genreNames
}
