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

    fileprivate var locationManager: CSLocationManager!

    fileprivate var venues: NSMutableOrderedSet?
    fileprivate var venuesImage: [String: Data]!
    fileprivate var location: CLLocation?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchingMessageLabel: UILabel!
    @IBOutlet weak var pulsatingButton: CSPulsatingButton!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var progressBar: M13ProgressViewSegmentedBar!
    @IBOutlet weak var yPosProgressBarConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableViewAnimation: CSTableViewAnimation!
    @IBOutlet fileprivate weak var dataController: ShopsListDataController!
    
    var tableViewController: UITableViewController!
    var refreshControl: UIRefreshControl = UIRefreshControl()
    fileprivate var selectedCellIndexPath: IndexPath?
    fileprivate var previouslySelectedCellIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        
        progressBar.configure()
        
        // Do any additional setup after loading the view.
        refreshControl.setupInTableView(tableView, viewController: self, selector: #selector(self.searchNearByWirelessEnabledVenues))
        searchNearByWirelessEnabledVenues()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let shopsMapViewController = segue.destination as? ShopsMapViewController, segue.identifier == "PushSegue" else { return }

        shopsMapViewController.annotations = self.dataController.annotations
        shopsMapViewController.location = self.location
    }
    
    @objc private func searchNearByWirelessEnabledVenues() {
        locationManager = CSLocationManager()
        
        locationManager.start { [unowned self] (location, error) -> Void in
            if let error = error, error.code > 0 { return }
            guard let location = location else { return }
            
            self.location = location
        
            let venuesManager = VenuesManager(location: location)
            venuesManager.delegate = self
            venuesManager.lookForVenuesWithWIFI()
        }
    }
    
    fileprivate let ExpandedTableViewCellSize:CGFloat = 300
    fileprivate let NormalTableViewCellSize:CGFloat = 110
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selected = selectedCellIndexPath, selected == indexPath, previouslySelectedCellIndexPath != selectedCellIndexPath {
            return ExpandedTableViewCellSize
        }
        
        return NormalTableViewCellSize
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellIndexPath = indexPath
        
        tableView.reloadRows(at: [indexPath], with: .none)
        previouslySelectedCellIndexPath = selectedCellIndexPath != previouslySelectedCellIndexPath ? selectedCellIndexPath : nil
    }
}

//MARK: - VenuesManager delegates
extension ShopsListViewController: VenuesManagerDelegate {
    func didStartLookingForVenues() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.pulsatingButton.liftAnimation(view: view)
    }
    
    func didFinishLookingForVenues() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let date = Date().stringWithDateFormat("MMM d, h:mm a")
        let title = "Last update: \(date)"
        
        let attrsDictionary = [NSForegroundColorAttributeName: UIColor.white]
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
        
        self.progressBar.isHidden = true
        self.pulsatingButton.dropAnimation(view: view) {
            $0?.animate()
        }

        tableView.reloadData()
        
        refreshControl.attributedTitle = attributedTitle;
        refreshControl.endRefreshing()
    }
    
    func didFailToFindVenueWithError(_ error: NSError!) {
        print("ERROR: \(error)")
    }

    func didFindPhotoForWirelessVenue(_ venue: CSHVenue) {
        dataController.imageForVenue(venue) { index in
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.fade)
        }
    }

    func didFindWirelessVenue(_ venue: CSHVenue?) {
        guard let venue = venue else { return }
        
        dataController.addVenue(venue) { index in
            self.searchingMessageLabel.isHidden = true            
            self.progressBar.animateInView(self.view, completion: nil)
            
            self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.fade)
        }
    }
}

//MARK: - CSPulsatingButtonDelegate
extension ShopsListViewController: CSPulsatingButtonDelegate {
    func didPressPulsatingButton(_ sender: UIButton!) {
        
    }
}
