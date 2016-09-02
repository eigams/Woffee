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
        self.nameLabel.text = venue.name
        self.ratingLabel.text = ""
        
        if let rating = venue.rating {
            self.ratingLabel.text = String(format: "%.1f", rating)
        }
        else {
            print("doesnt have rating: \(venue.name)")
        }
        
        self.ratingLabel.backgroundColor = UIColor(hexString: venue.ratingColor ?? "");
        self.priceLabel.text = [String](count: venue.price?.tier ?? 1, repeatedValue: venue.price?.currency ?? "€").reduce("", combine: +)
        
        self.openingHoursLabel.text = ""
        if let status = venue.hours?.status {
            self.openingHoursLabel.text = status;
        }
        else {
            self.openingHoursLabel.text = venue.hours?.isOpen ?? false ? "Open" : "";
        }
        
        self.previewImage.image = image ?? UIImage()
        
        self.distanceLabel.text = "\(venue.location?.distance ?? 0) m"
        self.streetAddress.text = venue.location?.address ?? nil;
        self.cityPostCodeAddress.text = venue.address
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    class func reusableIdentifier() -> String {
        return NSStringFromClass(self)
    }
}
