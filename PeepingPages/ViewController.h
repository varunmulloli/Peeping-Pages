//
//  ViewController.h
//  Scroll
//
//  Created by Varun Mulloli on 13/03/13.
//  Copyright (c) 2013 Fraction Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *myScrollView;

@end
