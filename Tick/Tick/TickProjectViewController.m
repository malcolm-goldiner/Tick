
//
//  MHNYCTickProjectViewController.m
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

#import "TickProjectViewController.h"

#import "TickProject.h"

#import "TickDataFetcher.h"

#import "TickEntry.h"

#import "TickEntryViewController.h"

#import "TickUser.h"

@interface TickProjectViewController ()
- (void)configureView;
@property (nonatomic) CGPoint originalCenter;
@property (strong, nonatomic) UIApplication *thisApplication;


@end

@implementation TickProjectViewController



#pragma mark - Lazy Instantation

- (UIApplication *) thisApplication
{
    if (!_thisApplication) _thisApplication = [UIApplication sharedApplication];
    return  _thisApplication;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.user.entriesForProjectData) return [self.user.entriesForProjectData count];
    else  return 0;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntryCell" forIndexPath:indexPath];
    cell.textLabel.text = [[self.user.entriesForProjectData objectForKey:@(indexPath.row)] description];
    return cell;
}



#pragma mark - View

- (void)viewDidLayoutSubviews
{
    if(!self.originalCenter.x && !self.originalCenter.y) self.originalCenter = self.view.center;
    self.thisApplication.networkActivityIndicatorVisible = FALSE;
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setEntriesList];
    self.thisApplication.networkActivityIndicatorVisible = FALSE;
    self.title = [NSString stringWithFormat:@"%@",[self.project name]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) setEntriesList
{
    [self.entriesTableView reloadData];
    self.thisApplication.networkActivityIndicatorVisible = NO;
}

- (void)setDetailItem:(id)newDetailItem
{
    if (_project != newDetailItem) {
        _project = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.project) {
        [self.detailDescriptionView setText:[NSString stringWithFormat:@"Project: %@ \n Total Hours: %g \n taskID: %i", [self.project name],[self.project sumHours],[self.project taskID]]];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

#pragma mark - Buttons
- (IBAction)createEntryButtonPressed:(UIButton *)sender {
    [sender setHidden:YES];
    [self.entriesTableView setHidden:YES];
    [self.hoursField setHidden:NO];
    [self.notesField setHidden:NO];
    [self.submitEntry setHidden:NO];
    [self.notesLabel setHidden:NO];
    [self.statusLabel setHidden:NO];
    [self.cancelButton setHidden:NO];
}


- (IBAction)submitEntryPressed:(id)sender {
    self.thisApplication.networkActivityIndicatorVisible = YES;
    TickEntry *newEntry = [[TickEntry alloc] init];
    newEntry.project = self.project;
    newEntry.user = self.user;
    newEntry.hours = [self.hoursField.text doubleValue];
    newEntry.dateCreated = [[[NSDate date] description] substringToIndex:9];
    newEntry.note = [self.notesField text];
    TickDataFetcher *entryAdder = [[TickDataFetcher alloc] init];
    entryAdder.user = self.user; 
    if([entryAdder createEntry:newEntry]){
        [self.notesField resignFirstResponder];
        [self textViewShouldEndEditing:self.notesField];
        [self.notesLabel resignFirstResponder];
        [self.notesField setHidden:YES];
        [self.notesLabel setHidden:YES];
        [self.hoursField setHidden:YES];
        [self.submitEntry setHidden:YES];
        [self.createEntryButton setHidden:NO];
        [self.entriesTableView setHidden:NO];
        [self.statusLabel setHidden:YES];
        [self.cancelButton setHidden:YES];
        self.user.entriesForProjectData = [entryAdder getEntriesForProject:self.project];
    } else {
        [self.statusLabel setText:@"Try Again"]; 
    }
    [self.entriesTableView reloadData];
    self.thisApplication.networkActivityIndicatorVisible = NO;
   
    
}

- (IBAction)cancelPressed:(id)sender {
    [self.hoursField resignFirstResponder];
    [self.notesField resignFirstResponder];
    [self.notesField setHidden:YES];
    [self.notesLabel setHidden:YES];
    [self.hoursField setHidden:YES];
    [self.submitEntry setHidden:YES];
    [self.createEntryButton setHidden:NO];
    [self.entriesTableView setHidden:NO];
    [self.statusLabel setHidden:YES];
    [self.cancelButton setHidden:YES];
}

#pragma mark - TextView

- (BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.view.center = self.originalCenter;
  
}




#pragma mark - TextField Delegate

// code from http://stackoverflow.com/questions/7952762/xcode-ios5-move-uiview-up-when-keyboard-appears
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y/1.65);
    
    
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField isEqual:self.notesField]){
        [self.createEntryButton setHidden:NO];
        [textField setHidden:YES];
        [self.hoursField setHidden:YES];
        [self.submitEntry setHidden:YES];
        [self.notesLabel setHidden:YES];
    }
    [self textFieldShouldReturn:textField];
    self.view.center = self.originalCenter;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if([textField isEqual:self.hoursField]){
        [self.notesField becomeFirstResponder];
    }
    [textField resignFirstResponder];
    return YES;
    
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *) sender
{
    if ([[segue identifier] isEqualToString:@"entrySegue"]) {
        NSIndexPath *indexPath = [self.entriesTableView indexPathForCell:sender];
        [[segue destinationViewController] setUser:self.user];
        [[segue destinationViewController] setEntry:[self.user.entriesForProjectData objectForKey:@(indexPath.row)]];
    }
}

@end
