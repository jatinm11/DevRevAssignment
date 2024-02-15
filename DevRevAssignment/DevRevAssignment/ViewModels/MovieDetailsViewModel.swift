//
//  MovieDetailsViewModel.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 13/02/24.
//

import UIKit
import MarshmellowXC

class MovieDetailsViewModel {
    
    private let movieId: Int
    private var castList: [Cast] = []
    private var movieDetail: MovieDetail?
    
    init(movieId: Int) {
        self.movieId = movieId
    }
    
    // MARK: - Data Fetchers
    func fetchMovieDetails(completion: @escaping (Result<Void, Error>) -> Void) {
        NetworkController.shared.makeRequest(endpoint: .movieDetail, movieId: "\(movieId)") { [weak self] (result: Result<MovieDetail, MellowError>) in
            guard let self = self else { return }
            switch result {
            case .success(let movieDetails):
                self.movieDetail = movieDetails
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchCastList(completion: @escaping (Result<Void, Error>) -> Void) {
        NetworkController.shared.makeRequest(endpoint: .movieCast, movieId: "\(movieId)") { [weak self] (result: Result<CastResponse, MellowError>) in
            guard let self = self else { return }
            switch result {
            case .success(let castResponse):
                self.castList = castResponse.cast
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Movie Details
    
    var imdbId: String? {
        return movieDetail?.imdbId
    }
    
    var movieHomepage: String? {
        return movieDetail?.homepage
    }

    func backdropPath() -> String? {
        return "https://image.tmdb.org/t/p/original/\(movieDetail?.backdropPath ?? "")"
    }
    
    func movieTitle() -> String? {
        return movieDetail?.title
    }
    
    func movieGenres() -> String? {
        return movieDetail?.genresNames()
    }
    
    func releaseDate() -> String? {
        return movieDetail?.releaseDate.DRVFormat
    }

    func overview() -> String? {
        return movieDetail?.overview
    }

    func tagline() -> String? {
        return movieDetail?.tagline?.isEmpty ?? true ? "A great quote" : movieDetail?.tagline
    }

    func budget() -> String? {
        return movieDetail?.budget ?? 0 > 0 ? movieDetail?.budget.currencyString() : "N/A"
    }

    func revenue() -> String? {
        return movieDetail?.revenue ?? 0 > 0 ? movieDetail?.revenue.currencyString() : "N/A"
    }

    func rating() -> String? {
        return movieDetail?.voteAverage.roundedToOneDecimalPlace().description
    }

    func runtime() -> String? {
        return movieDetail?.runtime.runtimeString()
    }
    
    // MARK: - Cast List
    func numberOfCastMembers() -> Int {
        return castList.count
    }
    
    func cast(at index: Int) -> Cast? {
        guard index < castList.count else { return nil }
        return castList[index]
    }
    
    // MARK: - Helper Methods
    func revenueTextColor() -> UIColor {
        guard let budget = movieDetail?.budget, let revenue = movieDetail?.revenue else { return .label }
        return revenue > budget ? .systemGreen : .systemPink
    }

    func revenueIndicatorIconName() -> String? {
        guard let budget = movieDetail?.budget, let revenue = movieDetail?.revenue else { return nil }
        return revenue > budget ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
    }
    
    // MARK: - Actions
    func openIMDbPage() {
        guard let imdbId = movieDetail?.imdbId, let url = URL(string: "https://www.imdb.com/title/\(imdbId)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func openMovieWebsite() {
        guard let movieHomepage = movieDetail?.homepage, let url = URL(string: movieHomepage) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
