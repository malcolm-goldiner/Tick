
//
//  MHNYCTickProjectListViewController.m
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

#import "TickProjectListViewController.h"

#import "TickProjectViewController.h"



@interface TickProjectListViewController () 
   


@property (nonatomic, strong) UIApplication *thisApplication;
@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) BOOL searching;
@property (nonatomic) BOOL showsCancelButton; 
@end

@implementation TickProjectListViewController

#pragma mark - Search Bar Controller

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
     [self.searchBar setShowsCancelButton:YES];
    return YES;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.searching = YES;
    TickDataFetcher *fetcher = [[TickDataFetcher alloc] init];
    fetcher.user = self.user; 
     self.user.resultsOfLastSearch = [fetcher searchForProjectWithName:searchBar.text];
    [self.searchBar endEditing:YES];
    [self.tableView reloadData];
   
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar endEditing:YES];
    [self.searchBar resignFirstResponder];
    self.searching = NO;
    [self.tableView reloadData];
}

- (UIApplication *) thisApplication
{
    if (!_thisApplication) _thisApplication = [UIApplication sharedApplication];
    return  _thisApplication;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:[NSString stringWithFormat:@"%@'s Projects",[self.user fullName]]];
}


- (void) viewWillAppear:(BOOL)animated
{
    self.thisApplication.networkActivityIndicatorVisible = TRUE;
    self.title = [NSString stringWithFormat:@"%@ %@'s Projects",[self.user firstName],[self.user lastName]]; 
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setprojectsList];
    self.thisApplication.networkActivityIndicatorVisible = FALSE; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) setprojectsList
{
    [self.tableView reloadData];
    self.thisApplication.networkActivityIndicatorVisible = NO;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(self.searching) return [[self.user.resultsOfLastSearch allValues] count];
    else return [[[self.user projectsForClientData] allValues] count]; 
}



- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(self.searching){
        cell.textLabel.text = [[self.user.resultsOfLastSearch objectForKey:@(indexPath.row)] description];
    } else {
           cell.textLabel.text = [[self.user.projectsForClientData objectForKey:@(indexPath.row)] description];
    }
 
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
     [self.thisApplication setNetworkActivityIndicatorVisible:YES];
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
          
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        TickDataFetcher *fetcher = [[TickDataFetcher alloc] init];
        fetcher.user = self.user;
        if (self.searching) self.user.entriesForProjectData = [fetcher getEntriesForProject:[self.user.resultsOfLastSearch objectForKey:@(indexPath.row)]];
        else self.user.entriesForProjectData = [fetcher getEntriesForProject:[self.user.projectsForClientData objectForKey:@(indexPath.row)]];
        [[segue destinationViewController] setProject:[self.user.projectsForClientData objectForKey:@(indexPath.row)]];
        [[segue destinationViewController] setTitle:[NSString stringWithFormat:@"%@",[sender textLabel].text]];
        [[segue destinationViewController] setUser:self.user];
    } else if ([[segue identifier] isEqualToString:@"todaySegue"]) {
        
            [self.thisApplication setNetworkActivityIndicatorVisible:YES];
        TickDataFetcher *fetcher = [[TickDataFetcher alloc] init];
        [fetcher setUser:self.user];
        self.user.entriesForTodayData = [fetcher getEntriesForToday];
        [[segue destinationViewController] setUser:self.user];
         
        
           
    }
     [self.thisApplication setNetworkActivityIndicatorVisible:NO];
    
}


@end
