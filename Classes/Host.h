/*
  Host.h
  FlameTouch

  Created by Tom Insam on 24/11/2008.
 
  
  Copyright (c) 2009 Sven-S. Porst, Tom Insam
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  Email flame@jerakeen.org or visit http://jerakeen.org/code/flame-iphone/
  for support.
*/

#import <Foundation/Foundation.h>


@interface Host : NSObject {
  NSString *hostname;
  NSString *ip;
  NSMutableArray *services;
  
}

@property (nonatomic, retain) NSString *hostname;
@property (nonatomic, retain) NSString *ip;
@property (nonatomic, retain) NSMutableArray *services;

-(id)initWithHostname:(NSString*)hn ipAddress:(NSString*)ipAddress;

-(NSString*)name;
-(NSString*)details;
-(NSString*)detailsWithCount;
-(NSNetService*)serviceAtIndex:(int)i;
-(void)addService:(NSNetService*)service;
-(BOOL)hasService:(NSNetService*)service;
-(void)removeService:(NSNetService*)service;
-(int)serviceCount;
-(int)compareByName:(Host*)host;


@end
