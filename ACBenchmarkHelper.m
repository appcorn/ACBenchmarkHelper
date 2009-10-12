//
//  ACBenchmarkHelper.m
//
//  Created by Martin Alléus on 2009-10-12.
//  Copyright 2009 Appcorn AB. All rights reserved.
//

#import "ACBenchmarkHelper.h"


@implementation ACBenchmarkHelper


# pragma mark --- Singelton Methods ---

static NSMutableDictionary *benchmarkHelpers = nil;

+ (ACBenchmarkHelper *)sharedBenchmarkHelperForCurrentThread {
	if(benchmarkHelpers == nil) {
		benchmarkHelpers = [[NSMutableDictionary alloc] init];
	}
	
	NSString *hash = [NSString stringWithFormat:@"%lu", [[NSThread currentThread] hash]];
	ACBenchmarkHelper *benchmarkHelper = [benchmarkHelpers objectForKey:hash];
	
	if (!benchmarkHelper) {
		benchmarkHelper = [[self alloc] init];
		[benchmarkHelpers setObject:benchmarkHelper forKey:hash];
	}
	return benchmarkHelper;
}

# pragma mark --- Initialization ---


- (id)init {
	[super init];
	
	if (self) {
		marks = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc {
	[marks release];
	
	[super dealloc];
}


# pragma mark --- Static convinience-methods ---

+ (void)mark:(NSString *)title {
	ACBenchmarkHelper *instance = [ACBenchmarkHelper sharedBenchmarkHelperForCurrentThread];
	[instance mark:title];
}

+ (void)report {
	ACBenchmarkHelper *instance = [ACBenchmarkHelper sharedBenchmarkHelperForCurrentThread];
	[instance report];
}

# pragma mark --- Custom Methods ---

- (void)mark:(NSString *)title {
	ACBenchmarkMark *mark = [[ACBenchmarkMark alloc] initWithTitle:title];
	[marks addObject:mark];
	[mark release];
}

- (void)report {
	NSDate *endTime = [NSDate date];
	
	printf(" ┌────────────────────────────────────────────────────────────┐\n");
	printf(" │Benchmark Report                                  %4d marks│\n", [marks count]);
	printf(" ├────────────────────────────────────────┬─────────┬─────────┤\n");
	printf(" │Title                                   │Time (s) │Total (s)│\n");
	printf(" ├────────────────────────────────────────┼─────────┼─────────┤\n");
	
	if ([marks count] > 0) {
		ACBenchmarkMark *mark = [marks objectAtIndex:0];
		NSString *lastTitle = mark.title;
		NSDate *lastTimestamp = mark.timestamp;
		NSTimeInterval total = 0, interval;
		NSUInteger i, count = [marks count];
		for (i = 1; i < count + 1; i++) {
			if (i != count) {
				mark = [marks objectAtIndex:i];
			}
			
			if (i != count) {
				interval = [mark.timestamp timeIntervalSinceDate:lastTimestamp];
			} else {
				interval = [endTime timeIntervalSinceDate:lastTimestamp];
			}
			
			total += interval;
			
			printf(" |%-40.40s|%8.4f |%8.4f | ", [lastTitle cStringUsingEncoding:NSUTF8StringEncoding], interval, total);
			
			NSUInteger j, size = interval * 100;
			for (j = 0; j < size && j < 50; j++) {
				printf("▒");
			}
			if (size > 50) {
				printf("...");
			}
			
			printf("\n");
			
			if (i != count) {
				lastTitle = mark.title;
				lastTimestamp = mark.timestamp;
			}
		}
	}

	printf(" └────────────────────────────────────────┴─────────┴─────────┘\n");
	
	[marks removeAllObjects];
}

@end


@implementation ACBenchmarkMark

@synthesize title;
@synthesize timestamp;

- (id)initWithTitle:(NSString *)aTitle {
	[super init];
	
	if (self) {
		self.title = aTitle;
		self.timestamp = [NSDate date];
	}
	
	return self;
}

@end
