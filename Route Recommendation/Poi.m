//
//  Poi.m
//  RouteAdvisorFrameWork
//
//  Created by Petar Mrazovic on 8/10/15.
//  Copyright (c) 2015 DAMA-UPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Poi.h"
#import "Route.h"
//#import "RouteAdvisor.h"

@implementation Poi

@synthesize poiId = _poiId;
@synthesize lat = _lat;
@synthesize lng = _lng;
@synthesize score = _score;
@synthesize consumingBudget = _consumingBudget;
@synthesize route = _route;
@synthesize distanceStartEnd = _distanceStartEnd;
@synthesize distanceDictionary = _distanceDictionary;

- (id)initWithPoiId:(NSString *)poiId
                lat:(double)lat
                lng:(double)lng
              score:(double)score
    consumingBudget:(double)consumingBudget {
    
    if ( self = [super init] )
    {
        self.poiId = poiId;
        self.lat = lat;
        self.lng = lng;
        self.score = score;
        self.consumingBudget = consumingBudget;
        self.distanceDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(double)distanceFrom:(double)lat
                     :(double)lng
                     :(double)walkingSpeed {
    
    
    double dlon = [self toRadians:lng] - [self toRadians:self.lng];
    double dlat = [self toRadians:lat] - [self toRadians:self.lat];
    
    double a = pow(sin(dlat/2),2) + cos([self toRadians:self.lat]) * cos([self toRadians:lat]) * pow(sin(dlon/2),2);
    double c = 2 * atan2(sqrt(a),sqrt(1-a));
    double d = 6373 * c * 1000;
    
    if (d > 1500) {
        // simulating speed of public transport (200 m/min)
        // http://www.tmb.cat/en/transports-en-xifres
        d = d / 200.0;
    } else {
        d = d / walkingSpeed;
    }
    
    return d;
}

-(void)setDistanceFromPoi:(NSString *)idToPoi
                         :(double)lat
                         :(double)lng
                         :(double)walkingSpeed {
    
    double distance = [self distanceFrom:lat:lng:walkingSpeed];
    [self.distanceDictionary setObject:[NSNumber numberWithDouble:distance] forKey:idToPoi];
}

-(double)getDistanceFromPoi:(NSString *)idToPoi {
    
    double distance = [[self.distanceDictionary objectForKey:idToPoi] doubleValue];
    return distance;
}


-(double) toRadians :(double) degrees {
    return degrees * (M_PI/ 180);
}



@end