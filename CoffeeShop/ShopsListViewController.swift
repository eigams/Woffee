//
//  ShopsListViewController.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/24/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
import MapKit

class ShopsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VenuesManagerDelegate {

    private var locationManager: CSLocationManager!

    private var venues: NSMutableOrderedSet?
    private var venuesImage: [String: NSData]!
    private var location: CLLocation?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchingMessageLabel: UILabel!
    @IBOutlet weak var pulsatingButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var progressBar: M13ProgressViewSegmentedBar!
    @IBOutlet weak var yPosProgressBarConstraint: NSLayoutConstraint!
    
    var tableViewController: UITableViewController!
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        
        self.progressBar.progressDirection = M13ProgressViewSegmentedBarProgressDirectionLeftToRight
        self.progressBar.indeterminate = true
        self.progressBar.segmentShape = M13ProgressViewSegmentedBarSegmentShapeCircle
        self.progressBar.primaryColor = UIColor.whiteColor()
        self.progressBar.secondaryColor = UIColor.grayColor()
        
        // Do any additional setup after loading the view.
        self.setUpRefreshControl()
        self.searchNearByWirelessEnabledVenues()
    }

    typealias closureType = () -> (Void)
    
    private func animateProgressBar(completionBlock: closureType) {
    
        for constraint in self.progressBar.superview!.constraints() as! [NSLayoutConstraint] {
            
            if constraint.secondItem as? NSObject == self.progressBar &&
                constraint.firstAttribute == .CenterY {
                
                    self.progressBar.superview!.removeConstraint(constraint)
                    
                    let newConstraint = NSLayoutConstraint(item: self.progressBar,
                                                            attribute: .Top,
                                                            relatedBy: .Equal,
                                                            toItem: self.progressBar.superview!,
                                                            attribute: .Top,
                                                            multiplier: 1,
                                                            constant: 35)
                    
                    newConstraint.active = true
                    
                    break
            }
        }
        
        UIView.animateWithDuration(1.0,
                                    delay: 0.0,
                    usingSpringWithDamping: 1.0,
                     initialSpringVelocity: 3.0,
                                   options: .CurveEaseIn,
                                animations: {
                                    self.view.layoutIfNeeded()
                                },
                                completion: { (complete: Bool) in
                                    completionBlock()
                                    
                                    return
                                })
    }

    private func animateDropPulsatingButton(completionBlock: closureType) {
        self.animatePulsatingButton(20, completionBlock: completionBlock)
    }

    private func animateLiftPulsatingButton(completionBlock: closureType) {
        self.animatePulsatingButton(-50, completionBlock: completionBlock)
    }
    
    private func animatePulsatingButton(constantValue: CGFloat, completionBlock: closureType) {
                                        
        for constraint in self.pulsatingButton.superview!.constraints() as! [NSLayoutConstraint] {
            
            if constraint.firstItem as? NSObject == self.pulsatingButton &&
                constraint.firstAttribute == .Top {
                                            
                constraint.constant = constantValue
            
                break
            }
        }
                                        
        UIView.animateWithDuration(1.0,
                                delay: 0.0,
                                usingSpringWithDamping: 0.4,
                                initialSpringVelocity: 10.0,
                                options: .CurveEaseIn,
                                animations: {
                                            
                    self.view.layoutIfNeeded()
                },
                completion: { (complete: Bool) in
                    completionBlock()

                    return
                })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushSegue" {
            
            let shopsMapViewController = segue.destinationViewController as! ShopsMapViewController
            
            let venuesArray = self.venues?.array as! [Venue]
            let annotations = venuesArray.map {
                (venue) -> MKPointAnnotation in
                
                let annotation = MKPointAnnotation()
                annotation.title = venue.name
                annotation.subtitle = "\(venue.location.address)  @\(venue.location.distance)m"
                annotation.coordinate = CLLocationCoordinate2DMake(venue.location.lat.doubleValue, venue.location.lng.doubleValue)
                
                return annotation
            }
            
            shopsMapViewController.annotations = annotations
            shopsMapViewController.location = self.location
            
        }
    }
    
    func searchNearByWirelessEnabledVenues() {
        
        self.venues = NSMutableOrderedSet()
        self.venuesImage = [String: NSData]()
        self.locationManager = CSLocationManager()
        
        self.locationManager.start { [unowned self] (location, error) -> Void in
            
            if let err = error {
                println("ERROR: \(error!)")

                return
            }
            
            self.location = location
            
            var loc = CLLocation(latitude: 51.4636, longitude: -0.3233)
            
            let venuesManager = VenuesManager(location: location!)
            venuesManager.delegate = self
            venuesManager.venuesWithWIFI()
        }
    }
    
    private func addTopBarBlurEffect() {
        
        // create the effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        
        // create the view
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.topBarView.insertSubview(blurView, atIndex: 0)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item:blurView, attribute: .Height, relatedBy: .Equal, toItem: self.topBarView, attribute: .Height, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item:blurView, attribute: .Width, relatedBy: .Equal, toItem: self.topBarView, attribute: .Width, multiplier: 1, constant: 0))
        
        self.topBarView.addConstraints(constraints)
    }
    
    func reloadData() {
        self.searchNearByWirelessEnabledVenues()
    }
    
    private func animateTable() {
        self.tableView.reloadData()

        struct Static {
            static var token:dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token){
        
            let cells = self.tableView.visibleCells()
            let tableHeight: CGFloat = self.tableView.bounds.size.height
            
            for i in cells {
                let cell: UITableViewCell = i as! UITableViewCell
                cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
                cell.alpha = 0
            }
            
            var index = 0
            
            for a in cells {
                let cell: UITableViewCell = a as! UITableViewCell
                UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: {
                    cell.transform = CGAffineTransformMakeTranslation(0, 0);
                    cell.alpha = 1.0
                    }, completion: nil)
                
                index += 1
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - UITableView delegates
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let venues = self.venues {
            return self.venues!.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        self.configureCell(cell as! VenueCell, indexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("VenueCell", forIndexPath: indexPath) as! VenueCell
        
        return cell
    }
    
    func configureCell(cell: VenueCell, indexPath: NSIndexPath) {
        
        if let venues = self.venues {
            
            if self.venues!.count < 1 {
                return ;
            }
            
            let venueObject = self.venues![indexPath.row] as! Venue
            cell.nameLabel.text = venueObject.name
            cell.ratingLabel.text = ""
            if let rating = venueObject.rating {
                cell.ratingLabel.text = String(format: "%.1f", venueObject.rating.floatValue)
            }
            else {
                println("doesnt have rating: \(venueObject.name)")
            }

            cell.ratingLabel.backgroundColor = UIColor.grayColor()
            if let ratingColor = venueObject.ratingColor {
                cell.ratingLabel.backgroundColor = UIColor(hexString:venueObject.ratingColor);
            }
            else {
                println("doesnt have rating color: \(venueObject.name)")
            }
            
            var price = ""
            if let p = venueObject.price {
                
                if let tier = p.tier {
                
                    for var i = 0; i < venueObject.price?.tier?.integerValue; ++i {
                        price += venueObject.price.currency;
                    }
                }
            }
            
            cell.priceLabel.text = price;
            
            cell.openingHoursLabel.text = ""
            if let status = venueObject.hours?.status {
                cell.openingHoursLabel.text = venueObject.hours.status;
            }
            else {
                if let isOpen = venueObject.hours?.isOpen {
                    cell.openingHoursLabel.text = venueObject.hours.isOpen.boolValue ? "Open" : "";
                }
            }

            cell.previewImage.image = UIImage()
            if let photo = venueObject.photo {
                if let imageData = self.venuesImage[venueObject.identifier] {
                    cell.previewImage.image = UIImage(data: self.venuesImage[venueObject.identifier]!)
                }
                else {
                    println("doesnt have image: \(venueObject.name) but does have a photo: \(venueObject.photo)")
                }
            }
            else {
                println("doesnt have photo: \(venueObject.name)")
            }
            
            cell.distanceLabel.text = String(format:"%.0fm", venueObject.location.distance.floatValue)
            if let location = venueObject.location {
                cell.streetAddress.text = venueObject.location.address;
                cell.cityPostCodeAddress.text = venueObject.address()
            }
            
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        }
    }
    
    func setUpRefreshControl() {
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.backgroundColor = UIColor.clearColor()
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.addTarget(self, action: "reloadData", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.insertSubview(self.refreshControl, atIndex: 0)
    }
    
    //MARK: - VenuesManager delegates
    func didStartLookingForVenues() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.animateLiftPulsatingButton({})
    }
    
    func didFinishLookingForVenues() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        var sorted = self.venues?.array.sorted({ (venue1, venue2) -> Bool in
            return (venue1 as! Venue).location.distance.intValue < (venue2 as! Venue).location.distance.intValue
        })

        let date = NSDate().stringWithDateFormat("MMM d, h:mm a")
        let title = "Last update: \(date)"
        
        let attrsDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
        
        self.progressBar.hidden = true
        self.animateDropPulsatingButton({ () -> (Void) in
            self.pulsatingButton.addPulsatingEffect()
        })
        
        self.refreshControl.attributedTitle = attributedTitle;
        self.refreshControl.endRefreshing()
    }
    
    func didFailToFindVenueWithError(error: NSError!) {
        println("ERROR: \(error)")
    }
    
    func didFindWirelessVenuesGroup() {
        var sorted = self.venues?.array.sorted({ (venue1, venue2) -> Bool in
            return (venue1 as! Venue).location.distance.intValue < (venue2 as! Venue).location.distance.intValue
        })
        
        self.venues = NSMutableOrderedSet(array: sorted!)
        
        if false == self.searchingMessageLabel.hidden {
            self.searchingMessageLabel.hidden = true

            var saveContainer = Array<Venue>(self.venues?.array as! [Venue])
            self.animateProgressBar({
                var indexPaths = Array<NSIndexPath>()
                for var index = 0;index < saveContainer.count; ++index {
                    indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
                }

//                self.tableView.reloadData()
                self.animateTable()
//                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Left)
            })
        }
        else {
//            self.tableView.reloadData()
            self.animateTable()
        }
    }
    
    func didFindWirelessVenue(venue: Venue?) {

        if let v = venue {
        
            if true == self.venues?.containsObject(venue!) {
                return
            }

            self.venues?.addObject(venue!)
            
            if let photo = venue!.photo {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    
                    let imageData = NSData(contentsOfURL: NSURL(string:venue!.photo)!)
                    println("set venue image for: \(venue!.name) imageData count: \(imageData?.length)")
                    self.venuesImage[venue!.identifier] = imageData
                    
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        
                        if self.venues?.count > 0 {
                            if self.tableView.numberOfRowsInSection(0) == self.venues?.count {
                                let index = find(Array<Venue>(self.venues!.array as! Array<Venue>), venue!)
                                
                                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                            }
                        }
                    })
                })
            }
        }
    }
}
