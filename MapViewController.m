//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   

    NSString *latitude = self.location[@"latitude"];
    NSString *longitude = self.location[@"longitude"];

    CLLocationCoordinate2D coord;
    coord.latitude = latitude.floatValue;
    coord.longitude = longitude.floatValue;

    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = coord;
    annotation.title = self.location[@"stationName"];
    [self.mapView addAnnotation:annotation];

    CLLocationCoordinate2D center = annotation.coordinate;

    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;

    MKCoordinateRegion region;
    region.center = center;
    region.span = span;

    [self.mapView setRegion:region animated:YES];
}



-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if (annotation == mapView.userLocation) {
        return nil;
    }

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView  = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.image = [UIImage imageNamed:@"bikeImage"];

    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{

    [self getDirections:(MKAnnotationView *)view];
}


-(void)getDirections:(MKAnnotationView *)view{
    MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
    [directionRequest setSource:[MKMapItem mapItemForCurrentLocation]];


    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(view.annotation.coordinate.latitude, view.annotation.coordinate.longitude) addressDictionary:nil];

    MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [destinationMapItem setName:@"Name of your location"];

    [directionRequest setDestination: destinationMapItem];
    directionRequest.transportType = MKDirectionsTransportTypeWalking;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        [self showRoute:response];
    }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];

        NSArray* reversedStepsForAlertView = [[route.steps reverseObjectEnumerator] allObjects];

        for (MKRouteStep *step in reversedStepsForAlertView)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Directions" message:step.instructions delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

@end
