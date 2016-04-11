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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        
        self.progressBar.configure()
        
        // Do any additional setup after loading the view.
        self.setUpRefreshControl()
        self.searchNearByWirelessEnabledVenues()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "PushSegue",
              let shopsMapViewController = segue.destinationViewController as? ShopsMapViewController else { return }

        shopsMapViewController.annotations = self.dataController.annotations()
        shopsMapViewController.location = self.location
    }
    
    func searchNearByWirelessEnabledVenues() {
        self.locationManager = CSLocationManager()
        
        self.locationManager.start { [unowned self] (location, error) -> Void in
            if let error = error where error.code > 0 {
                return
            }
            
            guard let location = location else { return }
            self.location = location
            
            let venuesManager = VenuesManager(location: location)
            venuesManager.delegate = self
            venuesManager.lookForVenuesWithWIFI()
        }
    }

    func reloadData() {
        self.searchNearByWirelessEnabledVenues()
    }
    
    func setUpRefreshControl() {
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.backgroundColor = UIColor.clearColor()
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "reloadData", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.insertSubview(self.refreshControl, atIndex: 0)
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
        self.pulsatingButton.dropAnimationInView(self.view) { (pulsatingButton) in
            pulsatingButton?.animate()
        }
        //        self.animateDropPulsatingButton({ () -> (Void) in
        //            self.pulsatingButton.addPulsatingEffect()
        //        })
        
        self.refreshControl.attributedTitle = attributedTitle;
        self.refreshControl.endRefreshing()
    }
    
    func didFailToFindVenueWithError(error: NSError!) {
        print("ERROR: \(error)")
    }
    
    func didFindWirelessVenuesGroup() {
        self.dataController.sortVenuesByDistance()
        
        guard !self.searchingMessageLabel.hidden else {
            self.tableViewAnimation.play()
            return
        }
        
        self.searchingMessageLabel.hidden = true
        self.progressBar.animateInView(self.view) {
            self.tableViewAnimation.play()
        }
        
        self.pulsatingButton.dropAnimationInView(self.view) { (pulsatingButton) in
            self.pulsatingButton.animate()
        }
    }
    
    func didFindWirelessVenue(venue: Venue?) {
        guard let venue = venue else { return }
        
        self.dataController.addVenue(venue) { (index) in
            guard index >= 0 else { return }
            
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
}

//MARK: - CSPulsatingButtonDelegate
extension ShopsListViewController: CSPulsatingButtonDelegate {
    func didPressPulsatingButton(sender: UIButton!) {
        
    }
}
