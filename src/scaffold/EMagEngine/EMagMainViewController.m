
//  https://github.com/zhiyu/emag/
//
//  Created by zhiyu on 7/11/12.
//  Copyright 2012 zhiyu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EMagMainViewController.h"
#import "EMagChannelViewController.h"
#import "EMagPaneView.h"
#import "EMagEngine.h"
#import "ResourceHelper.h"
#import "CacheHelper.h"
#import "ASIHTTPRequest.h"
#import "MessageHelper.h"
#import "JSONKit.h"
#import "HttpHelper.h"

@implementation EMagMainViewController

@synthesize loadingView;
@synthesize channelView;
@synthesize menuView;
@synthesize bgView;
@synthesize reqUrl;
@synthesize requestUrl;
@synthesize channelViewController;

- (id)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

- (void)dealloc {
	[loadingView release];
    [channelView release];
    [bgView release];
    [channelViewController release];
    [super dealloc];
}

#pragma mark - EMag data api

-(void)getChannels{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"channels" ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *data = [jsonString mutableObjectFromJSONString];
    [jsonString release];
    
    if(data !=nil && data.count > 0){
        EMagEngine *magEngine = [[EMagEngine alloc] init];
        magEngine.paneSpacing = 10;
        magEngine.paneBackgroundColor = [UIColor colorWithRed:100/255.f green:175/255.f blue:1 alpha:0.8];
        
        self.channelView = [magEngine getEMagScrollView:CGRectMake(0, 15, 320, 450) pageFrame:CGRectMake(15, 0, 230, 450) count:data.count layout:@"11-11-11-11"];
        channelView.delegate = self;
        [channelView release];
        [magEngine release];
        
        NSArray *panes = [channelView getPanes];
        for (int i =0;i< panes.count;i++) {
            EMagPaneView *v    = [panes objectAtIndex:i];
            v.title.textColor  = [UIColor whiteColor];
            v.enableBorderTop  = NO;
            v.enableBorderLeft = NO;
            v.title.textAlignment = UITextAlignmentCenter;
            [v reloadView];
            [v setData:[data objectAtIndex:i]];
            [v reloadData];
            v.image.contentMode = UIViewContentModeCenter;
            [v onClick:self action:@selector(panePressed:)];
        }
        channelView.alpha = 0;
        [self.view addSubview:channelView];
    }
}

-(NSMutableArray *)getPages{
    return nil;
}

-(NSMutableDictionary *)getPageContent{
    return nil;
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bgView = [[UIImageView alloc] initWithImage:[ResourceHelper loadImage:@"loading"]];
    [bgView release];
    [self.view addSubview:bgView];
    
    //self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    //loading view
    self.loadingView = [[UIImageView alloc] initWithImage:[ResourceHelper loadImage:@"loading"]];
    //loadingView.frame = self.view.frame;
    loadingView.userInteractionEnabled = YES;
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[ResourceHelper loadImage:@"logo"]];
    logoView.frame = CGRectMake(20,40, 160, 40);
    [loadingView addSubview:logoView];
    [logoView release];
    
    UILabel *copyright = [[UILabel alloc] initWithFrame:CGRectMake(20,420, 200, 30)];
    copyright.text = @"©2012 http://github.com/zhiyu";
    copyright.font = [UIFont systemFontOfSize:12];
    copyright.textColor = [UIColor whiteColor];
    copyright.backgroundColor = [UIColor clearColor];
    [loadingView addSubview:copyright];
    [copyright release];
    
    UIButton *toHome = [[UIButton alloc] initWithFrame:CGRectMake(250, 400, 50, 50)];
    [toHome setImage:[ResourceHelper loadImage:@"opr_home"] forState:UIControlStateNormal];
    [toHome setImage:[ResourceHelper loadImage:@"opr_home"] forState:UIControlStateSelected];
    [toHome addTarget:self action:@selector(showMainView) forControlEvents:UIControlEventTouchUpInside];
    [loadingView addSubview:toHome];
    [toHome release];
    
    [self.view addSubview:loadingView];
    
    self.channelViewController = [[EMagChannelViewController alloc] init];
    [channelViewController release];
    
    
    [self getChannels];

    
    
    //menu view
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(270, 0, 32, 480)];
    UIImageView *menuItemView = [[UIImageView alloc] initWithImage:[ResourceHelper loadImage:@"opr_download"]];
    menuItemView.frame = CGRectMake(0,185, 32, 32);
    [menuView addSubview:menuItemView];
    [menuItemView release];
    
    menuItemView = [[UIImageView alloc] initWithImage:[ResourceHelper loadImage:@"opr_clear"]];
    menuItemView.frame = CGRectMake(0,245, 32, 32);
    [menuView addSubview:menuItemView];
    [menuItemView release];
    
    menuItemView = [[UIImageView alloc] initWithImage:[ResourceHelper loadImage:@"opr_refresh"]];
    menuItemView.frame = CGRectMake(0,305, 32, 32);
    [menuView addSubview:menuItemView];
    [menuItemView release];
    
    menuItemView = [[UIImageView alloc] initWithImage:[ResourceHelper loadImage:@"opr_set"]];
    menuItemView.frame = CGRectMake(0,365, 32, 32);
    [menuView addSubview:menuItemView];
    [menuItemView release];
    
    menuItemView = [[UIImageView alloc] initWithImage:[ResourceHelper loadImage:@"opr_add"]];
    menuItemView.frame = CGRectMake(0,425, 32, 32);
    [menuView addSubview:menuItemView];
    [menuItemView release];
    
    menuView.alpha = 0;
    [self.view addSubview:menuView];
    [menuView release];
    
    [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(showMainView) userInfo:nil repeats:NO];
}

