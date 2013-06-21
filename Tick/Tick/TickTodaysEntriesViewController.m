//
//  MHYNCTickTodaysEntriesViewController.m
//  Tick
//
//  Created by Malcolm Goldiner on 6/20/13.
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

#import "TickTodaysEntriesViewController.h"
#import "TickEntryViewController.h"
#import "TickDataFetcher.h"

@interface TickTodaysEntriesViewController ()
@property (nonatomic) BOOL searching; 
@property (strong ,nonatomic) UIApplication *thisApplication;
@end

@implementation TickTodaysEntriesViewController

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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searching) {
        return [[self.user resultsOfLastSearch] count]; 
    }
   else  return [self.user.entriesForTodayData count];
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECell" forIndexPath:indexPath];
    if (self.searching) {
        cell.textLabel.text = [[self.user.resultsOfLastSearch objectForKey:@(indexPath.row)] description];
    } else cell.textLabel.text = [[self.user.entriesForTodayData objectForKey:@(indexPath.row)] description];
    return cell;
}

- (UIApplication *) thisApplication
{
    if (!_thisApplication) _thisApplication = [UIApplication sharedApplication];
    return  _thisApplication;
}


#pragma mark - Managing the detail item


- (void)viewDidLayoutSubviews
{
    self.thisApplication.networkActivityIndicatorVisible = FALSE;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    
    self.thisApplication.networkActivityIndicatorVisible = FALSE;
    self.title = [[[NSDate date] description] substringToIndex:10];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"entrySegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        [[segue destinationViewController] setUser:self.user];
        if (self.searching) [[segue destinationViewController] setEntry:[self.user.resultsOfLastSearch objectForKey:@(indexPath.row)]];
        else [[segue destinationViewController] setEntry:[self.user.entriesForTodayData objectForKey:@(indexPath.row)]];
    }
}



@end
