//
//  TopSolver.m
//  Route Recommendation
//
//  Created by Petar Mrazovic on 15/10/15.
//  Copyright © 2015 DAMA-UPC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TopSolver.h"
#import "Route.h"
#import "Poi.h"

@implementation TopSolver

@synthesize routeCount = _routeCount;
@synthesize availableBudget = _availableBudget;
@synthesize walkingSpeed = _walkingSpeed;
@synthesize pois = _pois;
@synthesize startPoi = _startPoi;
@synthesize finishPoi = _finishPoi;
@synthesize availablePois = _availablePois;
@synthesize assignedPois = _assignedPois;
@synthesize routes = _routes;

-(id)initWithRouteCount:(NSUInteger)routeCount
        availableBudget:(double)availableBudget
           walkingSpeed:(double)walkingSpeed
                   pois:(NSMutableArray *)pois
               startLat:(double)startLat
               startLng:(double)startLng
               finishLat:(double)finishLat
               finishLng:(double)finishLng {

    self.routeCount = routeCount;
    self.availableBudget = availableBudget;
    self.walkingSpeed = walkingSpeed;
    self.pois = pois;
    self.startPoi =[[Poi alloc] initWithPoiId:@"START" lat:startLat lng:startLng score:0.0 consumingBudget:0.0];
    self.finishPoi = [[Poi alloc] initWithPoiId:@"FINISH" lat:finishLat lng:finishLng score:0.0 consumingBudget:0.0];
    [self.pois addObject:self.startPoi];
    [self.pois addObject:self.finishPoi];
    self.availablePois = [[NSMutableArray alloc] init];
    self.assignedPois = [[NSMutableArray alloc] init];
    self.routes = [[NSMutableArray alloc] init];
    [self computeDistancesBetweenPois:self.pois];
    return self;
}

-(NSArray *)run:(NSUInteger)maxAlgLoop
               :(NSUInteger)maxLSLoop {

    [self construct];
    
    
    NSArray *resultRoutes = [[NSArray alloc] init];
    return resultRoutes;
}

