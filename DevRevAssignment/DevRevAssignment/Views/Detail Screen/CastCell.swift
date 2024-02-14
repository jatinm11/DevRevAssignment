//
//  CastCell.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 09/02/24.
//

import UIKit

class CastCell: UICollectionViewCell {
    
    @IBOutlet weak var castImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let networkController = NetworkController.shared
    
    func configureCellWith(castItem: Cast?) {
        guard let castItem = castItem else { return }
        self.nameLabel.text = castItem.name
        self.castImageView.fetchImageFromURL(urlString: networkController.castImageURL(for: castItem))
    }
}
