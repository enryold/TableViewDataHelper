//
//  TableViewDataManager.m
//  CityGlance
//
//  Created by Enrico Vecchio on 29/12/14.
//  Copyright (c) 2014 Cityglance SRL. All rights reserved.
//

#import "TableViewDataManager.h"

@implementation TableViewDataManager


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        datas = [NSMutableDictionary dictionary];
        rowHeightsCache = [NSMutableDictionary dictionary];
        cellIdentifierCache = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - PUBLIC

-(void) setCellIdentifierRecognizerForObjects: (NSString* (^)(NSObject *))callback
{
    cellIdentifierBlock = callback;
}

-(NSString *) cellIdentierForObject: (NSObject *) obj
{
    return cellIdentifierBlock(obj);
}

-(NSString *) cellIdentierForObjectUsingCache: (NSObject *) obj
{
    NSString *objKey = [NSString stringWithFormat:@"%ld", obj.hash];
    NSString *cellIdentifier = [cellIdentifierCache objectForKey:objKey];
    
    if(cellIdentifier != nil) { return cellIdentifier; }
    
    cellIdentifier = cellIdentifierBlock(obj);
    [cellIdentifierCache setObject:cellIdentifier forKey:objKey];
    
    return cellIdentifier;
}


#pragma mark - COUNT

-(NSInteger) sections
{
    return [[datas allKeys] count];
}

-(NSInteger) rowsInSection:(NSInteger) section
{
    return [[self objectsInSection:section] count];
}

-(BOOL) isEmpty
{
    for(NSInteger i=0; i<[self sections]; i++)
    {
        if([self rowsInSection:i] > 0) { return NO; }
    }
    
    return YES;
}


#pragma mark - DATAS


-(NSIndexPath *) addObject: (NSObject *) obj inSection: (NSInteger) section
{
    NSNumber *key = [self utilsKeyForSection:section];
    NSMutableArray *a = [datas objectForKey:key];
    
    if(!a) { a = [NSMutableArray array]; }
    
    NSInteger lastRow = [a count];
    
    [a addObject:obj];
    [datas setObject:a forKey:key];
    
    return [NSIndexPath indexPathForRow:lastRow inSection:section];
}

-(NSArray *) addObjects: (NSMutableArray *) objects inSection: (NSInteger) section
{
    
    NSNumber *key = [self utilsKeyForSection:section];
    NSMutableArray *a = [datas objectForKey:key];
    
    if(!a) { a = [NSMutableArray array]; }
    if(![objects count]) { objects = [NSMutableArray array]; }
    
    NSInteger lastOldRow = [a count];
    
    a = [[a arrayByAddingObjectsFromArray:objects] mutableCopy];
    
    [datas setObject:a forKey:key];
    
    return [self utilsBuildArrayOfIndexPathsFromRow:lastOldRow withOffset:[objects count] forSection:section];
    
    
}


-(NSArray *) setObjects: (NSMutableArray *) objects inSection: (NSInteger) section
{
    NSNumber *key = [self utilsKeyForSection:section];
    NSMutableArray *a = [NSMutableArray array];
    
    NSInteger lastOldRow = [a count];
    
    a = [[a arrayByAddingObjectsFromArray:objects] mutableCopy];
    
    [datas setObject:a forKey:key];
    
    return [self utilsBuildArrayOfIndexPathsFromRow:lastOldRow withOffset:[objects count] forSection:section];
    
}




-(NSIndexPath *) removeObject: (NSObject *) obj inSection: (NSInteger) section
{
    NSNumber *key = [self utilsKeyForSection:section];
    NSMutableArray *a = [datas objectForKey:key];
    
    NSInteger index = [a indexOfObject:obj];
    
    if(index == NSNotFound) { return nil; }
    
    [a removeObject:obj];
    
    return [NSIndexPath indexPathForRow:index inSection:section];
}

-(NSArray *) removeObjectsfromSection: (NSInteger) section
{
    NSNumber *key = [self utilsKeyForSection:section];
    NSMutableArray *a = [datas objectForKey:key];
    NSInteger offset = [a count];
    [datas removeObjectForKey:key];
    
    return [self utilsBuildArrayOfIndexPathsFromRow:0 withOffset:offset forSection:section];
}



