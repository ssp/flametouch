/*
 FTCopyableLabel.h
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

/*
 Idea and code starting from that at:
 http://stackoverflow.com/questions/1920541/enable-copy-and-paste-on-uitextfield-without-making-it-editable
 
 Changes applied to that include:
 
 1. label will now not be highlighted once the copy button appears
 2. highlight will now go away when the user dismisses the copy button
 (1 is a consequence of making 2 work, the original behaviour seems rather bad)
 3. make copy appear at the location of the touch
*/


#import <UIKit/UIKit.h>

@interface FTCopyableLabel : UILabel {

}

@end
