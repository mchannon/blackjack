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
@property (weak, nonatomic) IBOutlet UILabel *splitLabel;

@end

@implementation blaxjackGameViewController

short deck[ 52 * 8 ];  // Leave room for 8 decks, even if not all are used
short decksuits[ 52 * 8 ];
short deckposition = 0;
short activesplit = 0;
short numberofsplits = 0;
short dealerhand[ 10 ];
short dealerhandsuits[ 10 ];
short player1hand[ 10 ][ 4 ];
short player1handsuits[ 10 ][ 4 ];
BOOL doubledown[ 4 ];
short player1balance = 100;
short player1bet = 10;
BOOL dealerHitsSoft17 = false;

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
    
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    if ( [data objectForKey:@"player1balance"] )
        player1balance = [[data objectForKey:@"player1balance"] integerValue];
    
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
    
    if ( reveal )
    {
        UIFont *font = [UIFont fontWithName: @"Courier" size: 12.0f];
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, nil];
        
        NSString *totalString = [NSString stringWithFormat:@"%d", [ self AddDealerCards] ];
        
        [totalString drawInRect: CGRectMake( img.size.width + 23 * i, 30, 30, 20) withAttributes: dictionary];
    }
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
    
    NSString *totalString = [NSString stringWithFormat:@"%d", [ self AddPlayerCards:activesplit] ];
    
    [totalString drawInRect: CGRectMake( img.size.width + 23 * i, 30, 30, 20)
       withAttributes: dictionary];
    
    totalString = [NSString stringWithFormat:@"$%d", player1balance];
    font = [UIFont fontWithName: @"Marker Felt" size: 14.0f];
    dictionary = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, nil];

    [totalString drawInRect: CGRectMake( img.size.width + 18 * i, 70, 80, 20)
             withAttributes: dictionary];


    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [ _playerPlayfield setImage:newImage ];
    
    [ _playerPlayfield reloadInputViews];
}

