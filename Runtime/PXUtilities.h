//
// PXUtilities.h
//
// Copyright (c) 2011 Lukhnos D. Liu (http://lukhnos.org)
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

#define PXRetainAssign(foo, bar)    do { id tmp = (foo); foo = [(id)(bar) retain]; [tmp release]; } while(0)
#define PXReleaseClean(foo)         do { id tmp = (foo); foo = nil; [tmp release]; } while(0)
#define PXAutoreleasedCopy(foo)     [[(foo) copy] autorelease]
#define PXAutoreleasedRetain(foo)   [[(foo) retain] autorelease]

#define PXLSTR(key)                 NSLocalizedString((key), nil)

#define PXUIntObj(n)				([NSNumber numberWithUnsignedInteger:(n)])
#define PXBoolObj(b)				((b) ? (id)kCFBooleanTrue : (id)kCFBooleanFalse)
#define PXUIntString(u)				([NSString stringWithFormat:@"%ju", (uintmax_t)u])

// for dealing with the repeated scenario: if (outError) { *outError = value; }
#define PXSetOutParam(k, v)         do { if ((k)) { *(k) = (v); } } while (0)

// probably not for time-critical code path, but this gives you a nice warning with refactoring
#define PXSelKey(s)					(NSStringFromSelector(s))
