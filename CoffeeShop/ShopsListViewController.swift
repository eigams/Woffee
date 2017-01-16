//
//  ShopsListViewController.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/24/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit
import MapKit
import RxCocoa
import RxSwift

class ShopsListViewController: UIViewController, UITableViewDelegate {

    fileprivate struct Constants {
        static let ExpandedTableViewCellSize:CGFloat = 300
        static let NormalTableViewCellSize:CGFloat = 110
        static let TableViewInsets = UIEdgeInsetsMake(50, 0, 0, 0)
        static let PushSegueIdentifier = "PushSegue"
    }
    
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
    fileprivate var venuesManager: CSHVenuesManager!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CSLocationManager()
        tableView.contentInset = Constants.TableViewInsets
        
        progressBar.configure()
        
        // Do any additional setup after loading the view.
        refreshControl.setup(in: tableView, viewController: self, selector: #selector(self.setupLocationObserver))
        setupLocationObserver()
        setupTableViewObserver()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let shopsMapViewController = segue.destination as? ShopsMapViewController, segue.identifier == Constants.PushSegueIdentifier else { return }

        shopsMapViewController.annotations = self.dataController.annotations
        shopsMapViewController.location = self.location
    }
    
    fileprivate func setupTableViewObserver() {
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                self.selectedCellIndexPath = indexPath
                
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.previouslySelectedCellIndexPath = self.selectedCellIndexPath != self.previouslySelectedCellIndexPath ? self.selectedCellIndexPath : nil
            })
            .addDisposableTo(disposeBag)
    }
    
    @objc private func setupLocationObserver() {
        locationManager.locationDidUpdate
            .flatMapLatest({ [unowned self] location -> Observable<[CSHVenue]> in
                guard let location = location else { return Observable.just([]) }
                self.location = location
                
                self.startLookingForVenues()
                
                self.venuesManager = CSHVenuesManager(location: location)
                return self.venuesManager.lookForVenuesWithWIFI()
            })
            .flatMap({ venues -> Observable<[CSHVenue]> in
                venues.forEach {
                    self.didFindWirelessVenue($0)
                }
                
                return self.venuesManager.lookForPhotos(of: venues)
            })
            .subscribe(onNext: { venues in
                venues.forEach {
                    self.didFindPhotoForWirelessVenue($0)
                }
            }, onCompleted: { [unowned self] _ in
                self.finishLookingForVenues()
            })
            .addDisposableTo(disposeBag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selected = selectedCellIndexPath, selected == indexPath, previouslySelectedCellIndexPath != selectedCellIndexPath {
            return Constants.ExpandedTableViewCellSize
        }
        
        return Constants.NormalTableViewCellSize
    }
}

//MARK: - VenuesManager delegates
extension ShopsListViewController {
    fileprivate func startLookingForVenues() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        pulsatingButton.liftAnimation(view: view)
    }
    
    fileprivate func finishLookingForVenues() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let date = Date().stringWithDateFormat("MMM d, h:mm a")
        let title = "Last update: \(date)"
        
        let attrsDictionary = [NSForegroundColorAttributeName: UIColor.white]
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary)
        
        progressBar.isHidden = true
        pulsatingButton.dropAnimation(view: view) {
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