- (IBAction)HitButton:(id)sender {
    short i = 0;
    
    while ( player1hand[ i ][ activesplit ] != 0 )
        i++;
    
    CGPoint m = [self DealCard];
    player1hand[ i ][ activesplit ] = m.x;
    player1handsuits[ i ][ activesplit ] = m.y;
    
    [self drawPlayer1Playfield: [ self AddPlayerCards:activesplit] split:activesplit ];
    
    _doubleButton.hidden = true;
    _surrenderButton.hidden = true;
    _splitButton.hidden = true;
    
    if ( [ self AddPlayerCards:activesplit] >= 21 )
    {
        if ( activesplit < numberofsplits )
        {
            activesplit++;
            short sum = [ self AddPlayerCards:activesplit];
            [ _splitLabel setText:[NSString stringWithFormat:@"%d:", activesplit+1] ];

            short i = 0;
            
            while ( player1hand[ i ][ activesplit ] != 0 )
                i++;
            
            CGPoint m = [self DealCard];
            player1hand[ i ][ activesplit ] = m.x;
            player1handsuits[ i ][ activesplit ] = m.y;
            
            _doubleButton.hidden = false;
            if (player1hand[ 0 ][activesplit] == player1hand[ 1 ][activesplit])
                _splitButton.hidden = false;
            else
                _splitButton.hidden = true;

            [self drawPlayer1Playfield: sum split:activesplit ];
        }
        else
            [self dealersTurn: false];
    }
}
- (IBAction)StandButton:(id)sender {
    if ( activesplit < numberofsplits )
    {
        activesplit++;
        short sum = [ self AddPlayerCards:activesplit];
        [ _splitLabel setText:[NSString stringWithFormat:@"%d:", activesplit+1] ];
        
        short i = 0;
        
        while ( player1hand[ i ][ activesplit ] != 0 )
            i++;
        
        CGPoint m = [self DealCard];
        player1hand[ i ][ activesplit ] = m.x;
        player1handsuits[ i ][ activesplit ] = m.y;
        
        _doubleButton.hidden = false;
        if (player1hand[ 0 ][activesplit] == player1hand[ 1 ][activesplit])
            _splitButton.hidden = false;
        else
            _splitButton.hidden = true;

        [self drawPlayer1Playfield: sum split:activesplit ];
    }
    else
        [self dealersTurn: false];
}
- (IBAction)DoubleButton:(id)sender {
    
    CGPoint m = [self DealCard];
    doubledown[ activesplit ] = true;
    player1hand[ 2 ][ activesplit ] = m.x;
    player1handsuits[ 2 ][ activesplit ] = m.y;
    [self drawPlayer1Playfield: [ self AddPlayerCards:activesplit] split:activesplit ];
    if ( activesplit < numberofsplits )
    {
        activesplit++;
        short sum = [ self AddPlayerCards:activesplit];
        [ _splitLabel setText:[NSString stringWithFormat:@"%d:", activesplit+1] ];

        short i = 0;
        
        while ( player1hand[ i ][ activesplit ] != 0 )
            i++;
        
        CGPoint m = [self DealCard];
        player1hand[ i ][ activesplit ] = m.x;
        player1handsuits[ i ][ activesplit ] = m.y;

        _doubleButton.hidden = false;
        if (player1hand[ 0 ][activesplit] == player1hand[ 1 ][activesplit])
            _splitButton.hidden = false;
        else
            _splitButton.hidden = true;

        [self drawPlayer1Playfield: sum split:activesplit ];
    }
    else
        [self dealersTurn: false];
}
- (IBAction)SplitButton:(id)sender {
    
    numberofsplits++;
    player1hand[ 0 ][ numberofsplits ] = player1hand[ 1 ][ activesplit ];
    player1handsuits[ 0 ][ numberofsplits ] = player1handsuits[ 1 ][ activesplit ];
    
    CGPoint m = [self DealCard];
    player1hand[ 1 ][ activesplit ] = m.x;
    player1handsuits[ 1 ][ activesplit ] = m.y;
    
    [self drawPlayer1Playfield: [ self AddPlayerCards:activesplit] split:activesplit ];

    if (player1hand[ 0 ][activesplit] == player1hand[ 1 ][activesplit])
        _splitButton.hidden = false;
    else
        _splitButton.hidden = true;

    [ _splitLabel setText:[NSString stringWithFormat:@"%d:", activesplit+1] ];
    _splitLabel.hidden = false;
}
- (IBAction)SurrenderButton:(id)sender {
    player1balance -= (0.5f * player1bet);
    [ self dealersTurn: true];
}
- (IBAction)DealButton:(id)sender {
    _splitLabel.hidden = true;
    _dealButton.hidden = true;
    _hitButton.hidden = true;
    _standButton.hidden = true;
    _splitButton.hidden = true;
    _doubleButton.hidden = true;
    _surrenderButton.hidden = true;
    
    activesplit = 0;
    numberofsplits = 0;
    
    for ( short i = 0; i < 10; i++ )
        dealerhand[ i ] = 0;
    
    for ( short j = 0; j < 10; j++ )
        for ( short k = 0; k < 4; k++ )
        {
            player1hand[ j ][ k ] = 0;
            doubledown[ k ] = false;
        }
    
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    short numberOfDecks = [[data objectForKey:@"numDecks"] boolValue];
    
    if ( ( (float)deckposition / ( 52.0 * numberOfDecks ) ) > kPenetrationPercentage )
    {
        [self Shuffle];
        deckposition = 0;
    }
    
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

    if ( dealerTotal == 21 && dealerhand[ 0 ] == 1 )
    {
        player1balance -= (1.0f * player1bet);
        [self drawDealerPlayfield: dealerTotal reveal:TRUE ];
        _dealButton.hidden = false;
    }
    else
    {
        if ( dealerhand[ 1 ] == 1 )
            [self seekInsurance ];

        if ( playerTotal == 21 )
        {
            _dealButton.hidden = false;
           [self playerBlackjack ];
        }
        else
        {
            _doubleButton.hidden = false;
            _hitButton.hidden = false;
            _standButton.hidden = false;
            _surrenderButton.hidden = false;
        }
        
        if ( player1hand[ 0 ][ 0 ] == player1hand[ 1 ][ 0 ] )
            _splitButton.hidden = false;
        else
            _splitButton.hidden = true;

    }
}

