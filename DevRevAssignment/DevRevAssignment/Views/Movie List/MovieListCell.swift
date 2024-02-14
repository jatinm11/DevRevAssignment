//
//  MovieListCell.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 10/02/24.
//

import UIKit

class MovieListCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    let networkController = NetworkController.shared
    
    func configureCellWith(movieItem: Movie) {
        
        self.posterImageView.fetchImageFromURL(urlString: networkController.posterImageURL(for: movieItem))
        self.movieNameLabel.text = movieItem.title
        self.ratingLabel.text = "\(movieItem.voteAverage.roundedToOneDecimalPlace())"
        
        if let genreNamesList = getGenreNamesFromFile(movie: movieItem) {
            let firstTwoGenres = Array(genreNamesList.prefix(2))
            let genreNames = firstTwoGenres.map { $0 }
            self.genreLabel.text = genreNames.joined(separator: ", ")
        }
    }
}
