//
//  ViewController.m
//  Scroll
//
//  Created by Varun Mulloli on 13/03/13.
//  Copyright (c) 2013 Fraction Labs. All rights reserved.
//

#import "ViewController.h"
#import "LevelPage.h"

#define totalPages 10

@implementation ViewController
{
    NSMutableArray *myPageDataArray;
    NSMutableArray *visiblePages;
    NSInteger numberOfPages;
	NSRange visibleIndexes;
    
    UIView *selectedPage;
}

@synthesize myScrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];

	myPageDataArray = [[NSMutableArray alloc] initWithCapacity : totalPages];
	
	for (int i=0; i<totalPages; i++)
    {
		UIViewController *pageData = [self.storyboard instantiateViewControllerWithIdentifier:@"LevelPage"];
        
        LevelPage *page = (LevelPage *)([pageData.view viewWithTag:1]);

		[myPageDataArray addObject:page];
	}
    
    visiblePages = [[NSMutableArray alloc] initWithCapacity:3];
    
    myScrollView.clipsToBounds = NO;
    
    numberOfPages = 1;
    visibleIndexes.location = 0;
	visibleIndexes.length = 1;

	[self reloadData];

}

- (void) reloadData;
{	
    NSInteger selectedIndex = selectedPage?[visiblePages indexOfObject:selectedPage]:NSNotFound;
    
	[visiblePages removeAllObjects];

    [[myScrollView subviews] enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop)
    {
        [obj removeFromSuperview];
    }];
    
	numberOfPages = [myPageDataArray count];
    myScrollView.contentSize = CGSizeMake(numberOfPages * myScrollView.bounds.size.width, myScrollView.bounds.size.height);
    
	if (numberOfPages>0)
    {

		for (int index=0; index<visibleIndexes.length; index++)
        {
			UIView *page = [self loadPageAtIndex:visibleIndexes.location+index insertIntoVisibleIndex:index];
            [self addPageToScrollView:page atIndex:visibleIndexes.location+index];
		}
		
		[self updateVisiblePages];
		
        if (selectedIndex == NSNotFound)
            selectedPage = [visiblePages objectAtIndex:0];
        else
            selectedPage = [visiblePages objectAtIndex:selectedIndex];
	}
}

- (UIView *)loadPageAtIndex:(NSInteger)index insertIntoVisibleIndex:(NSInteger)visibleIndex
{
	UIView *visiblePage = [myPageDataArray objectAtIndex:index];
	[visiblePages insertObject:visiblePage atIndex:visibleIndex];
    
    return visiblePage;
}

- (void)addPageToScrollView:(UIView *)page atIndex:(NSInteger)index
{
	CGFloat contentOffset = index * myScrollView.frame.size.width;
	CGFloat margin = (myScrollView.frame.size.width - page.frame.size.width) / 2;
	CGRect frame = page.frame;
	frame.origin.x = contentOffset + margin;
	frame.origin.y = 0.0;
	page.frame = frame;
    
	[myScrollView insertSubview:page atIndex:0];
}

- (void) updateVisiblePages
{
	CGFloat pageWidth = myScrollView.frame.size.width;

	CGFloat leftViewOriginX = myScrollView.frame.origin.x - myScrollView.contentOffset.x + (visibleIndexes.location * pageWidth);
	CGFloat rightViewOriginX = myScrollView.frame.origin.x - myScrollView.contentOffset.x + (visibleIndexes.location+visibleIndexes.length-1) * pageWidth;
	
	if (leftViewOriginX > 0)
    {
		if (visibleIndexes.location > 0)
        {
			visibleIndexes.length += 1;
			visibleIndexes.location -= 1;
			UIView *page = [self loadPageAtIndex:visibleIndexes.location insertIntoVisibleIndex:0];
            [self addPageToScrollView:page atIndex:visibleIndexes.location];
            
		}
	}
	else if(leftViewOriginX < -pageWidth)
    {
		UIView *page = [visiblePages objectAtIndex:0];
        [visiblePages removeObject:page];
        [page removeFromSuperview];
		visibleIndexes.location += 1;
		visibleIndexes.length -= 1;
	}
    
	if (rightViewOriginX > self.view.frame.size.width)
    {
		UIView *page = [visiblePages lastObject];
        [visiblePages removeObject:page];
        [page removeFromSuperview];
		visibleIndexes.length -= 1;
	}
	else if(rightViewOriginX + pageWidth < self.view.frame.size.width)
    {
		if (visibleIndexes.location + visibleIndexes.length < numberOfPages)
        {
            visibleIndexes.length += 1;
            NSInteger index = visibleIndexes.location+visibleIndexes.length-1;
			UIView *page = [self loadPageAtIndex:index insertIntoVisibleIndex:visibleIndexes.length-1];
            [self addPageToScrollView:page atIndex:index];
            
		}
	}
}

#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self updateVisiblePages];
	
	CGFloat delta = scrollView.contentOffset.x - selectedPage.frame.origin.x;
	BOOL toggleNextItem = (fabs(delta) > scrollView.frame.size.width/2);
	if (toggleNextItem && [visiblePages count] > 1)
    {
		
		NSInteger selectedIndex = [visiblePages indexOfObject:selectedPage];
		BOOL neighborExists = ((delta < 0 && selectedIndex > 0) || (delta > 0 && selectedIndex < [visiblePages count]-1));
		
		if (neighborExists)
        {
			
			NSInteger neighborPageVisibleIndex = [visiblePages indexOfObject:selectedPage] + (delta > 0? 1:-1);
			UIView *neighborPage = [visiblePages objectAtIndex:neighborPageVisibleIndex];
            
			if (!neighborPage)
                selectedPage = nil;
            else
                selectedPage = neighborPage;
		}
	}
}

@end
