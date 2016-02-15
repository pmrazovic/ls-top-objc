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
@synthesize solutionScore = _solutionScore;
@synthesize solutionRoutes = _solutionRoutes;

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

    self.solutionScore = 0.0;
    self.solutionRoutes = [[NSMutableArray alloc] init];
    
    [self construct];
    NSUInteger algLoop = 0;
    NSUInteger disturbCount = 0;
    
    while (algLoop < maxAlgLoop) {
        algLoop++;
        NSUInteger lsLoop = 0;
        double solutionScore = 0.0;
        NSMutableArray *solutionRoutes = [[NSMutableArray alloc] init];
        Boolean solutionImproved = true;
        
        while (solutionImproved && (lsLoop < maxLSLoop)) {
            lsLoop++;
            solutionImproved = false;

            [self swap];
            [self tsp];
            [self swap];
            [self move];
            [self insert];
            [self replace];
            
            double newSolutionScore = [self computeSolutionScore];
            if (newSolutionScore > solutionScore) {
                [solutionRoutes removeAllObjects];
                for (Route *route in self.routes) {
                    NSMutableArray *routePois = [[NSMutableArray alloc] init];
                    for (Poi *routePoi in route.pois) {
                        [routePois addObject:routePoi.poiId];
                    }
                    [solutionRoutes addObject:routePois];
                }
                solutionScore = newSolutionScore;
                solutionImproved = true;
            }
        }
        
        if (solutionScore > self.solutionScore) {
            self.solutionScore = solutionScore;
            [self.solutionRoutes removeAllObjects];
            for (NSMutableArray *routePoiIds in solutionRoutes) {
                [self.solutionRoutes addObject:routePoiIds];
            }
        } else if (solutionScore == self.solutionScore) {
            if (disturbCount == 0) {
                [self disturb:0.7 :false];
                disturbCount++;
            } else if (disturbCount == 1) {
                [self disturb:0.7 :true];
                disturbCount++;
            } else {
                return self.solutionRoutes;
            }
        }
        
        if (algLoop == maxAlgLoop/2) {
            [self disturb:0.7 :false];
            disturbCount++;
        }
        
    }
    
    return self.solutionRoutes;
}

// Greedy construction heuristic creates initial solution
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

// Method swaps a location between two tours
// This heuristic endeavours to exchange two locations between two tours
-(void)swap{
    Boolean swap = true;
    while (swap) {
        swap = false;
        for (Poi *poiI in self.assignedPois) {
            for (Poi *poiJ in self.assignedPois) {
                
                Route *routeI = poiI.route;
                Route *routeJ = poiJ.route;
                if (routeI != routeJ) {
                    
                    NSArray *rI = [routeI findCheapestReplace:poiI :poiJ];
                    double gainI = [[rI objectAtIndex:0] doubleValue];
                    double costI = [[rI objectAtIndex:1] doubleValue];
                    NSUInteger insertPositionI = [[rI objectAtIndex:2] integerValue];
                    
                    NSArray *rJ = [routeJ findCheapestReplace:poiJ :poiI];
                    double gainJ = [[rJ objectAtIndex:0] doubleValue];
                    double costJ = [[rJ objectAtIndex:1] doubleValue];
                    NSUInteger insertPositionJ = [[rJ objectAtIndex:2] integerValue];
                    
                    if ((routeI.consumedBudget - gainI + costI <= self.availableBudget) &&
                       (routeJ.consumedBudget - gainJ + costJ <= self.availableBudget )) {
                        // If the travel time can be reduced in each tour, or if the time saved in one tour
                        // is longer than the extra time needed in the other tour, the swap is carried out
                        if ((gainI > costI && gainJ > costJ) ||
                            (gainI - costI > costJ - gainJ) ||
                            (gainJ - costJ > costI - gainI)) {
                            [routeI removePoi:poiI :gainI];
                            [routeJ removePoi:poiJ :gainJ];
                            [routeI insertPoi:poiJ :insertPositionI :costI];
                            [routeJ insertPoi:poiI :insertPositionJ :costJ];
                            swap = true;
                            break;
                        }
                    }
                    
                }
            }
            if (swap) break;
        }
    }
}

// A 2-opt heuristic for traveling salesman problem
// https://en.wikipedia.org/wiki/2-opt
-(void)tsp {
    for (Route *route in self.routes) {
        [route tsp];
    }
}

// Move a location from one tour to another
// Methods tries to group together the available time left.
-(void)move {
    NSMutableArray *shortenedRoutes = [[NSMutableArray alloc] init];
    Boolean moveMade = true;
    
    while (moveMade) {
        moveMade = false;
        for (Poi *movingPoi in self.assignedPois) {
            for (Route *newRoute in self.routes) {
                Route *oldRoute = movingPoi.route;
                if ((newRoute != oldRoute) && ![shortenedRoutes containsObject:newRoute]) {
                    
                    NSArray *r = [newRoute findCheapestInsertion:movingPoi];
                    double insertCost = [[r objectAtIndex:0] doubleValue];
                    NSUInteger insertPosition = [[r objectAtIndex:1] integerValue];
                    
                    if (newRoute.consumedBudget + insertCost <= self.availableBudget) {
                        [oldRoute removePoi:movingPoi];
                        [newRoute insertPoi:movingPoi :insertPosition :insertCost];
                        if (![shortenedRoutes containsObject:oldRoute]) [shortenedRoutes addObject:oldRoute];
                        moveMade = true;
                        break;
                    }
                    
                }
            }
            if (moveMade) break;
        }
    }
}

