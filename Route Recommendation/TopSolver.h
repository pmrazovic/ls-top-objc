//
//  TopSolver.h
//  Route Recommendation
//
//  Created by Petar Mrazovic on 15/10/15.
//  Copyright © 2015 DAMA-UPC. All rights reserved.
//

#ifndef TopSolver_h
#define TopSolver_h


#endif /* TopSolver_h */

@class Poi;
@class Route;

@interface TopSolver : NSObject

@property NSUInteger routeCount;
@property double availableBudget;
@property double walkingSpeed;
@property NSMutableArray *pois;
@property Poi *startPoi;
@property Poi *finishPoi;
@property NSMutableArray *availablePois;
@property NSMutableArray *assignedPois;
@property NSMutableArray *routes;
@property double solutionScore;
@property NSMutableArray *solutionRoutes;

- (id)initWithRouteCount:(NSUInteger)routeCount
         availableBudget:(double)availableBudget
            walkingSpeed:(double)walkingSpeed
                    pois:(NSMutableArray *)pois
                startLat:(double)startLat
                startLng:(double)startLng
               finishLat:(double)finishLat
               finishLng:(double)finishLng;

-(NSArray *)run:(NSUInteger)maxAlgLoop
               :(NSUInteger)maxLSLoop;

@end