//
//  NEHTTPModelManager.h
//  NetworkEye
//
//  Created by coderyi on 15/11/4.
//  Copyright © 2015年 coderyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NetworkModel;
@interface NEHTTPModelManager : NSObject
{
    NSMutableArray *allRequests;
    BOOL enablePersistent;
}

@property(nonatomic,strong) NSString *sqlitePassword;
@property(nonatomic,assign) int saveRequestMaxCount;

/**
 *  get recorded requests 's SQLite filename
 *
 *  @return filename
 */
+ (NSString *)filename;

/**
 *  get NEHTTPModelManager's singleton object
 *
 *  @return singleton object
 */
+ (NEHTTPModelManager *)defaultManager;

/**
 *  create NEHTTPModel table
 */
- (void)createTable;


/**
 *  add a NEHTTPModel object to SQLite
 *
 *  @param aModel a NEHTTPModel object
 */
- (void)addModel:(NetworkModel *) aModel;

/**
 *  get SQLite all NEHTTPModel object
 *
 *  @return all NEHTTPModel object
 */
- (NSMutableArray *)allobjects;

/**
 *  delete all SQLite records
 */
- (void) deleteAllItem;

- (NSMutableArray *)allMapObjects;
- (void)addMapObject:(NetworkModel *)mapReq;
- (void)removeMapObject:(NetworkModel *)mapReq;
- (void)removeAllMapObjects;

@end
