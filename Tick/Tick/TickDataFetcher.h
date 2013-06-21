//
//  DataFetcher.h
//  Tick
//
//  Created by Malcolm Goldiner on 6/4/13.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "XMLDictionary.h"
#import "TickUser.h"
#import "TickEntry.h"
#import "TickClient.h"

@interface TickDataFetcher : NSObject

@property (strong,nonatomic) TickUser *user;


- (NSMutableDictionary *) getProjects;
- (NSString *) getUserFullName;
- (BOOL) createEntry:(TickEntry *)entry;
- (NSMutableDictionary *) getEntriesForProject:(TickProject *)project;
- (NSMutableDictionary *) getEntriesForToday;
- (NSMutableDictionary *) getClients;
- (NSMutableDictionary *) getProjectsForClient:(TickClient *)client;
- (TickEntry *) updateEntry:(TickEntry *)entry;
- (NSMutableDictionary *) searchForProjectWithName:(NSString *)prefix;
- (NSMutableDictionary *) searchForClientWithName:(NSString *)prefix;
- (NSMutableDictionary *) searchForEntryWithNote:(NSString *)note;




@end
