//
//  VenueCell.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 2/20/16.
//  Copyright © 2016 Stefan Burettea. All rights reserved.
//

import UIKit

@objc (VenueTableViewCell) 
class VenueTableViewCell: UITableViewCell {
    
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
    
    func configureForVenue(venue: Venue) {

        self.nameLabel.text = venue.name
        self.ratingLabel.text = ""
        
        if let rating = venue.rating {
            self.ratingLabel.text = String(format: "%.1f", rating.floatValue)
        }
        else {
            print("doesnt have rating: \(venue.name)")
        }
        
        self.ratingLabel.backgroundColor = UIColor.grayColor()
        if let ratingColor = venue.ratingColor {
            self.ratingLabel.backgroundColor = UIColor(hexString:ratingColor);
        }
        else {
            print("doesnt have rating color: \(venue.name)")
        }
        
        var price = ""
        if let p = venue.price,
           let tier = p.tier {
                for var i = 0; i < tier.integerValue; ++i {
                    price += venue.price.currency
                }
        }
        
        self.priceLabel.text = price
        
        self.openingHoursLabel.text = ""
        if let status = venue.hours?.status {
            self.openingHoursLabel.text = status;
        }
        else {
            if let isOpen = venue.hours?.isOpen {
                self.openingHoursLabel.text = isOpen.boolValue ? "Open" : "";
            }
        }
        
        self.previewImage.image = UIImage()
//        if let photo = venue.photo {
//            if let imageData = self.venuesImage[venue.identifier] {
//                self.previewImage.image = UIImage(data: imageData)
//            }
//            else {
//                print("doesnt have image: \(venue.name) but does have a photo: \(venue.photo)")
//            }
//        }
//        else {
//            print("doesnt have photo: \(venue.name)")
//        }
        
        self.distanceLabel.text = String(format:"%.0fm", venue.location.distance.floatValue)
        if let location = venue.location {
            self.streetAddress.text = location.address;
            self.cityPostCodeAddress.text = venue.address()
        }
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    class func reusableIdentifier() -> String {
        return NSStringFromClass(self)
    }
}