// Method attempts to insert new locations in the tours in
// the position where the location consumes the least travel time.
-(void)insert {
    for (Route *route in self.routes) {
        Boolean insertion = true;
        while (insertion) {
            insertion = false;
            NSArray *sortedAvailablePois = [self sortByAppropriateness:route];
            for (Poi *insertPoi in sortedAvailablePois) {
                
                NSArray *r = [route findCheapestInsertion:insertPoi];
                double insertCost = [[r objectAtIndex:0] doubleValue];
                NSUInteger insertPosition = [[r objectAtIndex:1] integerValue];
                
                if (route.consumedBudget + insertCost <= self.availableBudget) {
                    [route insertPoi:insertPoi :insertPosition :insertCost];
                    [self.availablePois removeObject:insertPoi];
                    [self.assignedPois addObject:insertPoi];
                    insertion = true;
                    break;
                }
            }
        }
    }
}

// Method seeks to replace an included location by a non-included location with a higher score.
-(void)replace {
    for (Route *route in self.routes) {
        Boolean replacement = true;
        while (replacement) {
            replacement = false;
            NSArray *sortedAvailablePois = [self sortByAppropriateness:route];
            for (Poi *insertPoi in sortedAvailablePois) {
                
                // First check if there is enough budget to insert POI
                NSArray *r = [route findCheapestInsertion:insertPoi];
                double insertCost = [[r objectAtIndex:0] doubleValue];
                NSUInteger insertPosition = [[r objectAtIndex:1] integerValue];
                if (route.consumedBudget + insertCost <= self.availableBudget) {
                    [route insertPoi:insertPoi :insertPosition :insertCost];
                    [self.availablePois removeObject:insertPoi];
                    [self.assignedPois addObject:insertPoi];
                    replacement = true;
                    break;
                }
                
                // If no avialable budget, try to find it by removing pois with lower scores
                for (Poi *removePoi in [route.pois subarrayWithRange:NSMakeRange(1, [route.pois count]-2)]) {
                    if (removePoi.score < insertPoi.score) {
                        
                        NSArray *r = [route findCheapestReplace:removePoi :insertPoi];
                        double removeGain = [[r objectAtIndex:0] doubleValue];
                        double insertCost = [[r objectAtIndex:1] doubleValue];
                        NSUInteger insertPosition = [[r objectAtIndex:2] integerValue];
                        
                        double temp = route.consumedBudget - removeGain + insertCost;
                        if (route.consumedBudget - removeGain + insertCost <= self.availableBudget) {
                            [route removePoi:removePoi :removeGain];
                            [self.availablePois addObject:removePoi];
                            [self.assignedPois removeObject:removePoi];
                            [route insertPoi:insertPoi :insertPosition :insertCost];
                            [self.availablePois removeObject:insertPoi];
                            [self.assignedPois addObject:insertPoi];
                            replacement = true;
                            break;
                        }
                        
                    }
                }
                if (replacement) break;

            }
        }
    }
}

-(void)disturb:(double)percentage
              :(Boolean)fromStart {
    for (Route *route in self.routes) {
        for (Poi *removedPoi in [route disturb:percentage :fromStart]) {
            removedPoi.route = nil;
            [self.availablePois addObject:removedPoi];
            [self.assignedPois removeObject:removedPoi];
        }
    }
}

-(NSArray *)sortByAppropriateness:(Route *)route {
    NSArray *cog = [route computeRouteCOG];
    NSMutableDictionary *apprDict = [[NSMutableDictionary alloc] init];
    for (Poi *availablePoi in self.availablePois) {
        apprDict[availablePoi.poiId] = [NSNumber numberWithDouble:[availablePoi distanceFrom:[[cog objectAtIndex:0] doubleValue] :[[cog objectAtIndex:1] doubleValue] :self.walkingSpeed]];
    }
    NSArray *sortedArray = [self.availablePois sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *cogDistance1 = [apprDict objectForKey:((Poi *)obj1).poiId];
        NSNumber *cogDistance2 = [apprDict objectForKey:((Poi *)obj2).poiId];
        return  [cogDistance2 compare:cogDistance1];
    }];
    
    return sortedArray;
}

-(void)computeDistancesBetweenPois:(NSMutableArray *)pois {
    for (Poi *poiI in pois) {
        for (Poi *poiJ in pois) {
            [poiI setDistanceFromPoi:poiJ.poiId :poiJ.lat :poiJ.lng :self.walkingSpeed];
        }
    }
}

-(double)computeSolutionScore {
    double solutionScore = 0.0;
    for (Route *route in self.routes) {
        solutionScore += route.score;
    }
    return solutionScore;
}

@end

