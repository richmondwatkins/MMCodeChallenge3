//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "MapViewController.h"
#import <MapKit/MapKit.h>
@interface StationsListViewController () <UITabBarDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *bikeStations;
@property CLLocationManager *locationManger;
@property CLLocationCoordinate2D userLocation;
@property (strong, nonatomic) IBOutlet UITableView *searchTable;
@property NSMutableArray *searchResults;
@property NSMutableArray *allBikeStations;
@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchTable.hidden = YES;
    self.bikeStations = [NSMutableArray array];
    self.allBikeStations = [NSMutableArray array];
    self.locationManger = [[CLLocationManager alloc] init];
    [self.locationManger requestWhenInUseAuthorization];
    self.locationManger.delegate = self;
    [self.locationManger startUpdatingLocation];

    NSURL *url = [NSURL URLWithString:@"http://www.divvybikes.com/stations/json/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        for (NSDictionary *bikeStation in results[@"stationBeanList"]) {
            [self.bikeStations addObject:bikeStation];
            [self.allBikeStations addObject:bikeStation];
        }
        [self.tableView reloadData];
    }];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    for(CLLocation *location in locations){
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            self.userLocation = location.coordinate;
            [self.locationManger stopUpdatingLocation];
            break;
        }
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.bikeStations removeAllObjects];
    [self.tableView reloadData];
    self.searchTable.hidden = YES;
    [self.searchResults removeAllObjects];
    for (NSDictionary *location in self.allBikeStations) {
        if ([location[@"stationName"] containsString:searchText]) {
            NSLog(@"%@", location);
            [self.bikeStations addObject:location];
            [self.tableView reloadData];
        }
    }
}


#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

        return self.bikeStations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        NSDictionary *bikeStation = [self.bikeStations objectAtIndex:indexPath.row];
        cell.textLabel.text = bikeStation[@"stationName"];
        cell.detailTextLabel.text = bikeStation[@"stAddress1"];

        UILabel *label = [UILabel new];
        label.frame = CGRectMake(300.0f, 5.0f, 100.0f, 50.0f);
        label.text = [NSString stringWithFormat:@"%@ bikes",bikeStation[@"availableDocks"]];
        [cell addSubview:label];

    return cell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ToMapSegue"]) {
        MapViewController *mapViewCtrl = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        mapViewCtrl.location = [self.bikeStations objectAtIndex:indexPath.row];
        mapViewCtrl.userLocation = self.userLocation;
    }
}

@end
