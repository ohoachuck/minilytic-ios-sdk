//
//  FirstViewController.m
//  weblytic Sample
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import "FirstViewController.h"
#import "WLYTracker.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
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

- (IBAction)tap:(id)sender
{
    for(int i=0; i < 100; i++){
        
        NSString *name = [NSString stringWithFormat:@"tab%d.button", rand() % 10];
        
        [[WLYTracker defaultTracker] trackEvent:name];
    }
}
@end
