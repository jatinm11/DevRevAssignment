//
//  MovieListViewModel.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 13/02/24.
//

import UIKit
import Marshmellow

class MoviesListViewModel {
    
    // MARK: - Properties
    
    var movieList: [Movie] = []
    var allMovies: [String : [Movie]] = [:]
    var lastFetchedPageForEndpoint: [APIEndpoint: Int] = [:]
    
    var isFetching: Bool = false
    var totalPages: Int?
    
    // MARK: - Data fetchers
    func fetchMovieListFor(endpoint: APIEndpoint, completion: @escaping (Result<[Movie], MellowError>) -> Void) {
        
        guard !isFetching else { return }
        
        let currentPage = lastFetchedPageForEndpoint[endpoint] ?? 1
        
        NetworkController.shared.makeRequest(endpoint: endpoint, page: currentPage) { (result: Result<MovieListResponse, MellowError>) in
            switch result {
                
            case .success(let movieListResponse):
                
                if currentPage == 1 {
                    self.movieList = movieListResponse.results
                }
                else {
                    self.movieList.append(contentsOf: movieListResponse.results)
                }
                
                self.allMovies[endpoint.rawValue] = self.movieList
                self.totalPages = movieListResponse.page + 1
                self.lastFetchedPageForEndpoint[endpoint] = currentPage + 1
                
                completion(.success(self.movieList))
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
     
    // MARK: - Movie List props
    func numberOfMovies() -> Int {
        return movieList.count
    }
    
    func movie(at index: Int) -> Movie {
        return movieList[index]
    }
    
    func didSelectItemAt(indexPath: IndexPath, presentingViewController: UIViewController) {
        presentingViewController.present(MovieDetailsViewController.controller(movieId: movieList[indexPath.row].id), animated: true)
    }
    
    func didChangeSegmentTo(endPoint: APIEndpoint, completion: @escaping (Result<[Movie], MellowError>) -> Void) {
        if let moviesList = allMovies[endPoint.rawValue] {
            self.movieList = moviesList
            completion(.success(self.movieList))
        }
        else {
            lastFetchedPageForEndpoint[endPoint] = 1
            self.fetchMovieListFor(endpoint: endPoint, completion: completion)
        }
    }
    
    func loadMoreMoviesIfNeeded(endpoint: APIEndpoint, completion: @escaping (Result<[Movie], MellowError>) -> Void) {
        fetchMovieListFor(endpoint: endpoint, completion: completion)
    }
}
