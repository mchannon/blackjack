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
short holecard;
short dealerhand[ 10 ];
short dealerhandsuits[ 10 ];
short player1hand[ 10 ][ 4 ];
short player1handsuits[ 10 ][ 4 ];

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
    [ self Shuffle ];
	// Do any additional setup after loading the view.
}

- (void)drawDealerPlayfield:(short)total reveal:(BOOL)reveal
{
    UIGraphicsBeginImageContextWithOptions(_dealerPlayfield.frame.size, FALSE, 0.0);
    
    short i = 0;
    UIImage *img;
    
    while (dealerhand[i] != 0)
    {
        if ( reveal == FALSE && i == 0 )
            img = [self CardImage:3 suit:5];
        else
            img = [self CardImage:dealerhand[i] suit:dealerhandsuits[i]];
        [img drawInRect:CGRectMake( 23 * i, 0, img.size.width, img.size.height)];
        i++;
    }
    
    UIFont *font = [UIFont fontWithName: @"Courier" size: 12.0f];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, nil];
    
    NSString *totalString = [NSString stringWithFormat:@"%d", [ self AddDealerCards] ];
    
    [totalString drawInRect: CGRectMake( img.size.width + 23 * i, 30, 30, 20)
             withAttributes: dictionary];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [ _dealerPlayfield setImage:newImage ];
    
    [ _dealerPlayfield reloadInputViews];
}

- (void)drawPlayer1Playfield:(short)total split:(short)split
{
    UIGraphicsBeginImageContextWithOptions(_playerPlayfield.frame.size, FALSE, 0.0);

    short i = 0;
    UIImage *img;
    
    while (player1hand[i][split] != 0)
    {
        img = [self CardImage:player1hand[i][split] suit:player1handsuits[i][split]];
        [img drawInRect:CGRectMake( 23 * i, 0, img.size.width, img.size.height)];
        i++;
    }
    
    UIFont *font = [UIFont fontWithName: @"Courier" size: 12.0f];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, nil];
    
    NSString *totalString = [NSString stringWithFormat:@"%d", [ self AddPlayerCards:0] ];
    
    [totalString drawInRect: CGRectMake( img.size.width + 23 * i, 30, 30, 20)
       withAttributes: dictionary];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [ _playerPlayfield setImage:newImage ];
    
    [ _playerPlayfield reloadInputViews];
}

- (IBAction)HitButton:(id)sender {
}
- (IBAction)StandButton:(id)sender {
}
- (IBAction)DoubleButton:(id)sender {
}
- (IBAction)SplitButton:(id)sender {
}
- (IBAction)SurrenderButton:(id)sender {
}
- (IBAction)DealButton:(id)sender {
    _dealButton.hidden = true;
    
    for ( short i = 0; i < 10; i++ )
        dealerhand[ i ] = 0;
    
    for ( short j = 0; j < 10; j++ )
        for ( short k = 0; k < 4; k++ )
            player1hand[ j ][ k ] = 0;

    if ( ( (float)deckposition / ( 52.0 * kNumberOfDecks ) ) > kPenetrationPercentage )
        [self Shuffle];
    
    CGPoint m = [self DealCard];
    player1hand[ 0 ][ 0 ] = m.x;
    player1handsuits[ 0 ][ 0 ] = m.y;
    m = [self DealCard];
    dealerhand[ 0 ] = m.x;
    dealerhandsuits[ 0 ] = m.y;
    m = [self DealCard];
    player1hand[ 1 ][ 0 ] = m.x;
    player1handsuits[ 1 ][ 0 ] = m.y;
    m = [self DealCard];
    dealerhand[ 1 ] = m.x;
    dealerhandsuits[ 1 ] = m.y;
    
    short playerTotal = [ self AddPlayerCards:0];
    short dealerTotal = [ self AddDealerCards];
    
    [self drawDealerPlayfield: dealerTotal reveal:FALSE ];
    [self drawPlayer1Playfield: playerTotal split:0 ];
}

- (short)AddPlayerCards:(short)split
{
    short softSum = 0, hardSum = 0;
    short card;
    
    for ( short i = 0; i < 10; i++ )
    {
        card = player1hand[ i ][ split ];
        
        switch ( card )
        {
            case 11:
            case 12:
            case 13:
                card = 10;
                break;
        }
        
        hardSum += card;
        if ( card == 1 )
            softSum += 11;
        else
            softSum += card;
    }
    
    if ( softSum <= 21 )
        return softSum;
    else
        return hardSum;
}

- (short)AddDealerCards
{
    short softSum = 0, hardSum = 0;
    short card;
    
    for ( short i = 0; i < 10; i++ )
    {
        card = dealerhand[ i ];
        
        switch ( card )
        {
            case 11:
            case 12:
            case 13:
                card = 10;
                break;
        }
        
        hardSum += card;
        if ( card == 1 )
            softSum += 11;
        else
            softSum += card;
    }
    
    if ( softSum <= 21 )
        return softSum;
    else
        return hardSum;
}

- (CGPoint)DealCard
{
    CGPoint m = CGPointMake( deck[ deckposition ], decksuits[ deckposition]);
    deckposition++;
    return m;
}

- (void)Shuffle
{
    NSInteger r;
    short temp, tempSuit;
    
    NSLog( @"SHUFFLING" );
    
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
