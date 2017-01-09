//
//  VenueCell.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 2/20/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import UIKit

@objc (CSHVenueTableViewCell)
final class CSHVenueTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var distanceLabel: UILabel!
    @IBOutlet fileprivate weak var streetAddress: UILabel!
    @IBOutlet fileprivate weak var cityPostCodeAddress: UILabel!
    @IBOutlet fileprivate weak var priceLabel: UILabel!
    @IBOutlet fileprivate weak var ratingLabel: UILabel!
    @IBOutlet fileprivate weak var previewImage: UIImageView!
    @IBOutlet fileprivate weak var openingHoursLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var model: CSHVenueCellViewModel? {
        didSet {
            configure(model: model)
        }
    }
    
    func configure(model: CSHVenueCellViewModel?) {
        guard let cellViewModel = model else { return }
        
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
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    class func reusableIdentifier() -> String {
        return NSStringFromClass(self)
    }
}