-(void)showMainView{
    CGContextRef context=UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0f];
	loadingView.alpha=0.0f;
	channelView.alpha=1.0f;
    menuView.alpha=1.0f;
	channelView.transform=CGAffineTransformIdentity;
	[UIView setAnimationDelegate:self];
	[UIView commitAnimations];
}

-(void)panePressed:(id)sender{    
    self.requestUrl = @"http://iphone.myzaker.com/zaker/blog.php?app_id=785";
    
    [MessageHelper load:self message:nil detail:nil view:nil delay:0];
    NSData *cache = [CacheHelper get:requestUrl];
    if(cache!=nil){
        NSLog(@"cache");
        NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithData:cache];
        [MessageHelper hide];
        [self showChannel:data];
    }else{
        self.reqUrl = [[NSURL alloc] initWithString: requestUrl];
        [reqUrl release];
        
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:reqUrl];
        [request setTimeOutSeconds:10];
        [request setDelegate:self];
        [request startAsynchronous];        
    }
}

-(void)showChannel:(NSArray *)data{
    CATransition *transition = [CATransition animation]; 
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]; 
    transition.type = @"cube"; 
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;     
    [self.view.layer addAnimation:transition forKey:nil];
    channelViewController.items = data;
    [channelViewController fresh];
    [self.view addSubview:channelViewController.view];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([reqUrl isEqual:request.url]){
        [MessageHelper hide];
        NSString *responseString = [request responseString];
        NSArray *data = [[[responseString objectFromJSONString] objectForKey:@"data"] objectForKey:@"articles"];
        if(data.count > 0){
            [self showChannel:data];
            NSData *cache = [NSKeyedArchiver archivedDataWithRootObject:data];
            [CacheHelper setObject:cache forKey:requestUrl withExpires:10];
        }else{
            [MessageHelper show:self message:@"没有数据了" detail:nil delay:1];
        }
    }
    
    [request release];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if([reqUrl isEqual:request.url]){
        [request cancel];
        [MessageHelper show:self message:@"请求发生错误!" detail:nil delay:1];
    }else{
        [MessageHelper show:self message:@"没有数据了" detail:nil delay:1];
    }
    [request release];
}

#pragma mark - EMagScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   // NSLog(@"scrollViewDidScroll");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView // called on start of dragging (may require some time and or distance to move)
{
    //NSLog(@"scrollViewWillBeginDragging");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
{
     //NSLog(@"scrollViewDidEndDragging");
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView  // called on finger up as we are moving
{
    //NSLog(@"scrollViewWillBeginDecelerating");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView    // called when scroll view grinds to a halt
{
    //NSLog(@"scrollViewDidEndDecelerating");
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView; // called when setContentOffset/scrollRectVisible animated: finishes. not called if not animating
{
    //NSLog(@"scrollViewDidEndScrollingAnimation");
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView   // return a yes if you want to scroll to the top. if not defined, assumes YES
{
    //NSLog(@"scrollViewShouldScrollToTop");
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView      // called when scrolling animation finished. may be called immediately if already at top
{
    //NSLog(@"scrollViewDidScrollToTop");
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    NSLog(@"view did unload");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
