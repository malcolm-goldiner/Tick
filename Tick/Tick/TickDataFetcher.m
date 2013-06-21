
//
//  DataFetcher.m
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

#import "TickDataFetcher.h"
#import "XMLDictionary.h"
#import "TickProject.h"
#import "TickUser.h"
#import "TickEntry.h"
#import "TickClient.h"

@interface TickDataFetcher()
@end

@implementation TickDataFetcher


- (NSMutableDictionary *) getClients
{
    NSMutableDictionary *cleanDict = [[NSMutableDictionary alloc] init]; 
    if(!self.user.ProjectData) self.user.ProjectData = [self getProjects];
    NSMutableSet *projects = [[NSMutableSet alloc] init];
    for (id project in [self.user.ProjectData allValues]){
        [projects addObject:[project clientName]];
        
    }
    
    int i = 0; 
    for (id name in projects){
        if ([name isKindOfClass:[NSString class]]){
            TickClient *client = [[TickClient alloc] init];
            client.name = name;
            [cleanDict setObject:client forKey:@(i)];
            i++;
            
        }
        
        
    }
    NSMutableArray *clients = [[[cleanDict allValues] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    [cleanDict removeAllObjects];
    for(int i = 0; i < clients.count; i++) {
        [cleanDict setObject:clients[i] forKey:@(i)];
    }
    
    self.user.ClientData = cleanDict;
    return cleanDict;
}


- (NSMutableDictionary *) getProjectsForClient:(TickClient *)client
{
    NSMutableDictionary *localDict;
    int i = 0;
    NSMutableDictionary *cleanDict = [[NSMutableDictionary alloc] init];
    if (!self.user.ProjectData){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@.tickspot.com/api/projects?email=%@@%@.com&password=%@",[self.user company],[self.user username], [self.user company],[self.user password]]];
        
        NSData *webData = [NSData dataWithContentsOfURL:url];
        
        
        
        localDict = [[NSDictionary dictionaryWithXMLData:webData] mutableCopy];
        
        
    
        
        for (id project in [localDict objectForKey:@"project"]){
            if([project isKindOfClass:[NSDictionary class]] && [[project objectForKey:@"client_name"] isEqualToString:[client name]]){
                TickProject *projectObject = [[TickProject alloc] init];
                [projectObject setName:[project objectForKey:@"name"]];
                [projectObject setClientName:[project objectForKey:@"client_name"]];
                NSDictionary *sumHours = [project objectForKey:@"sum_hours"];
                double sum = [[sumHours objectForKey:@"__text"] doubleValue];
                projectObject.sumHours = sum;
                id task = [project objectForKey:@"task"];
                
                
                if ([task isKindOfClass:[NSDictionary class]]){
                    id text = [task objectForKey:@"id"];
                    if ([text isKindOfClass:[NSDictionary class]]){
                        NSString *taskNum = [text objectForKey:@"__text"];
                        float taskIDNumber = [taskNum floatValue];
                        [projectObject setTaskID:taskIDNumber];
                        
                    }
                }
                
                
                id creationDate = [project objectForKey:@"opened_on"];
                if ([creationDate isKindOfClass:[NSDictionary class]]){
                    NSString *startDate = [creationDate objectForKey:@"__text"];
                    [projectObject setCreatedOn:startDate];
                    
                }
                
                id projectID = [project objectForKey:@"id"];
                if([projectID isKindOfClass:[NSDictionary class]]) {
                    NSString *ID = [projectID objectForKey:@"__text"];
                    [projectObject setProjectID:[ID intValue]];
                    
                }
                [cleanDict setObject:projectObject forKey:@(i)];
                
                i++;
            }
        }
        
    } else{
        localDict = [self.user ProjectData];
        for (id project in [localDict allValues]){
            if([[project clientName] isEqualToString:[client name]]){
                [cleanDict setObject:project forKey:@(i)];
                i++;
            }
        }
    }
    
  
    NSMutableArray *projects = [[[cleanDict allValues] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    [cleanDict removeAllObjects];
    for(int i = 0; i < projects.count; i++) {
        [cleanDict setObject:projects[i] forKey:@(i)];
    }
   

    return cleanDict;
    
}


- (NSMutableDictionary *) searchForProjectWithName:(NSString *)name
{
    NSArray *projects = [[self.user projectsForClientData] allValues]
    ;
    NSMutableDictionary *searchResults = [[NSMutableDictionary alloc] init];
    int i = 0; 
    for (TickProject *project in projects) {
        NSRange range = [[[project name] uppercaseString] rangeOfString:[name uppercaseString]];
        if(range.length == 0) NSLog(@"not there");
        else{
            [searchResults setObject:project forKey:@(i)];
            i++;
        }
       
    }
    return searchResults;
    
}

- (NSMutableDictionary *) searchForClientWithName:(NSString *)name
{
    NSArray *clients = [[self.user ClientData] allValues]
    ;
    NSMutableDictionary *searchResults = [[NSMutableDictionary alloc] init];
    int i = 0;
    for (TickClient *client in clients) {
        NSRange range = [[[client name]uppercaseString] rangeOfString:[name uppercaseString]];
        if(range.length == 0) NSLog(@"not there");
        else{
            [searchResults setObject:client forKey:@(i)];
            i++;
        }
        
    }
    return searchResults;
}

- (NSMutableDictionary *) searchForEntryWithNote:(NSString *)note fromView:(NSString *)view
{
    NSMutableDictionary *entries; 
    if ([view isEqualToString:@"entriesForProject"]){
        entries  = [self.user entriesForProjectData];
    } else {
        entries = [self.user entriesForTodayData];
    }
    
   
    NSMutableDictionary *searchResults = [[NSMutableDictionary alloc] init];
    int i = 0;
    for (TickEntry *entry in entries) {
        NSRange range = [[[entry note] uppercaseString] rangeOfString: [note uppercaseString]];
        if(range.length == 0) NSLog(@"not there");
        else{
            [searchResults setObject:entry forKey:@(i)];
            i++;
        }
        
    }
    return searchResults;
}



- (NSMutableDictionary *) getProjects
{
    
    if (!self.user.ProjectData){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@.tickspot.com/api/projects?email=%@@%@.com&password=%@",[self.user company],[self.user username], [self.user company],[self.user password]]];
        
        NSData *webData = [NSData dataWithContentsOfURL:url];
        
        int i = 0;
        
        NSMutableDictionary *localDict = [[NSDictionary dictionaryWithXMLData:webData] mutableCopy];
        
        NSMutableDictionary *cleanDict = [[NSMutableDictionary alloc] init];
        
        
        for (id project in [localDict objectForKey:@"project"]){
            if([project isKindOfClass:[NSDictionary class]]){
                TickProject *projectObject = [[TickProject alloc] init];
                [projectObject setName:[project objectForKey:@"name"]];
                [projectObject setClientName:[project objectForKey:@"client_name"]];
                NSDictionary *sumHours = [project objectForKey:@"sum_hours"];
                double sum = [[sumHours objectForKey:@"__text"] doubleValue];
                projectObject.sumHours = sum;
                id task = [project objectForKey:@"task"];
                
                
                if ([task isKindOfClass:[NSDictionary class]]){
                    id text = [task objectForKey:@"id"];
                    if ([text isKindOfClass:[NSDictionary class]]){
                        NSString *taskNum = [text objectForKey:@"__text"];
                        float taskIDNumber = [taskNum floatValue];
                        [projectObject setTaskID:taskIDNumber];
                        
                    }
                }
                
                
                id creationDate = [project objectForKey:@"opened_on"];
                if ([creationDate isKindOfClass:[NSDictionary class]]){
                    NSString *startDate = [creationDate objectForKey:@"__text"];
                    [projectObject setCreatedOn:startDate];
                    
                }
                
                id projectID = [project objectForKey:@"id"];
                if([projectID isKindOfClass:[NSDictionary class]]) {
                    NSString *ID = [projectID objectForKey:@"__text"];
                    [projectObject setProjectID:[ID intValue]];
                    
                }
                [cleanDict setObject:projectObject forKey:@(i)];
                
                i++;
            }
        }
        
        
        NSMutableArray *projects = [[[cleanDict allValues] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
        [cleanDict removeAllObjects];
        for(int i = 0; i < projects.count; i++) {
            [cleanDict setObject:projects[i] forKey:@(i)];
        }
        
        return cleanDict;
    } else return self.user.ProjectData;
   
}

- (NSString *) getUserFullName
{
    
    if(!self.user.firstName){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@.tickspot.com/api/users?email=%@@%@.com&password=%@",[self.user company],[self.user username], [self.user company],[self.user password]]];
        
        NSData *webData = [NSData dataWithContentsOfURL:url];
        NSMutableDictionary *localDict = [[NSDictionary dictionaryWithXMLData:webData] mutableCopy];
        localDict = [localDict objectForKey:@"user"];
        self.user.firstName = [localDict objectForKey:@"first_name"];
        self.user.lastName = [localDict objectForKey:@"last_name"];
    }
    
    return [NSString stringWithFormat:@"%@ %@", [self.user firstName], [self.user lastName]];
}

- (BOOL) createEntry:(TickEntry *)entry;
{
    NSString *note = [entry note];
    NSRange space = [note rangeOfString:@" "];
    while (space.length != 0) {
        note = [NSString stringWithFormat:@"%@%@%@",[note substringToIndex:space.location],@"+",[note substringFromIndex:space.location+space.length]];
        space = [note rangeOfString:@" "];
    }
    
    
    NSString *date = [[[NSDate date] description] substringToIndex:10];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@.tickspot.com/api/create_entry?email=%@@%@.com&password=%@&task_id=%i&hours=%g&date=%@&notes=%@",[entry.user company], [entry.user username], [entry.user company], [entry.user password], [entry.project taskID], [entry hours], date, note]];
                      
    NSData *webData = [NSData dataWithContentsOfURL:url];
    if(webData) return YES;
    else return NO; 
}

- (NSMutableDictionary *) getEntriesForProject:(TickProject *)project
{
     NSString *date = [[[NSDate date] description] substringToIndex:10];
    
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@.tickspot.com/api/entries?email=%@@%@.com&password=%@&start_date=%@&end_date=%@&project_id=%i",[self.user company], [self.user username], [self.user company], [self.user password], [project createdOn], date, [project projectID]]];
    
   

    NSData *webData = [NSData dataWithContentsOfURL:url];
    
      NSMutableDictionary *localDict = [[NSDictionary dictionaryWithXMLData:webData] mutableCopy];
  
    
    NSArray *entries = [localDict objectForKey:@"entry"];
    int i = entries.count - 1;
    for(id item in entries) {
        if ([item isKindOfClass:[NSDictionary class]]){
            TickEntry *entry = [[TickEntry alloc] init];
            entry.ID = [[[item objectForKey:@"id"] objectForKey:@"__text"] intValue];
            entry.project = project;
            entry.note = [[item objectForKey:@"notes"] objectForKey:@"__text"];
            NSString *date = [[item objectForKey:@"created_at"] objectForKey:@"__text"];
            NSString *day = [date substringToIndex:16];
            entry.dateCreated = day;
            id hours  = [item objectForKey:@"hours"];
            if([hours isKindOfClass:[NSDictionary class]]) {
                entry.hours = [[hours objectForKey:@"__text"] doubleValue];
                [localDict setObject:entry forKey:@(i)];
                i--;
            }
            

        }
               for (id key in [localDict allKeys]){
            if (![[localDict objectForKey:key] isKindOfClass:[TickEntry class]])     {
                [localDict removeObjectForKey:key];
            }
        }
    }
    if (entries)return localDict;
    else return nil; 
}

- (NSMutableDictionary *) getEntriesForToday
{
      NSString *date = [[[NSDate date] description] substringToIndex:10];
    
    
      NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@.tickspot.com/api/entries?email=%@@%@.com&password=%@&start_date=%@&end_date=%@",[self.user company], [self.user username], [self.user company], [self.user password], date, date]];
    
    
    
    NSData *webData = [NSData dataWithContentsOfURL:url];
    
    NSMutableDictionary *localDict = [[NSDictionary dictionaryWithXMLData:webData] mutableCopy];
    int i = 0;
    
    NSArray *entries = [localDict objectForKey:@"entry"];
    for(id item in entries) {
        if([item isKindOfClass:[NSDictionary class]]){
            TickEntry *entry = [[TickEntry alloc] init];
            TickProject *project = [[TickProject alloc] init];
            project.name = [item objectForKey:@"project_name"];
            project.clientName = [item objectForKey:@"client_name"];
            project.sumHours = [[[item objectForKey:@"sum_hours"] objectForKey:@"__text"] doubleValue];
            entry.project = project;
            entry.note = [[item objectForKey:@"notes"] objectForKey:@"__text"];
            NSString *date = [[item objectForKey:@"created_at"] objectForKey:@"__text"];
            NSString *day = [date substringToIndex:16];
            entry.dateCreated = day;
            id hours  = [item objectForKey:@"hours"];
            if([hours isKindOfClass:[NSDictionary class]]) {
                entry.hours = [[hours objectForKey:@"__text"] doubleValue];
                [localDict setObject:entry forKey:@(i)];
                i++;
            }
        }
       
        
        for (id key in [localDict allKeys]){
            if (![[localDict objectForKey:key] isKindOfClass:[TickEntry class]])     {
                [localDict removeObjectForKey:key];
            }
        }
    }
    if (entries)return localDict;
    else return nil;
    
}

- (TickEntry *) updateEntry:(TickEntry *)entry
{
    
    NSString *note = [entry note];
    NSRange space = [note rangeOfString:@" "];
    while (space.length != 0) {
        note = [NSString stringWithFormat:@"%@%@%@",[note substringToIndex:space.location],@"+",[note substringFromIndex:space.location+space.length]];
         space = [note rangeOfString:@" "];
    }
    
    NSString *url = [NSString stringWithFormat:@"https://%@.tickspot.com/api/update_entry?email=%@@%@.com&password=%@&id=%i&notes=%@&hours=%g",[self.user company], [self.user username], [self.user company], [self.user password], [entry ID],note,[entry hours]];
  
	
    NSData *Data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if(Data) {
        NSDictionary *newEntries = [self getEntriesForProject:entry.project];
        
        for (TickEntry *newEntry in [newEntries allValues]) {
            if([newEntry ID] == [entry ID]) return newEntry;
        }
    } 
    return nil; 
}



@end
