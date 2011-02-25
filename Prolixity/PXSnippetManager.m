//
// PXSnippetManager.m
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

#import "PXSnippetManager.h"
#import "PXRuntime.h"

static NSString *const kSnippetListKey = @"SnippetList_1.0";
static NSString *const kSnippetStorageKey = @"SnippetStorage_1.0";

static NSString *const kSnippetObjectContentKey = @"Content";
static NSString *const kSnippetObjectDescriptionKey = @"Content";
static NSString *const kSnippetObjectTitleKey = @"Title";

@interface PXSnippetManager ()
- (void)writeBack;
@end

@implementation PXSnippetManager
@synthesize firstTimeUser;

- (void)dealloc
{
    [snippetList release], snippetList = nil;
    [snippetStorage release], snippetStorage = nil;
    [super dealloc];
}

+ (PXSnippetManager *)sharedManager
{
	static PXSnippetManager *instance = nil;
	@synchronized(self) {
		if (!instance) {
			instance = [[PXSnippetManager alloc] init];
		}
	}

	return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:kSnippetListKey];
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kSnippetStorageKey];
        
        if (!list && !dict) {
            firstTimeUser = YES;
        }
        
        if (![list isKindOfClass:[NSArray class]] || ![dict isKindOfClass:[NSDictionary class]]) {
            list = [NSArray array];
            dict = [NSDictionary dictionary];
        }
        
        snippetList = [list mutableCopy];
        snippetStorage = [dict mutableCopy];
        
        // TODO: Sync to see if there's anything in dict that's missing in list, and vice versa
    }
    return self;
}

- (NSUInteger)snippetCount
{
    return [snippetList count];
}

- (NSString *)snippetIDAtIndex:(NSUInteger)index
{
    return [snippetList objectAtIndex:index];
}

- (NSString *)createSnippet
{
    NSMutableDictionary *snippet = [NSMutableDictionary dictionary];
    NSString *identifier = [NSString generateUniqueIdentifier];
    
    
    [snippet setObject:@"" forKey:kSnippetObjectContentKey];
    [snippet setObject:@"" forKey:kSnippetObjectDescriptionKey];
    [snippet setObject:PXLSTR(@"New Snippet") forKey:kSnippetObjectTitleKey];
    
    [snippetStorage setObject:snippet forKey:identifier];
    [snippetList addObject:identifier];
    return identifier;
}

- (NSString *)snippetTitleForID:(NSString *)identifier
{
    return [[snippetStorage objectForKey:identifier] objectForKey:kSnippetObjectTitleKey];
}

- (void)setSnippetTitle:(NSString *)snippet forSnippetID:(NSString *)identifier
{
    return [[snippetStorage objectForKey:identifier] setValue:snippet forKey:kSnippetObjectTitleKey];
}

- (NSString *)snippetDescriptionForID:(NSString *)identifier
{
    return [[snippetStorage objectForKey:identifier] objectForKey:kSnippetObjectDescriptionKey];
}

- (void)setSnippetDescription:(NSString *)snippet forSnippetID:(NSString *)identifier
{
    return [[snippetStorage objectForKey:identifier] setValue:snippet forKey:kSnippetObjectDescriptionKey];
}


- (NSString *)snippetForID:(NSString *)identifier
{
    return [[snippetStorage objectForKey:identifier] objectForKey:kSnippetObjectContentKey];
}

- (void)setSnippet:(NSString *)snippet forSnippetID:(NSString *)identifier
{
    return [[snippetStorage objectForKey:identifier] setValue:snippet forKey:kSnippetObjectContentKey];
}

- (void)markFirstTimeDataAsPopulated
{
    firstTimeUser = NO;
}

- (void)writeBack
{
    [[NSUserDefaults standardUserDefaults] setObject:snippetList forKey:kSnippetListKey];
    [[NSUserDefaults standardUserDefaults] setObject:snippetStorage forKey:kSnippetStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