- (void)dealersTurn: (BOOL)surrender
{
    short softSum = 0, hardSum = 0;
    short card;
    CGPoint m;
    short i = 0;
    BOOL isHard17 = false;
    
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    dealerHitsSoft17 = [[data objectForKey:@"hitSoft17"] boolValue];
    
    while ([ self AddDealerCards] < 18 && isHard17 == false )
    {
        i = 0;
        while ( dealerhand[ i ] != 0 )
            i++;
        
        if ( [ self AddDealerCards] == 17 )
        {
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
            
            if ( hardSum == 7 && dealerHitsSoft17 )
            {
                m = [self DealCard];
                dealerhand[ i ] = m.x;
                dealerhandsuits[ i ] = m.y;
            }
            else
                isHard17 = true;
        }
        else
        {
            m = [self DealCard];
            dealerhand[ i ] = m.x;
            dealerhandsuits[ i ] = m.y;
        }
    }
    
    [self drawDealerPlayfield: [ self AddDealerCards] reveal:TRUE ];
    
    _dealButton.hidden = false;
    _hitButton.hidden = true;
    _standButton.hidden = true;
    _splitButton.hidden = true;
    _doubleButton.hidden = true;
    _surrenderButton.hidden = true;
    
    if ( surrender != true )
    {
  //      short i = 0;
//        if ( 1 )
            
       for ( short i = 0; i <= numberofsplits; i++ )
        {
            if ( [ self AddPlayerCards:i ] > 21)
                player1balance -= doubledown[ i ] ? (2 * player1bet) : player1bet;
            else
                if ( [ self AddDealerCards ] > 21)
                    player1balance += doubledown[ i ] ? (2 * player1bet) : player1bet;
                else
                    if ( [ self AddDealerCards ] > [ self AddPlayerCards:i ])
                        player1balance -= doubledown[ i ] ? (2 * player1bet) : player1bet;
                    else
                        if ( [ self AddDealerCards ] < [ self AddPlayerCards:i ])
                            player1balance += doubledown[ i ] ? (2 * player1bet) : player1bet;
        }
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [ prefs setFloat:(float)player1balance forKey:@"player1balance"];
    [ prefs synchronize];

}

- (void)seekInsurance
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Insurance"
                          message: @"Do you want insurance?"
                          delegate: self
                          cancelButtonTitle:@"No"
                          otherButtonTitles:@"Yes",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        if ( [ self AddDealerCards ] == 21 )
        {
            player1balance += (1.0f * player1bet); //Takes it back off so this cancels it out
            [self dealersTurn:false];
        }
        else
        {
            player1balance -= (0.5f * player1bet);
            [self drawPlayer1Playfield:[self AddPlayerCards:activesplit] split:activesplit];
        }
    else
        if ( [ self AddDealerCards ] == 21 )
        {
            player1balance -= player1bet;
            [self dealersTurn:false];
        }
}

- (void)playerBlackjack
{
    player1balance += (1.5f * player1bet);
    
    _doubleButton.hidden = true;
    _hitButton.hidden = true;
    _standButton.hidden = true;
    _surrenderButton.hidden = true;
    _splitButton.hidden = true;
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
    
    while ( ( softSum - hardSum ) > 10 )
        softSum -= 10;

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
    
    while ( ( softSum - hardSum ) > 10 )
        softSum -= 10;
    
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
    
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    short numberOfDecks = [[data objectForKey:@"numDecks"] boolValue];
    
    for ( short d = 1; d <= numberOfDecks; d++ )
        for ( short suit = 1; suit <= 4; suit++ )
            for ( short card = 1; card <= 13; card++ )
    {
        deck[ ( d - 1 )*52 + (suit - 1 )*13 + (card-1)] = card;
        decksuits[ ( d - 1 )*52 + (suit - 1 )*13 + (card-1)] = suit;
    }
    
    for ( short i = 0; i < 3; i++ )
        for ( short j = 0; j < 52 * numberOfDecks; j++ )
        {
            r = arc4random()%(52 * numberOfDecks);
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