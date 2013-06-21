//
//  MHNYCEntryViewController.m
//  Tick
//
//  Created by Malcolm Goldiner on 6/18/13.
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

#import "TickEntryViewController.h"
#import "TickDataFetcher.h"

@interface TickEntryViewController ()
@property (nonatomic) CGPoint originalCenter;
@property (strong, nonatomic) UIApplication *thisApplication; 
@end

@implementation TickEntryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIApplication *) thisApplication
{
    if (!_thisApplication) _thisApplication = [UIApplication sharedApplication];
    return  _thisApplication;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setText];
    self.title = [NSString stringWithFormat:@"%@",[self.entry project]]; 
    
    
}

- (void) viewDidLayoutSubviews{
     if(!self.originalCenter.x && !self.originalCenter.y) self.originalCenter = self.view.center;
}

- (IBAction)submitUpdatesPressed:(UIButton *)sender {
    [self.thisApplication setNetworkActivityIndicatorVisible:YES];
    TickDataFetcher *updated = [[TickDataFetcher alloc] init];
    [updated setUser:self.user];

    
    TickEntry *newEntry = [[TickEntry alloc] init];
    newEntry.hours = [self.updatedHoursField.text doubleValue];
    newEntry.note =self.updatedNotesField.text;
    newEntry.ID = self.entry.ID;
    newEntry = [updated updateEntry:newEntry]; 
    if (newEntry){
        sender.hidden = YES;
        self.notesLabel.hidden = YES;
        self.updatedHoursField.hidden = YES;
        self.updatedNotesField.hidden = YES;
        self.submitUpdatedButton.hidden = YES;
        self.updateEntryButton.hidden = NO;
        self.entry = newEntry;
        [self setText];
    } else {
        self.statusLabel.text = @"Try Again"; 
    }
    [self.updatedNotesField resignFirstResponder];
    self.view.center = self.originalCenter;
    [self.thisApplication setNetworkActivityIndicatorVisible:NO];

}

- (IBAction)updateEntryPressed:(UIButton *)sender {
    sender.hidden = YES;
    self.notesLabel.hidden = NO;
    self.updatedHoursField.text = [NSString stringWithFormat:@"%g",self.entry.hours];
    self.updatedNotesField.text = self.entry.note;
    self.updatedHoursField.hidden = NO;
    self.updatedNotesField.hidden = NO;
    self.submitUpdatedButton.hidden = NO;
    self.statusLabel.hidden = NO; 
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setText
{
    NSString *entryText = [NSString stringWithFormat:@"Hours: %g \n Date: %@ \n Notes: %@", [self.entry hours], [self.entry dateCreated], [self.entry note]];
    [self.textView setText:entryText];
    [self.textView reloadInputViews];
}

#pragma mark - TextView

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y/3.00);
}


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
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y/2);
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField isEqual:self.updatedNotesField]){
        [self.updateEntryButton setHidden:NO];
        [textField setHidden:YES];
        [self.updatedHoursField setHidden:YES];
        [self.submitUpdatedButton setHidden:YES];
        [self.notesLabel setHidden:YES];
    }
    [self textFieldShouldReturn:textField];
    self.view.center = self.originalCenter;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if([textField isEqual:self.updatedHoursField]){
        [self.updatedNotesField becomeFirstResponder];
    }
    [textField resignFirstResponder];
    return YES;
    
}



@end
