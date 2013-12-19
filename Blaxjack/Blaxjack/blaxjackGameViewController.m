//
//  blaxjackGameViewController.m
//  Blaxjack
//
//  Created by clamps on 12/18/13.
//  Copyright (c) 2013 loitery. All rights reserved.
//

#import "blaxjackGameViewController.h"

@interface blaxjackGameViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *dealerPlayfield;
@property (weak, nonatomic) IBOutlet UIImageView *playerPlayfield;
@property (weak, nonatomic) IBOutlet UIButton *dealButton;
@property (weak, nonatomic) IBOutlet UIButton *hitButton;
@property (weak, nonatomic) IBOutlet UIButton *standButton;
@property (weak, nonatomic) IBOutlet UIButton *doubleButton;
@property (weak, nonatomic) IBOutlet UIButton *splitButton;
@property (weak, nonatomic) IBOutlet UIButton *surrenderButton;

@end

@implementation blaxjackGameViewController

short deck[ 52 * kNumberOfDecks ];
short decksuits[ 52 * kNumberOfDecks ];
short deckposition = 0;
short dealerhand[ 10 ];
short dealerhandsuits[ 10 ];
short player1hand[ 10 ];
short player1handsuits[ 10 ];

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


- (IBAction)HitButton:(id)sender {
}
- (IBAction)StandButton:(id)sender {
}
- (IBAction)DoubleButton:(id)sender {
    
    UIImage *img = [self CardImage:11 suit: 3];
    
    [ _dealerPlayfield setFrame:CGRectMake( _dealerPlayfield.frame.origin.x, _dealerPlayfield.frame.origin.y,
                                           img.size.width, img.size.height)];
    
    [ _dealerPlayfield setImage:img ];
    
    [ _dealerPlayfield reloadInputViews];
    
}
- (IBAction)SplitButton:(id)sender {
}
- (IBAction)SurrenderButton:(id)sender {
}

- (void)Shuffle
{
    NSInteger r;
    short temp, tempSuit;
    
    for ( short d = 1; d <= kNumberOfDecks; d++ )
        for ( short suit = 1; suit <= 4; suit++ )
            for ( short card = 1; card <= 13; card++ )
    {
        deck[ ( d - 1 )*52 + (suit - 1 )*13 + (card-1)] = card;
        decksuits[ ( d - 1 )*52 + (suit - 1 )*13 + (card-1)] = suit;
    }
    
    for ( short i = 0; i < 3; i++ )
        for ( short j = 0; j < 52 * kNumberOfDecks; j++ )
        {
            r = arc4random()%(52 * kNumberOfDecks);
            temp = deck[ r ];
            tempSuit = decksuits[ r ];
            deck[ r ] = deck[ j ];
            decksuits[ r ] = decksuits[ j ];
            deck[ j ] = temp;
            decksuits[ j ] = tempSuit;
        }
}

- (UIImage *) CardImage:( short )value suit: (short) suit
{
    UIImage* image = [UIImage imageNamed:@"cards.png"];
    
    CGRect rect = CGRectMake(-79+79*value,
                      -123+123*suit,
                      79,
                      123);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:1.0f
                                    orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
