//
//  MHNYCEntryViewController.h
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

#import <UIKit/UIKit.h>
#import "TickEntry.h"
#import "TickUser.h"

@interface TickEntryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) TickEntry *entry;
@property (weak, nonatomic) IBOutlet UITextView *updatedNotesField;
@property (weak, nonatomic) IBOutlet UITextField *updatedHoursField;
@property (weak, nonatomic) IBOutlet UIButton *updateEntryButton;
@property (weak, nonatomic) IBOutlet UIButton *submitUpdatedButton;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) TickUser *user;

@end
