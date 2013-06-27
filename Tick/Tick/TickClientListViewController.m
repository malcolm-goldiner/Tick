//
//  TickClientListViewViewController.m
//  Tick
//
//  Created by Malcolm Goldiner on 6/18/13.
//  Copyright (c) 2013 Mac Help NYC. All rights reserved.
//

#import "TickClientListViewController.h"

@interface TickClientListViewController ()
@property (nonatomic) BOOL showsCancelButton;
@property (nonatomic) BOOL searching;
@property (strong, nonatomic) UIApplication *thisApplication; 
@end

@implementation TickClientListViewController

- (UIApplication *) thisApplication
{
    if (!_thisApplication) _thisApplication = [UIApplication sharedApplication];
    return  _thisApplication;
}

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
    self.user.resultsOfLastSearch = [fetcher searchForClientWithName:searchBar.text];
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


- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searching) {
        return self.user.resultsOfLastSearch.count; 
    } else return [[self.user ClientData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"clientCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
   if (self.searching) cell.textLabel.text = [[self.user.resultsOfLastSearch objectForKey:@(indexPath.row)] description];
    else cell.textLabel.text = [[self.user.ClientData objectForKey:@(indexPath.row)] description];
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"clientToProjectSegue"]) {
        TickDataFetcher *fetcher = [[TickDataFetcher alloc] init];
        fetcher.user = self.user;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (self.searching) self.user.projectsForClientData = [fetcher getProjectsForClient:[self.user.resultsOfLastSearch objectForKey:@(indexPath.row)]];
        else self.user.projectsForClientData = [fetcher getProjectsForClient:[self.user.ClientData objectForKey:@(indexPath.row)]];
        [[segue destinationViewController] setUser:self.user];
    }  else if ([[segue identifier] isEqualToString:@"clientTodaySegue"]) {
        
        [self.thisApplication setNetworkActivityIndicatorVisible:YES];
        TickDataFetcher *fetcher = [[TickDataFetcher alloc] init];
        [fetcher setUser:self.user];
        self.user.entriesForTodayData = [fetcher getEntriesForToday];
        [[segue destinationViewController] setUser:self.user];
        
        
        
    }
    [self.thisApplication setNetworkActivityIndicatorVisible:NO];
}






@end
