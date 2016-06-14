//
//  TableViewDataManager.h
//  CityGlance
//
//  Created by Enrico Vecchio on 29/12/14.
//  Copyright (c) 2014 Cityglance SRL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewDataManager : NSObject
{
    NSMutableDictionary *datas;
    NSMutableDictionary *cellIdentifierCache;
    NSMutableDictionary *rowHeightsCache;
    NSString* (^cellIdentifierBlock) (NSObject *);
}


#pragma mark - CELL IDENTIFIER

-(void) setCellIdentifierRecognizerForObjects: (NSString* (^)(NSObject *))callback;
-(NSString *) cellIdentierForObject: (NSObject *) obj;
-(NSString *) cellIdentierForObjectUsingCache: (NSObject *) obj;


#pragma mark - COUNT

-(NSInteger) sections;
-(NSInteger) rowsInSection:(NSInteger) section;
-(BOOL) isEmpty;


#pragma mark - DATAS

-(NSArray *) setObjects: (NSMutableArray *) objects inSection: (NSInteger) section;

-(NSIndexPath *) addObject: (NSObject *) obj inSection: (NSInteger) section;
-(NSArray *) addObjects: (NSMutableArray *) objects inSection: (NSInteger) section;

-(NSIndexPath *) removeObject: (NSObject *) obj inSection: (NSInteger) section;
-(NSArray *) removeObjectsfromSection: (NSInteger) section;

-(NSIndexPath *) updateObject: (NSObject *) obj inSection: (NSInteger) section;
-(NSArray *) updateObjects: (NSMutableArray *) objects inSection: (NSInteger) section;

-(NSObject *) objectAtIndexPath: (NSIndexPath *) indexPath;
-(NSMutableArray *) objectsInSection:(NSInteger) section;

-(NSIndexPath *) indexPathOfObject: (NSObject *) o;
-(NSIndexPath *) indexPathOfObject: (NSObject *) o InSection: (NSInteger) section;

#pragma mark - CACHE

-(void) cacheAddHeight: (CGFloat) height forRowAtIndexPath: (NSIndexPath *) ip;
-(void) cacheDeleteElementAtIndexPath: (NSIndexPath *) ip;
-(void) cacheEmpty;
-(CGFloat) cacheGetHeightForRowAtIndexPath: (NSIndexPath *) ip;

#pragma mark - TABLE VIEW UTILS

-(id) dequeueCellWithIdentifier: (NSString *) cellIdentifier andRegisterIfNeededInTableView: (UITableView *) tableView;
-(BOOL) utilsIsLastRowVisible: (UITableView *) tableView;

@end
