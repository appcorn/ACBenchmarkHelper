//  --------------------------------------------
//  The MIT License
//  
//  Copyright 2009 Appcorn AB.
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//  --------------------------------------------
//
//  ACBenchmarkHelper.m
//
//  Created by Martin Alléus on 2009-10-12.
//  Copyright 2009 Appcorn AB.
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
		[benchmarkHelper release];
	}
	return benchmarkHelper;
}

# pragma mark --- Initialization ---


- (id)init {
	if (self = [super init]) {
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
	if (self = [super init]) {
		self.title = aTitle;
		self.timestamp = [NSDate date];
	}
	
	return self;
}

- (void)dealloc {
	self.title = nil;
	self.timestamp = nil;
	
	[super dealloc];
}

@end
