//
//  ShopsListViewController.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/24/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
import MapKit

class ShopsListViewController: UIViewController, UITableViewDelegate {

    private var locationManager: CSLocationManager!

    private var venues: NSMutableOrderedSet?
    private var venuesImage: [String: NSData]!
    private var location: CLLocation?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchingMessageLabel: UILabel!
    @IBOutlet weak var pulsatingButton: CSPulsatingButton!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var progressBar: M13ProgressViewSegmentedBar!
    @IBOutlet weak var yPosProgressBarConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableViewAnimation: CSTableViewAnimation!
    @IBOutlet private weak var dataController: ShopsListDataController!
    
    var tableViewController: UITableViewController!
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var selectedCellIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        
        progressBar.configure()
        
        // Do any additional setup after loading the view.
        refreshControl.setupInTableView(tableView, viewController: self, selector: #selector(self.searchNearByWirelessEnabledVenues))
        searchNearByWirelessEnabledVenues()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let shopsMapViewController = segue.destinationViewController as? ShopsMapViewController where segue.identifier == "PushSegue" else { return }

        shopsMapViewController.annotations = self.dataController.annotations
        shopsMapViewController.location = self.location
    }
    
    func searchNearByWirelessEnabledVenues() {
        self.locationManager = CSLocationManager()
        
        self.locationManager.start { [unowned self] (location, error) -> Void in
            if let error = error where error.code > 0 { return }
            guard let location = location else { return }
            
            self.location = location
        
            let venuesManager = VenuesManager(location: location)
            venuesManager.delegate = self
            venuesManager.lookForVenuesWithWIFI()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let selected = selectedCellIndexPath where selected == indexPath {
            return 300
        }
        
        return 110
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCellIndexPath = indexPath
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
}

//MARK: - VenuesManager delegates
extension ShopsListViewController: VenuesManagerDelegate {
    func didStartLookingForVenues() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.pulsatingButton.liftAnimationInView(self.view)
    }
    
    func didFinishLookingForVenues() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        let date = NSDate().stringWithDateFormat("MMM d, h:mm a")
        let title = "Last update: \(date)"
        
        let attrsDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
        
        self.progressBar.hidden = true
        self.pulsatingButton.dropAnimationInView(self.view) {
            $0?.animate()
        }

        tableView.reloadData()
        
        refreshControl.attributedTitle = attributedTitle;
        refreshControl.endRefreshing()
    }
    
    func didFailToFindVenueWithError(error: NSError!) {
        print("ERROR: \(error)")
    }

    func didFindPhotoForWirelessVenue(venue: CSHVenue) {
        dataController.imageForVenue(venue) { index in
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }

    func didFindWirelessVenue(venue: CSHVenue?) {
        guard let venue = venue else { return }
        
        dataController.addVenue(venue) { index in
            self.searchingMessageLabel.hidden = true            
            self.progressBar.animateInView(self.view, completion: nil)
            
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
}

//MARK: - CSPulsatingButtonDelegate
extension ShopsListViewController: CSPulsatingButtonDelegate {
    func didPressPulsatingButton(sender: UIButton!) {
        
    }
}
