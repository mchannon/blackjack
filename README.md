blackjack
=========

iOS Blackjack

Architecture
--------------

This implementation uses a simple storyboard topology with three viewControllers
all arranged through a standard tabBarController.

SettingsViewController is designed to configure the settings in 
GameViewController through using NSUserDefaults.

Although it makes for a long code file, almost all gameplay is folded into
GameViewController.m.  If substantial and complex modifications are made,
some of these functions should be put off into other classes.

Design Choices
--------------

A simple straightforward approach was taken.  By designing for the smallest
3.5" iPhone screen, opportunity for larger amounts of data to be displayed is
passed up in favor of large print.

Buttons and labels use quite straightforward designs and could stand being
jazzed up.

For handling splits, a separate label system is implemented, showing one split
at a time, as the number of cards can exceed 20 for one player alone.


Known Bugs
--------------

No known bugs at this time, though additional testing, particularly on
multiple splits and dollar amounts, may reveal a few.


Areas for Improvement
--------------

* The user can not adjust their bet.
* Only one user is permitted; AI and real players can't yet be added.
* Animations are not in place.
* When a player hits or exceeds 21, particularly on split cards, there is no delay.
* Game stats tracking, to be made available on main screen, aren't yet in place.
* Tutorial on initial gameplay would be nice.
* Far improved graphics, particularly for iPad.
* Card-counting and Ace-tracking aids would be good.
* Realistic shuffling employing standard cut and riffle algorithms.
* Side bets such as Lucky Ladies and Wheel of Madness to be supported.
* iAd support.
* Network/server support employing in-game purchases and sitewide high score tracking.


To Do
--------------

* Submit to App Store.  With only 1,730 other options (market validation) 
there is a clearly demonstrated need for a better (?) blackjack game.
