//
//  VenueCell.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 2/20/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import UIKit

@objc (CSHVenueTableViewCell)
class CSHVenueTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var streetAddress: UILabel!
    @IBOutlet private weak var cityPostCodeAddress: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var openingHoursLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWithVenue(venue: CSHVenue, image: UIImage?) {
        let cellViewModel = CSHVenueCellViewModel(venue: venue, image: image)
        
        self.nameLabel.text = cellViewModel.name
        self.ratingLabel.text = ""
        
        self.ratingLabel.text = cellViewModel.rating
        
        self.ratingLabel.backgroundColor = cellViewModel.ratingColor
        self.priceLabel.text = cellViewModel.price
        
        self.openingHoursLabel.text = cellViewModel.openingHours
        
        self.previewImage.image = cellViewModel.previewImage
        
        self.distanceLabel.text = cellViewModel.distance
        self.streetAddress.text = cellViewModel.street
        self.cityPostCodeAddress.text = cellViewModel.cityPostCode
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    class func reusableIdentifier() -> String {
        return NSStringFromClass(self)
    }
}
