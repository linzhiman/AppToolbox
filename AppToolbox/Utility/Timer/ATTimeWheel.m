//
//  ATTimeWheel.m
//  AppToolbox
//
//  Created by linzhiman on 2020/6/1.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATTimeWheel.h"
#import "ATGlobalMacro.h"
#import "ATGCDTimer.h"

#define ATTW_NOW ((long)([[NSDate date] timeIntervalSince1970] * 1000))

//#define ATTW_TRACE

#ifdef ATTW_TRACE
#define ATTW_TRACE_DEALLOC - (void)dealloc{NSLog(@"dealloc %@", self);}
#else
#define ATTW_TRACE_DEALLOC
#endif

@class ATTWTimerTaskList;
@class ATTimeWheel;

@interface ATTWTimerTaskEntry : NSObject

@property (nonatomic, strong) ATTWTimerTask *task;
@property (nonatomic, assign) long expirationMs;

@property (nonatomic, strong) ATTWTimerTaskList *list;
@property (nonatomic, strong) ATTWTimerTaskEntry *prev;
@property (nonatomic, strong) ATTWTimerTaskEntry *next;

+ (instancetype)timeTaskEntryWithTask:(ATTWTimerTask *)task expirationMs:(long)expirationMs;
- (BOOL)cancelled;
- (void)remove;

@end

typedef void (^ATTWTimerTaskListFlushCB)(ATTWTimerTaskEntry *entry);

@interface ATTWTimerTaskList : NSObject

@property (nonatomic, assign) long expirationMs;
@property (nonatomic, strong) ATTWTimerTaskEntry *root;
@property (nonatomic, weak) ATTimeWheel *timeWheel;

- (void)addEntry:(ATTWTimerTaskEntry *)entry;
- (void)removeEntry:(ATTWTimerTaskEntry *)entry;
- (void)flushWithBlock:(ATTWTimerTaskListFlushCB)block;
- (long)getDelay;

@end


@interface ATTWTimerTask ()

@property (nonatomic, weak) ATTWTimerTaskEntry *entry;

@end

@implementation ATTWTimerTask

ATTW_TRACE_DEALLOC

- (void)cancel
{
    if (self.entry != nil) {
        [self.entry remove];
        self.entry = nil;
    }
}

- (void)setTimerTaskEntry:(ATTWTimerTaskEntry *)entry
{
    if (_entry != nil && _entry != entry) {
        [_entry remove];
    }
    _entry = entry;
}

@end


@implementation ATTWTimerTaskEntry

+ (instancetype)timeTaskEntryWithTask:(ATTWTimerTask *)task expirationMs:(long)expirationMs
{
    ATTWTimerTaskEntry *tmp = [ATTWTimerTaskEntry new];
    tmp.task= task;
    tmp.expirationMs = expirationMs;
    return tmp;
}

ATTW_TRACE_DEALLOC

- (BOOL)cancelled
{
    return self.task.entry != self;
}

- (void)remove
{
    ATTWTimerTaskList *currentList = self.list;
    while (currentList != nil) {
        [currentList removeEntry:self];
        currentList = self.list;
    }
}

- (void)setTask:(ATTWTimerTask *)task
{
    _task = task;
    if (task != nil) {
        task.entry = self;
    }
}

@end


@implementation ATTWTimerTaskList

- (instancetype)init
{
    self = [super init];
    if (self) {
        _expirationMs = -1;
        _root = [ATTWTimerTaskEntry timeTaskEntryWithTask:nil expirationMs:-1];
        _root.next = _root;
        _root.prev = _root;
    }
    return self;
}

ATTW_TRACE_DEALLOC

- (void)addEntry:(ATTWTimerTaskEntry *)entry
{
    BOOL done = NO;
    while (!done) {
        [entry remove];
        if (entry.list == nil) {
            ATTWTimerTaskEntry *tail = self.root.prev;
            entry.next = self.root;
            entry.prev = tail;
            entry.list = self;
            tail.next = entry;
            self.root.prev = entry;
            done = YES;
        }
    }
}

- (void)removeEntry:(ATTWTimerTaskEntry *)entry
{
    if (entry.list == self) {
        entry.next.prev = entry.prev;
        entry.prev.next = entry.next;
        entry.next = nil;
        entry.prev = nil;
        entry.list = nil;
    }
}

- (void)flushWithBlock:(ATTWTimerTaskListFlushCB)block
{
    ATTWTimerTaskEntry *head = self.root.next;
    while (head != self.root) {
        [self removeEntry:head];
        AT_SAFETY_CALL_BLOCK(block, head);
        head = self.root.next;
    }
    self.expirationMs = -1;
}

- (long)getDelay
{
    return MAX(self.expirationMs - ATTW_NOW, 0);
}

@end

@interface ATTimeWheel : NSObject

+ (instancetype)timeWheelWithTickMs:(long)tickMs wheelSize:(int)wheelSize startMs:(long)startMs;

@property (nonatomic, assign) long tickMs;
@property (nonatomic, assign) int wheelSize;
@property (nonatomic, assign) long startMs;
@property (nonatomic, assign) long interval;
@property (nonatomic, assign) long currentTime;
@property (nonatomic, strong) NSMutableArray<ATTWTimerTaskList *> *buckets;
@property (nonatomic, strong) ATTimeWheel *overflowWheel;

@end

@implementation ATTimeWheel