-(void)construct {
    // Compute distances to start and finish POI and filter reachable POIs
    NSMutableArray *reachablePois = [[NSMutableArray alloc] init];
    for (Poi *poi in self.pois) {
        if (poi.poiId != self.startPoi.poiId && poi.poiId != self.finishPoi.poiId) {
            poi.distanceStartEnd = [poi getDistanceFromPoi:self.startPoi.poiId] +
                                   [poi getDistanceFromPoi:self.finishPoi.poiId];
            if (poi.distanceStartEnd + poi.consumingBudget <= self.availableBudget) {
                [self.availablePois addObject:poi];
                [reachablePois addObject:poi];
            }
        }
    }
    
    // Sort available POIs by distances to start and end POI, and take first routeCount POIs to intialize routes
    NSSortDescriptor *poiSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distanceStartEnd" ascending:false];
    NSArray *poiSortDescriptors = [NSArray arrayWithObject:poiSortDescriptor];
    NSMutableArray *routeInitPois = (NSMutableArray *)[self.availablePois sortedArrayUsingDescriptors:poiSortDescriptors];
    // Making sure there is enough available POIs to initialize routeCount routes
    NSUInteger initRouteCount = self.routeCount;
    if (self.routeCount > [routeInitPois count]) {
        initRouteCount = [routeInitPois count];
    }
    routeInitPois = (NSMutableArray *)[routeInitPois subarrayWithRange:NSMakeRange(0, initRouteCount)];
    
    // Initialize routes
    for (Poi *initPoi in routeInitPois) {
        Route *newRoute = [[Route alloc] initWithStartPoi:self.startPoi finishPoi:self.finishPoi];
        // Add init POI between start and finish POIs, i.e. at the position 1
        [newRoute insertPoi:initPoi :1];
        [self.availablePois removeObject:initPoi];
        [self.routes addObject:newRoute];
    }
    
	// For each of available POIs find cheapest insertion position among all newly created routes
    NSMutableArray *includedPois = [[NSMutableArray alloc] init];
    for (Poi *insertPoi in self.availablePois) {
        double cheapestCost = DBL_MAX;
        Route *cheapestRoute = nil;
        NSUInteger insertPosition = 0;
        
        for (Route *route in self.routes) {
            NSArray *r = [route findCheapestInsertion:insertPoi];
            double routeInsertCost = [[r objectAtIndex:0] doubleValue];
            NSUInteger routeInsertPosition = [[r objectAtIndex:1] integerValue];
            
            if ((route.consumedBudget + routeInsertCost <= self.availableBudget) &&
               (routeInsertCost < cheapestCost)) {
                cheapestCost = routeInsertCost;
                insertPosition = routeInsertPosition;
                cheapestRoute = route;
            }
        }
        
        // If the cheapest cost is found in the budget
        if (cheapestRoute != nil) {
            [cheapestRoute insertPoi:insertPoi :insertPosition :cheapestCost];
            [includedPois addObject:insertPoi];
        }
    }
    // Remove included POIs
    [self.availablePois removeObjectsInArray:includedPois];
    
    // Construct new routes from the remaining available POIs until all points are assigned to routes
    while ([self.availablePois count] > 0) {
        // Initialize new route with most distant available POI
        Poi *initPoi = (Poi *)((NSMutableArray *)[self.availablePois sortedArrayUsingDescriptors:poiSortDescriptors])[0];
        Route *newRoute = [[Route alloc] initWithStartPoi:self.startPoi finishPoi:self.finishPoi];
        // Add init POI between start and finish POIs, i.e. at the position 1
        [newRoute insertPoi:initPoi :1];
        [self.availablePois removeObject:initPoi];
        [self.routes addObject:newRoute];
        
        // Go through all the available POIs and find the cheapest place for insertion
        NSMutableArray *includedPois = [[NSMutableArray alloc] init];
        for (Poi *insertPoi in self.availablePois) {
            NSArray *r = [newRoute findCheapestInsertion:insertPoi];
            double insertCost = [[r objectAtIndex:0] doubleValue];
            NSUInteger insertPosition = [[r objectAtIndex:1] integerValue];
            if (newRoute.consumedBudget + insertCost <= self.availableBudget) {
                [newRoute insertPoi:insertPoi :insertPosition :insertCost];
                [includedPois addObject:insertPoi];
            }
        }
        // Remove included POIs
        [self.availablePois removeObjectsInArray:includedPois];
    }
    
    // Sort routes by score, and take first routeCount routes as initial solution
    NSSortDescriptor *routeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:false];
    NSArray *routeSortDescriptors = [NSArray arrayWithObject:routeSortDescriptor];
    NSMutableArray *initRoutes = (NSMutableArray *)[self.routes sortedArrayUsingDescriptors:routeSortDescriptors];
    
    // Making sure there is more than routeCount routes
    NSUInteger routeCount = self.routeCount;
    if (self.routeCount > [initRoutes count]) {
        routeCount = [initRoutes count];
    }
    
    // Take first routeCount routes
    self.routes = (NSMutableArray *)[initRoutes subarrayWithRange:NSMakeRange(0, routeCount)];
    
    // Assign IDs to routes, and add assinged POIs to corresponding list
    NSUInteger routeCounter = 0;
    for (Route *route in self.routes) {
        route.routeId = [NSString stringWithFormat:@"%@",  @(routeCounter)];
        routeCounter++;
        for (Poi *assignedPoi in route.pois) {
            if (assignedPoi.poiId != self.startPoi.poiId && assignedPoi.poiId != self.finishPoi.poiId) {
                [self.assignedPois addObject:assignedPoi];
            }
        }
    }
    // Remove assigned POIs from reachable list
    [reachablePois removeObjectsInArray:self.assignedPois];
    // Set route to nil for all remaining POIs
    for (Poi *reachablePoi in reachablePois) {
        reachablePoi.route = nil;
    }
    self.availablePois = [NSMutableArray arrayWithArray:reachablePois];
}

-(void)computeDistancesBetweenPois:(NSMutableArray *)pois {
    for (Poi *poiI in pois) {
        for (Poi *poiJ in pois) {
            [poiI setDistanceFromPoi:poiJ.poiId :poiJ.lat :poiJ.lng :self.walkingSpeed];
        }
    }
}






@end

