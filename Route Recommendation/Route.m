//
//  Route.m
//  Route Recommendation
//
//  Created by Petar Mrazovic on 14/10/15.
//  Copyright © 2015 DAMA-UPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"
#import "Poi.h"

@implementation Route

@synthesize routeId = _routeId;
@synthesize score = _score;
@synthesize consumedBudget = _consumedBudget;
@synthesize pois = _pois;

-(id)initWithRouteId:(NSString *)routeId
            startPoi:(Poi *)startPoi
              endPoi:(Poi *)endPoi {

    self.routeId = routeId;
    self.pois = [[NSMutableArray alloc] init];
    [self.pois addObject:startPoi];
    [self.pois addObject:endPoi];
    self.consumedBudget = [self computeTotalConsumedBudget:self.pois];
    self.score = [self computeTotalScore:self.pois];
    return self;
}

-(void)insertPoi:(Poi *)insertPoi
                :(NSUInteger)position {

    double cost = [self getInsertionCost:self.pois :insertPoi :position];
    [self insertPoi:insertPoi :position :cost];
}

-(void)insertPoi:(Poi *)insertPoi
                :(NSUInteger)position
                :(double)cost {
    [self.pois insertObject:insertPoi atIndex:position];
    self.consumedBudget += cost;
    self.score += insertPoi.score;
    insertPoi.route = self;
}

-(void)removePoi:(Poi *)removePoi {
    double gain = [self getDelitionGain:removePoi];
    [self removePoi:removePoi :gain];
}

-(void)removePoi:(Poi *)removePoi
                :(long)gain {
    [self.pois removeObject:removePoi];
    self.consumedBudget -= gain;
    self.score -= removePoi.score;
    removePoi.route = NULL;
}

-(NSArray *)findCheapestInsertion:(Poi *)insertPoi {
    double insertCost = DBL_MAX;
    NSUInteger insertPosition = 0;
    for (NSUInteger i = 1; i < [self.pois count]; i++) {
        float newCost = [self getInsertionCost:self.pois :insertPoi :i];
        if (newCost < insertCost) {
            insertCost = newCost;
            insertPosition = i;
            
        }
    }
    
    NSArray *returnArray = [NSArray arrayWithObjects:[NSNumber numberWithDouble:insertCost], [NSNumber numberWithLong:insertPosition], nil];
    return returnArray;
}

-(double)computeTotalScore:(NSMutableArray *)pois {
    double score = 0.0;
    for (Poi *includedPoi in pois) {
        score += includedPoi.score;
    }
    return score;
}

-(double)computeTotalConsumedBudget:(NSMutableArray *)pois {
    double consumedBudget = 0.0;
    for (NSUInteger i = 0; i < [pois count]-1; i++) {
        Poi *currentPoi = [pois objectAtIndex:i];
        Poi *nextPoi = [pois objectAtIndex:i+1];
        consumedBudget += currentPoi.consumingBudget + [currentPoi getDistanceFromPoi:nextPoi.poiId];
    }
    Poi *lastPoi = [pois lastObject];
    consumedBudget += lastPoi.consumingBudget;
    return consumedBudget;
}

-(double)getInsertionCost:(NSMutableArray *)pois
                         :(Poi *)insertPoi
                         :(NSUInteger)position {
    
    Poi *previousPoi = [pois objectAtIndex:position-1];
    Poi *nextPoi = [pois objectAtIndex:position];
    double cost = [previousPoi getDistanceFromPoi:insertPoi.poiId] +
                  [insertPoi getDistanceFromPoi:nextPoi.poiId] -
                  [previousPoi getDistanceFromPoi:nextPoi.poiId] +
                  insertPoi.consumingBudget;
    return cost;    
}

-(double)getDelitionGain:(Poi *)removePoi {
    NSUInteger position = [self.pois indexOfObject:removePoi];
    Poi *previousPoi = [self.pois objectAtIndex:position-1];
    Poi *nextPoi = [self.pois objectAtIndex:position+1];
    double gain = [previousPoi getDistanceFromPoi:removePoi.poiId] +
                  [removePoi getDistanceFromPoi:nextPoi.poiId] +
                  removePoi.consumingBudget -
                  [previousPoi getDistanceFromPoi:nextPoi.poiId];
    return gain;
}



@end











