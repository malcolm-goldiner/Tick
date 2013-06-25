//
//  TickEntry.m
//  Tick
//
//  Created by Malcolm Goldiner on 6/14/13.
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

#import "TickEntry.h"

@implementation TickEntry


- (NSString *) description
{
    double hours = [self hours];
    int minutes = 0; 
    int hrs = (int)hours;
    if (hrs != hours){
        minutes = 60 * (hours - hrs);
    }
    if (minutes == 0 )return [NSString stringWithFormat:@"%@ - %g hours", [self dateCreated], [self hours]];
    else if (hrs == 0) return [NSString stringWithFormat:@"%@ - %i minutes", [self dateCreated], minutes];
    else return [NSString stringWithFormat:@"%@ - %i hrs %i mins", [self dateCreated], hrs, minutes];

}


@end
