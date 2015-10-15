//
//  Poi.h
//  RouteAdvisorFrameWork
//
//  Created by Petar Mrazovic on 8/10/15.
//  Copyright (c) 2015 DAMA-UPC. All rights reserved.
//

#ifndef Poi_h
#define Poi_h


#endif

@class Route;

@interface Poi : NSObject

@property NSString *poiId;
@property double lat;
@property double lng;
@property double score;
@property double consumingBudget;
@property Route *route;
@property double distanceStartEnd;
@property NSMutableDictionary *distanceDictionary;

- (id)initWithPoiId:(NSString *)poiId
                lat:(double)lat
                lng:(double)lng
              score:(double)score
    consumingBudget:(double)consumingBudget;

-(void)setDistanceFromPoi:(NSString *)idToPoi
                         :(double)lat
                         :(double)lng
                         :(double)walkingSpeed;

-(double)getDistanceFromPoi:(NSString *)idToPoi;

-(double)distanceFrom:(double)lat
                     :(double)lng
                     :(double)walkingSpeed;


@end
