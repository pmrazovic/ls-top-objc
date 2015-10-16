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
#import "TopSolver.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSMutableArray *pois = [[NSMutableArray alloc] init];
        
        // Adding example POIs
        [pois addObject:[[Poi alloc] initWithPoiId:@"1228" lat:41.3582863888889 lng:1.98555497222222 score:1.071500462609837810842 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"142" lat:41.380573 lng:2.170374 score:1.0226352416326089006933 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"1155" lat:41.3647776388889 lng:2.15257502777778 score:0.9492961108275586664858 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"205" lat:41.378864 lng:2.174117 score:0.9233420967003482566011 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"398" lat:41.407215 lng:2.214539 score:0.9112400667271195467048 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"975" lat:41.40205 lng:2.21529 score:0.887575121952868456074 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"230" lat:41.395271 lng:2.161785 score:0.875461113613918228113 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"667" lat:41.36882 lng:2.153347 score:0.8662620850333555307264 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"470" lat:41.380852 lng:2.185799 score:0.8435596210701236669254 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"228" lat:41.389248 lng:2.186548 score:0.8369478904631378023212 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"891" lat:41.382812 lng:2.178195 score:0.8359267847127004286224 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"425" lat:41.391556 lng:2.197416 score:0.8162579683864020667817 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"436" lat:41.379158 lng:2.192717 score:0.8123688312451524313095 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"472" lat:41.376625 lng:2.184117 score:0.7971431153497817392677 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"82" lat:41.387554 lng:2.17554 score:0.7883110848570788505394 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"973" lat:41.394341 lng:2.2066 score:0.7725692920623401825411 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"646" lat:41.363823 lng:2.167096 score:0.7714574979479849857823 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"933" lat:41.390739 lng:2.166672 score:0.7700726028941891965625 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"676" lat:41.368679 lng:2.147031 score:0.7587892128029988410156 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"953" lat:41.424667 lng:2.139856 score:0.7385574063080987645526 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"509" lat:41.41935 lng:2.146432 score:0.7025758536957329385092 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"6" lat:41.384178 lng:2.176819 score:0.6969025857970963423707 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"508" lat:41.414249 lng:2.151926 score:0.6918199688041046361079 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"106" lat:41.383518 lng:2.1818 score:0.6565676966073492762232 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"1001" lat:41.419388 lng:2.161812 score:0.6545776972759535427268 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"81" lat:41.385181 lng:2.180863 score:0.6537048403785426627762 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"909" lat:41.378681 lng:2.169317 score:0.6484741837097378590578 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"372" lat:41.403568 lng:2.174435 score:0.6444139874712940676368 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"636" lat:41.363441 lng:2.152537 score:0.6419986913432869675026 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"889" lat:41.3857751666667 lng:2.17367072222222 score:0.6340049443614819554213 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"421" lat:41.394859 lng:2.201189 score:0.6338075113034215618702 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"978" lat:41.373009 lng:2.189541 score:0.6323997206248743680307 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"1227" lat:41.0864267222222 lng:1.15315255555556 score:0.6191091645056532665621 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"435" lat:41.375286 lng:2.17598 score:0.6157370214126676756599 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"932" lat:41.387005 lng:2.17003 score:0.6141237418660427171555 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"25" lat:41.383835 lng:2.178294 score:0.6076169154704081098786 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"955" lat:41.432961 lng:2.165669 score:0.6047825912849173312138 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"255" lat:41.391758 lng:2.164961 score:0.6040702874278491115916 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"911" lat:41.387653 lng:2.188076 score:0.5985822004805903960741 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"32" lat:41.384144 lng:2.177409 score:0.5948266881022139892132 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"375" lat:41.398621 lng:2.185367 score:0.5887573167012532377171 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"504" lat:41.403442 lng:2.150684 score:0.5857459622056266502022 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"4" lat:41.383327 lng:2.174488 score:0.5834712792598761662134 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"972" lat:41.390316 lng:2.201922 score:0.5699134489198409311308 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"920" lat:41.376385 lng:2.179861 score:0.5618092441686082138036 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"974" lat:41.398445 lng:2.211921 score:0.5608241372712440842465 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"930" lat:41.394924 lng:2.175599 score:0.5598177540766773373912 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"931" lat:41.39555 lng:2.1652 score:0.5595978145917815381391 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"981" lat:41.383797 lng:2.195914 score:0.555005080069009199819 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"924" lat:41.397072 lng:2.160723 score:0.5510282330491897303723 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"954" lat:41.451843 lng:2.178289 score:0.5487785576230039922697 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"422" lat:41.387707 lng:2.19939 score:0.5478835621501023121838 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"107" lat:41.385818 lng:2.183785 score:0.5419081351544801363337 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"918" lat:41.380924 lng:2.182465 score:0.5377895678936946469414 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"227" lat:41.386299 lng:2.187545 score:0.5370804735655128673436 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"971" lat:41.40192 lng:2.200141 score:0.5333078865309969471023 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"1132" lat:41.400425 lng:2.149986 score:0.5317110098647379311222 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"631" lat:41.364746 lng:2.159382 score:0.522287606388757812531 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"226" lat:41.384144 lng:2.177409 score:0.5196580475729424132615 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"635" lat:41.364746 lng:2.155624 score:0.5191689592936082750738 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"901" lat:41.383713 lng:2.18243 score:0.5154555630313201682594 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"961" lat:41.399937 lng:2.121871 score:0.512946737637612377699 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"1504" lat:412357.651 lng:3.50763 score:0.5127012924247508749702 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"925" lat:41.39119 lng:2.165511 score:0.5095150870691734771588 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"923" lat:41.390972 lng:2.173002 score:0.5092501274214534221637 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"768" lat:41.422001 lng:2.119771 score:0.5049006813228455236231 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"707" lat:41.3993 lng:2.110373 score:0.5037095382032114033482 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"668" lat:41.37117 lng:2.151732 score:0.4996037551605042767785 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"941" lat:41.393375 lng:2.184021 score:0.4871454463871992856584 consumingBudget:45]];
        [pois addObject:[[Poi alloc] initWithPoiId:@"1139" lat:41.394596 lng:2.149034 score:0.4868388252256201571276 consumingBudget:45]];
        

        TopSolver *topSolver = [[TopSolver alloc] initWithRouteCount:4 availableBudget:300.0 walkingSpeed:65.0 pois:pois startLat:41.375128 startLng:2.16835 finishLat:41.375128 finishLng:2.16835];
        
        NSDate *methodStart = [NSDate date];
        NSArray *solutionRoutes = [topSolver run:10 :10];
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"executionTime = %f", executionTime);
        

    }
    return 0;
}
