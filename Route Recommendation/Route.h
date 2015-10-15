//
//  Route.h
//  Route Recommendation
//
//  Created by Petar Mrazovic on 14/10/15.
//  Copyright © 2015 DAMA-UPC. All rights reserved.
//

#ifndef Route_h
#define Route_h

#endif /* Route_h */

@class Poi;

@interface Route : NSObject

@property NSString *routeId;
@property double score;
@property double consumedBudget;
@property NSMutableArray *pois;

- (id)initWithRouteId:(NSString *)routeId
             startPoi:(Poi *)startPoi
               endPoi:(Poi *)endPoi;

-(void)insertPoi:(Poi *)insertPoi
                :(NSUInteger)position;

-(void)insertPoi:(Poi *)insertPoi
                :(NSUInteger)position
                :(double)cost;

-(void)removePoi:(Poi *)removePoi;

-(void)removePoi:(Poi *)removePoi
                :(long)gain;

-(NSArray *)findCheapestInsertion:(Poi *)insertPoi;

-(NSArray *)findCheapestReplace:(Poi *)removePoi
                               :(Poi *)insertPoi;

-(double)getDelitionGain:(Poi *)removePoi;

-(void)tsp;

-(double)computeRouteCOG;

-(double)disturb:(double)percentage
                :(BOOL)fromStart;

@end