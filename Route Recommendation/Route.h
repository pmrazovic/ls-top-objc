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

- (id)initWithStartPoi:(Poi *)startPoi
            finishPoi:(Poi *)finishPoi;

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

-(NSArray *)computeRouteCOG;

-(NSMutableArray *)disturb:(double)percentage
              :(Boolean)fromStart;

@end