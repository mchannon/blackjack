//
//  blaxjackSettingsViewController.m
//  Blaxjack
//
//  Created by clamps on 12/18/13.
//  Copyright (c) 2013 loitery. All rights reserved.
//

#import "blaxjackSettingsViewController.h"
#import "blaxjackGameViewController.h"

@interface blaxjackSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *hitSoft17;
@property (weak, nonatomic) IBOutlet UISegmentedControl *numberOfDecks;

@end

@implementation blaxjackSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dealer17:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [ prefs setBool:_hitSoft17.on forKey:@"hitSoft17"];
    [ prefs synchronize];
}

- (IBAction)numDecks:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    switch ( _numberOfDecks.selectedSegmentIndex)
    {
        case 0:
            [ prefs setInteger:1 forKey:@"numDecks"];
            break;
        case 1:
            [ prefs setInteger:2 forKey:@"numDecks"];
            break;
        case 2:
            [ prefs setInteger:3 forKey:@"numDecks"];
            break;
        case 3:
            [ prefs setInteger:4 forKey:@"numDecks"];
            break;
        case 4:
            [ prefs setInteger:6 forKey:@"numDecks"];
            break;
        default:
            [ prefs setInteger:8 forKey:@"numDecks"];
            break;
    }
    [ prefs synchronize];
}


@end
