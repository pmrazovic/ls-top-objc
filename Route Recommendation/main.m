//
//  main.m
//  Route Recommendation
//
//  Created by Petar Mrazovic on 14/10/15.
//  Copyright © 2015 DAMA-UPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Poi.h"
#import "Route.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        Poi *poiExample1 = [[Poi alloc] initWithPoiId:@"1" lat:41.386286 lng:2.119956 score:30 consumingBudget:20.0];
        Poi *poiExample2 = [[Poi alloc] initWithPoiId:@"2" lat:41.387992 lng:2.115386 score:30 consumingBudget:40.0];
        Poi *poiExample3 = [[Poi alloc] initWithPoiId:@"3" lat:41.392532 lng:2.143989 score:10 consumingBudget:10.0];
        Poi *poiExample4 = [[Poi alloc] initWithPoiId:@"4" lat:41.389900 lng:2.148248 score:20 consumingBudget:5.0];
        Poi *poiExample5 = [[Poi alloc] initWithPoiId:@"5" lat:41.383542 lng:2.161902 score:3 consumingBudget:12.0];
        Poi *poiExample6 = [[Poi alloc] initWithPoiId:@"6" lat:41.375028 lng:2.166251 score:50 consumingBudget:80.0];
        
        NSMutableArray *pois = [[NSMutableArray alloc] init];
        [pois addObject:poiExample1];
        [pois addObject:poiExample2];
        [pois addObject:poiExample3];
        [pois addObject:poiExample4];
        [pois addObject:poiExample5];
        [pois addObject:poiExample6];
        
        for (Poi *poiI in pois) {
            for (Poi *poiJ in pois) {
                [poiI setDistanceFromPoi:poiJ.poiId :poiJ.lat :poiJ.lng :60.0];
            }
        }
        
        Route *newRoute = [[Route alloc] initWithRouteId:@"1" startPoi:poiExample1 endPoi:poiExample6 ];
        
        NSArray *r = [newRoute findCheapestInsertion:poiExample4];
        double cost = [[r objectAtIndex:0] doubleValue];
        NSUInteger position = [[r objectAtIndex:1] longValue];
        
        [newRoute insertPoi:poiExample4 :position];
        
        r = [newRoute findCheapestInsertion:poiExample2];
        cost = [[r objectAtIndex:0] doubleValue];
        position = [[r objectAtIndex:1] longValue];
        
        [newRoute insertPoi:poiExample2 :position];

        r = [newRoute findCheapestInsertion:poiExample5];
        cost = [[r objectAtIndex:0] doubleValue];
        position = [[r objectAtIndex:1] longValue];
        
        [newRoute insertPoi:poiExample5 :1];
        [newRoute insertPoi:poiExample3 :3];
        
        [newRoute tsp];
        
        NSMutableArray *removed = [newRoute disturb:0.8 :true];
        
        [newRoute tsp];
        
        
        NSLog(@"nekaj");
        
        
        
        
        

    }
    return 0;
}
