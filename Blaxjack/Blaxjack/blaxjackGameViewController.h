//
//  blaxjackGameViewController.h
//  Blaxjack
//
//  Created by clamps on 12/18/13.
//  Copyright (c) 2013 loitery. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface blaxjackGameViewController : UIViewController <UIAlertViewDelegate>

- (UIImage *)CardImage:( short )value suit: (short) suit;

@end

#define kNumberOfDecks          8
#define kPenetrationPercentage  0.7