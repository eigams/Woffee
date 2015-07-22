//
//  MasterViewController.m
//  CoffeeShop
//
//  Created by Stefan Burettea on 28/04/2013.
//  Copyright (c) 2013 Stefan Burettea. All rights reserved.
//

#import "MasterViewController.h"

#import <RestKit/RestKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Group.h"
#import "GroupItems.h"
#import "Venue.h"
#import "VenueCell.h"
#import "UIColor+HexColors.h"

//#import "AFOAuth2Client.h"
#import "CoffeeShop-Swift.h"

@interface MasterViewController ()<VenuesManagerDelegate>

@property (nonatomic, strong) CSLocationManager* locationManager;
@property (nonatomic, strong) NSArray* venues;
@property (nonatomic, strong) NSDictionary* venuesImage;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (BOOL)isDuplicate:(Venue *)venue {
    
    NSArray *duplicate = [self.venues filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"location.address == %@ AND name == %@", venue.location.address, venue.name]];
    
    return ([duplicate count] != 0);
}

- (void)getNearByWifiCoffeShops {
    __weak MasterViewController *weakSelf = self;
    
    self.venues = [NSArray array];
    self.venuesImage = [NSDictionary dictionary];
    self.locationManager = [[CSLocationManager alloc] init];
    
    [self.locationManager start:^(CLLocation *location, NSError *error) {
        
        if(nil == error) {
            NSLog(@"ERROR: %@", error);
        }
        else {
            NSLog(@"Location: %@", location);
            
            VenuesManager *manager = [[VenuesManager alloc] initWithLocation:location];
            manager.delegate = self;
            
            [manager venuesWithWIFI:^(Venue *venue, NSError *error) {
                
                if(nil != error) {
                    return ;
                }
                
                NSLog(@"");
                
                if(NO == [weakSelf isDuplicate:venue]) {
                    NSMutableArray *sink = [weakSelf.venues mutableCopy];
                    [sink addObject:venue];
                    weakSelf.venues = [sink copy];
                    
                    if(venue.photo) {
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:venue.photo]];
                            NSMutableDictionary *isink = [weakSelf.venuesImage mutableCopy];
                            [isink setObject:imageData forKey:venue.identifier];
                            weakSelf.venuesImage = [isink copy];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf reloadData];
                            });
                        });
                    }
                }
            }];
        }
        
    }];
}

- (void)reloadData {
    
    // Reload table data
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

//    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wifibg.png"]];
//    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
//    [backgroundView setFrame:self.tableView.bounds];
//    backgroundView.image = [UIImage imageNamed:@"wifibg.png"];
//    backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    
//    self.tableView.backgroundView = backgroundView;
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
//                                     [UIImage imageNamed:@"wifibg.png"]];
//    backgroundView.image = [UIImage imageNamed:@"wifibg.png"];
    
//    [self.tableView setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed:@"wifibg.png"]]];
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"wifibg.png"]];
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    self.tableView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getNearByWifiCoffeShops)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    
    [self getNearByWifiCoffeShops];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
//    if([self.venues count] > 0) {
//        tableView.backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"wifibg.png"]];
        return 1;
//    }
    
    // Display a message when the table is empty
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = [UIImage imageNamed:@"wifibg.png"];
    
    [containerView addSubview:bgImageView];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:containerView.bounds];
    
    messageLabel.text = @"No data is currently available. Please pull down to refresh.";
    messageLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [messageLabel sizeToFit];
    
    [containerView addSubview:messageLabel];
    
    tableView.backgroundView = containerView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.venues.count;
}

- (void)configureCell:(UITableViewCell *)tableViewCell atIndexPath:(NSIndexPath *)indexPath {

    VenueCell *cell = (VenueCell *)tableViewCell;
    
    if([self.venues count] < 1) {
        return ;
    }
    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        backgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08];
//    });

//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
//    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    [blurView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    cell.backgroundView = backgroundView;
    
    Venue *venueObject = [self.venues objectAtIndex:indexPath.row];
    cell.nameLabel.text = venueObject.name;
    if(venueObject.rating) {
        cell.ratingLabel.text = [NSString stringWithFormat:@"%.1f", [venueObject.rating floatValue]];
    }
    
    if(venueObject.ratingColor) {
        cell.ratingLabel.backgroundColor = [UIColor colorWithHexString:venueObject.ratingColor];
    }
    
    NSString *price = @"";
    for (int i = 0; i < [venueObject.price.tier intValue]; ++i) {
        price = [price stringByAppendingString:venueObject.price.currency];
    }
    
    cell.priceLabel.text = price;
    
    cell.openingHoursLabel.text = @"";
    if(venueObject.hours.status) {
        cell.openingHoursLabel.text = venueObject.hours.status;
    }
    else {
        if (venueObject.hours.isOpen) {
            cell.openingHoursLabel.text = [venueObject.hours.status boolValue] ? @"Open" : @"";
        }
    }
    
    if(venueObject.photo) {
        cell.previewImage.image = [UIImage imageWithData:[self.venuesImage objectForKey:venueObject.identifier]];
    }
    
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.0fm", [venueObject.location.distance floatValue]];
    if (venueObject.location) {
        cell.streetAddress.text = venueObject.location.address;
        cell.cityPostCodeAddress.text = [venueObject address];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VenueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VenueCell"];

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

#pragma mark - VenuesManager delegates

- (void)didFindWirelessVenue:(Venue *)venue error:(NSError *)error {
    
}

- (void)didFinishLookingForVenues:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.venues = [self.venues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    Venue *venue1 = (Venue *)obj1;
                    Venue *venue2 = (Venue *)obj2;
                    
                    return [venue1.location.distance intValue] > [venue2.location.distance intValue];
                  }];
    
    [self.tableView reloadData];
}

- (void)didStartLookingForVenues {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

@end
