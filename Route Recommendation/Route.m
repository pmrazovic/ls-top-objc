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

-(id)initWithStartPoi:(Poi *)startPoi
            finishPoi:(Poi *)finishPoi {

    self.pois = [[NSMutableArray alloc] init];
    [self.pois addObject:startPoi];
    [self.pois addObject:finishPoi];
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

-(NSArray *)findCheapestReplace:(Poi *)removePoi
                               :(Poi *)insertPoi {
    
    double removeGain = [self getDelitionGain:removePoi];
    
    // Temporarily remove removePoi from the list to calculate replace cost (remember original position)
    NSUInteger originalPosition = [self.pois indexOfObject:removePoi];
    [self.pois removeObject:removePoi];
    
    NSArray *r = [self findCheapestInsertion:insertPoi];
    double insertCost = [[r objectAtIndex:0] doubleValue];
    NSUInteger insertPosition = [[r objectAtIndex:1] longValue];
    
    // Put removePoi back to list
    [self.pois insertObject:removePoi atIndex:originalPosition];
    
    NSArray *returnArray = [NSArray arrayWithObjects:[NSNumber numberWithDouble:removeGain], [NSNumber numberWithDouble:insertCost], [NSNumber numberWithLong:insertPosition], nil];
    
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

-(NSArray *)computeRouteCOG {
    double cogX = 0.0;
    double cogY = 0.0;
    
    for (Poi *includedPoi in self.pois) {
        cogX += includedPoi.score * includedPoi.lat;
        cogY += includedPoi.score * includedPoi.lng;
    }
    NSArray *cog = [NSArray arrayWithObjects:[NSNumber numberWithDouble:cogX/self.score], [NSNumber numberWithDouble:cogY/self.score], nil];
    if (self.score == 0.0) {
        cog = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.0], [NSNumber numberWithDouble:0.0], nil];
    }
    return cog;
}

-(void)tsp {
    double consumedBudget = [self computeTotalConsumedBudget:self.pois];
    NSMutableArray *tmpPois = [self.pois mutableCopyWithZone:nil];
    Boolean edgeSwaped = true;
    
    while (edgeSwaped) {
        edgeSwaped = false;
        for (NSUInteger i = 1; i < [tmpPois count]-1; i++) {
            for (NSUInteger k = i+1; k < [tmpPois count]-1; k++) {
                double oldDistance = [((Poi *)tmpPois[i-1]) getDistanceFromPoi:((Poi *)tmpPois[i]).poiId] +
                                     [((Poi *)tmpPois[k]) getDistanceFromPoi:((Poi *)tmpPois[k+1]).poiId];
                double newDistance = [((Poi *)tmpPois[i-1]) getDistanceFromPoi:((Poi *)tmpPois[k]).poiId] +
                                     [((Poi *)tmpPois[i]) getDistanceFromPoi:((Poi *)tmpPois[k+1]).poiId];
                
                if (newDistance < oldDistance) {
                    [self twoOpt:tmpPois :i :k];
                    edgeSwaped = true;
                }
            }
        }
    }
    
    double tempBudget = [self computeTotalConsumedBudget:tmpPois];
    if (tempBudget < consumedBudget) {
        self.pois = tmpPois;
    }
    
}

-(NSMutableArray *)disturb:(double)percentage
                          :(Boolean)fromStart {
    NSUInteger removeCount = (NSUInteger)(([self.pois count]-2)*percentage);
    NSMutableArray *removedPois = [[NSMutableArray alloc] init];
    Poi *removePoi;
    
    NSUInteger counter = 0;
    while (counter < removeCount) {
        if (fromStart) {
            removePoi = self.pois[1];
        } else {
            removePoi = self.pois[[self.pois count] - 2];
        }
        [removedPois addObject:removePoi];
        [self.pois removeObject:removePoi];
        self.score -= removePoi.score;
        counter++;
    }
    
    return removedPois;
}

-(void)twoOpt:(NSMutableArray *)pois
             :(NSUInteger)i
             :(NSUInteger)k {
    NSUInteger l = k;
    NSUInteger limit = i + ((k - i) / 2);
    for (NSUInteger j = i; j <= limit; j++) {
        Poi *tmpPoi = pois[j];
        pois[j] = pois[l];
        pois[l] = tmpPoi;
        l--;
    }
}

@end