-(NSIndexPath *) updateObject: (NSObject *) obj inSection: (NSInteger) section
{
    NSNumber *key = [self utilsKeyForSection:section];
    NSMutableArray *a = [datas objectForKey:key];
    
    NSInteger index = [a indexOfObject:obj];
    
    if(index == NSNotFound) { return nil; }
    
    [a setObject:obj atIndexedSubscript:index];
    
    return [NSIndexPath indexPathForRow:index inSection:section];
}

-(NSArray *) updateObjects: (NSMutableArray *) objects inSection: (NSInteger) section
{
    NSNumber *key = [self utilsKeyForSection:section];
    NSMutableArray *a = [datas objectForKey:key];
    
    if(!a) { return [self addObjects:objects inSection:section]; }
    
    NSMutableArray *sub = [NSMutableArray array];
    
    for(NSObject *o in objects)
    {
        NSIndexPath *ip = [self updateObject:o inSection:section];
        [sub addObject:ip];
    }
    
    return sub;
}


-(NSIndexPath *) indexPathOfObject: (NSObject *) o
{
    for(NSNumber *key in [datas allKeys])
    {
        NSIndexPath *indexPath = [self indexPathOfObject:o InSection:key.integerValue];
        if(indexPath != nil) { return indexPath; }
    }
    
    return nil;
}


-(NSIndexPath *) indexPathOfObject: (NSObject *) o InSection: (NSInteger) section
{
    NSNumber *key = [self utilsKeyForSection:section];
    NSMutableArray *a = [datas objectForKey:key];
    NSInteger row = [a indexOfObject:o];
    
    if(row == NSNotFound) { return nil; }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}


-(NSObject *) objectAtIndexPath: (NSIndexPath *) indexPath
{
    NSNumber *key = [self utilsKeyForSection:indexPath.section];
    NSMutableArray *a = [datas objectForKey:key];
    return [a objectAtIndex:indexPath.row];
}

-(NSMutableArray *) objectsInSection:(NSInteger) section
{
    NSNumber *key = [self utilsKeyForSection:section];
    NSMutableArray *a = [datas objectForKey:key];
    return (a != nil) ? a : [NSMutableArray array];
}


#pragma mark - CACHE

-(void) cacheAddHeight: (CGFloat) height forRowAtIndexPath: (NSIndexPath *) ip
{
    NSString *key = [self cacheKeyForIndexPath:ip];
    [rowHeightsCache setObject:[NSNumber numberWithFloat:height] forKey:key];
}

-(CGFloat) cacheGetHeightForRowAtIndexPath: (NSIndexPath *) ip
{
    NSString *key = [self cacheKeyForIndexPath:ip];
    id o = [rowHeightsCache objectForKey:key];
    
    return (o) ? [o floatValue] : -1;
}

-(void) cacheDeleteElementAtIndexPath: (NSIndexPath *) ip
{
    NSString *key = [self cacheKeyForIndexPath:ip];
    [rowHeightsCache removeObjectForKey:key];
}

-(void) cacheEmpty
{
    [rowHeightsCache removeAllObjects];
}

-(NSString *) cacheKeyForIndexPath: (NSIndexPath *) ip
{
    return [NSString stringWithFormat:@"%ld-%ld", ip.section, ip.row];
}


#pragma mark - TABLE VIEW UTILS

-(id) dequeueCellWithIdentifier: (NSString *) cellIdentifier andRegisterIfNeededInTableView: (UITableView *) tableView
{
    UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!c)
    {
        UINib *nib = [UINib nibWithNibName:cellIdentifier bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        c = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    return c;
}





#pragma - PRIVATE UTILS


-(NSNumber *) utilsKeyForSection: (NSInteger) section
{
    return [NSNumber numberWithInteger:section];
}

-(NSArray *) utilsBuildArrayOfIndexPathsFromRow: (NSInteger) row withOffset: (NSInteger) offset forSection: (NSInteger) section
{
    NSMutableArray *sub = [NSMutableArray array];
    
    for(NSInteger i=row; i < row+offset; i++)
    {
        [sub addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    return sub;
}

-(BOOL) utilsIsLastRowVisible: (UITableView *) tableView
{
    NSArray *indexes = [tableView indexPathsForVisibleRows];
    
    NSInteger lastSection = [self sections]-1;
    NSInteger lastRow = [self rowsInSection:lastSection];
    
    for (NSIndexPath *index in indexes)
    {
        if(index.section != lastSection) { continue; }
        if(index.row == lastRow-1) { return YES; }
    }
    
    return NO;
}


@end
