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
//  ACBenchmarkHelper.h
//
//  Created by Martin Alléus on 2009-10-12.
//  Copyright 2009 Appcorn AB.
//
//	Class description:
//	--------------------------------------------
//	This class provides benchmarking functionality to be used to track
//  time consumtion of code. The class can be used either in a static
//  manner (for example, just calling [ACBenchmarkHelper mark:@"test"])
//  or as a instanced object.
//  
//  The static methods measure time seperately in different threads.
//	
//	Varible description:
//	--------------------------------------------
//	benchmarkHelpers:	Static dictionary of ACBenchmarkHelper instances.
//						The instances are seperated by the thread calling the
//						+ (ACBenchmarkHelper *)sharedBenchmarkHelperForCurrentThread
//						method.
//	marks:				Array of marks that are made with the - (void)mark: method.
//  

#import <Foundation/Foundation.h>


@interface ACBenchmarkHelper : NSObject {
	NSMutableArray	*marks;
}


# pragma mark --- Singleton methods ---

/* Singelton method to access a static, shared instance of the class.
   Note that this method returns a new benchmark helper for every thread.
   You should not call this method directly, use + (void)mark: and
   + (void)report instead. */

+ (ACBenchmarkHelper *)sharedBenchmarkHelperForCurrentThread;


# pragma mark --- Static convinience-methods ---

/* Convinience-method to add a benchmark mark.
   See - (void)mark: for more information */

+ (void)mark:(NSString *)title;

/* Convinience-method for print the benchmark report to the console.
   See - (void)report for more information */

+ (void)report;


# pragma mark --- Custom methods ---

/* Adds a benchmark mark with the current timestamp to the list of benchmarks.
   By marking, you tell the Benchmark helper to measure the time from this mark
   until the mark made. The last mark is measured until the report method is
   called. */

- (void)mark:(NSString *)title;

/* Prints the benchmark results summary to the console (via printf).
   Reports are printed in a fancy table. */

- (void)report;

@end


//  
//	Class description:
//	--------------------------------------------
//	Small class for storing information about a benchmark timing mark
//	
//	Varible description:
//	--------------------------------------------
//	title:		The title of the mark
//	timestamp:	The timestamp of the mark
//  


@interface ACBenchmarkMark : NSObject {
	NSString	*title;
	NSDate		*timestamp;
}

@property(retain) NSString *title;
@property(retain) NSDate *timestamp;

/* Initiates a mark, setting the title to the specified string
   and the timestamp to the current time */

- (id)initWithTitle:(NSString *)aTitle;

@end