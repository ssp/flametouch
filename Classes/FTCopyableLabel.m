/*
 FTCopyableLabel.m
 FlameTouch
 
 Created by Sven-S. Porst on 2010-02-02.
 
 
 Copyright (c) 2010 Sven-S. Porst, Tom Insam
 
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


#import "FTCopyableLabel.h"



@implementation FTCopyableLabel

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  if(action == @selector(copy:)) {
    return YES;
  }
  else {
    return [super canPerformAction:action withSender:sender];
  }
}


- (BOOL)canBecomeFirstResponder {
  return YES;
}


- (void)copy:(id)sender {
  UIPasteboard *board = [UIPasteboard generalPasteboard];
  [board setString:self.text];
  self.highlighted = NO;
  [self resignFirstResponder];
}


/*
 Highlight while we're touched.
*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  self.highlighted = YES;
}


/*
 When touches end, display menu and stop highlighting.
*/
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UIMenuController * menuController = [UIMenuController sharedMenuController];

  CGPoint touchPoint = [[touches anyObject] locationInView:self];
  CGRect clickRect = CGRectMake(touchPoint.x, touchPoint.y, .0, .0);
  
  if([self isFirstResponder]) {
    [menuController setMenuVisible:NO animated:YES];
    [menuController setTargetRect:clickRect inView:self];
    [menuController update];
    [self resignFirstResponder];
  }
  else if([self becomeFirstResponder]) {
    [menuController setTargetRect:clickRect inView:self];
    [menuController setMenuVisible:YES animated:YES];
  }

  self.highlighted = NO;
}


@end