+ (instancetype)timeWheelWithTickMs:(long)tickMs wheelSize:(int)wheelSize startMs:(long)startMs
{
    ATTimeWheel *timeWheel = [ATTimeWheel new];
    timeWheel.tickMs = tickMs;
    timeWheel.wheelSize = wheelSize;
    timeWheel.startMs = startMs;
    timeWheel.interval = tickMs * wheelSize;
    timeWheel.currentTime = startMs;
    timeWheel.buckets = [NSMutableArray new];
    for(int i = 0; i < wheelSize; ++i) {
        ATTWTimerTaskList *bucket = [ATTWTimerTaskList new];
        bucket.timeWheel = timeWheel;
        [timeWheel.buckets addObject:bucket];
    }
    return timeWheel;
}

ATTW_TRACE_DEALLOC

- (void)addOverflowWheel
{
    if (self.overflowWheel == nil) {
        self.overflowWheel = [ATTimeWheel timeWheelWithTickMs:self.interval wheelSize:self.wheelSize startMs:self.currentTime];
    }
}

- (ATTWTimerTaskList *)addEntry:(ATTWTimerTaskEntry *)entry
{
    [self advanceClock:(ATTW_NOW - self.currentTime) / self.tickMs * self.tickMs + self.currentTime];
    
    if (entry.task.delayMs == 1000) {
        ;;
    }
    
    long expirationMs = entry.expirationMs;
    
    if (entry.cancelled) {
        // Cancelled
        return nil;
    }
    else if (expirationMs < self.currentTime + self.tickMs) {
        // Already expired
        return nil;
    }
    else if (expirationMs < self.currentTime + self.interval) {
        // Put in its own bucket
        long virtualId = (expirationMs - self.startMs) / self.tickMs;
        
        ATTWTimerTaskList *bucket = self.buckets[(virtualId % self.wheelSize)];
        [bucket addEntry:entry];
        
        // Set the bucket expiration time
        bucket.expirationMs = virtualId * self.tickMs + self.startMs;
        return bucket;
    }
    else {
        // Out of the interval. Put it into the parent timer
        [self addOverflowWheel];
        return [self.overflowWheel addEntry:entry];
    }
}

- (void)advanceClock:(long)timeMs
{
    if (timeMs >= self.currentTime + self.tickMs) {
        self.currentTime = timeMs;
        
        // Try to advance the clock of the overflow wheel if present
        if (self.overflowWheel != nil) {
            [self.overflowWheel advanceClock:self.currentTime];
        }
    }
}

- (void)trace
{
    NSLog(@"ATTimeWheel tickMs(%@)", @(self.tickMs));
    for (ATTWTimerTaskList *tmp in self.buckets) {
        NSMutableString *text = [NSMutableString stringWithString:@"bucket->root"];
        ATTWTimerTaskEntry *head = tmp.root.next;
        while (head != tmp.root) {
            [text appendFormat:@"->(%@)", @(head.task.delayMs)];
            head = head.next;
        }
        NSLog(@"%@", text);
    }
    if (self.overflowWheel != nil) {
        [self.overflowWheel trace];
    }
}

@end


@interface ATTimeWheelTimer ()

@property (nonatomic, strong) ATTimeWheel *timingWheel;

@end

@implementation ATTimeWheelTimer

+ (instancetype)timeWithTickMs:(long)tickMs wheelSize:(int)wheelSize
{
    ATTimeWheelTimer *tmp = [ATTimeWheelTimer new];
    tmp.timingWheel = [ATTimeWheel timeWheelWithTickMs:tickMs wheelSize:wheelSize startMs:ATTW_NOW];
    return tmp;
}

ATTW_TRACE_DEALLOC

- (void)addTimerTaskEntry:(ATTWTimerTaskEntry *)entry
{
    ATTWTimerTaskList *bucket = [self.timingWheel addEntry:entry];
    if (bucket == nil) {
        // Already expired or cancelled
        if (!entry.cancelled) {
            AT_SAFETY_CALL_BLOCK(entry.task.action);
        }
    }
    else {
        long adjust = (ATTW_NOW - self.timingWheel.startMs) % self.timingWheel.tickMs;
        double delaySeconds = (bucket.expirationMs - self.timingWheel.currentTime - adjust) * 1.0 / 1000;
        
        AT_WEAKIFY_SELF;
        __block ATGCDTimer *timer = [ATGCDTimer scheduleTimer:delaySeconds timeout:^{
            if (bucket != nil) {
                [weak_self advanceClock:bucket];
            }
            timer = nil;
        } repeats:NO];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (bucket != nil) {
//                [weak_self advanceClock:bucket];
//            }
//        });
    }
}

- (void)addTask:(ATTWTimerTask *)task
{
    [self addTimerTaskEntry:[ATTWTimerTaskEntry timeTaskEntryWithTask:task expirationMs:task.delayMs + ATTW_NOW]];
#ifdef ATTW_TRACE
    [self.timingWheel trace];
#endif
}

/*
* Advances the clock if there is an expired bucket. If there isn't any expired bucket when called,
* waits up to timeoutMs before giving up.
*/
- (void)advanceClock:(ATTWTimerTaskList *)bucket
{
    [self.timingWheel advanceClock:bucket.expirationMs];
    AT_WEAKIFY_SELF;
    [bucket flushWithBlock:^(ATTWTimerTaskEntry *entry) {
        [weak_self addTimerTaskEntry:entry];
    }];
}

- (void)shutdown
{
    ;;
}

@end

