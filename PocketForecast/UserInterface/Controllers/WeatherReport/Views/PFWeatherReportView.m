////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2013, Jasper Blues & Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


#import "PFWeatherReportView.h"
#import "UIFont+ApplicationFonts.h"
#import "PFForecastTableViewCell.h"
#import "PFForecastConditions.h"
#import "PFWeatherReport.h"
#import "PFCurrentConditions.h"
#import "PFTemperature.h"
#import "PFWeatherReportViewDelegate.h"
#import "CKUITools.h"


@implementation PFWeatherReportView

/* ====================================================================================================================================== */
#pragma mark - Initialization & Destruction

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initBackgroundView];
        [self initSpinner];
        [self initCityNameLabel];
        [self initConditionsDescriptionLabel];
        [self initConditionsIcon];
        [self initTemperatureLabel];
        [self initTableView];
        [self initToolbar];
        [self initLastUpdateLabel];
    }

    return self;
}


/* ====================================================================================================================================== */
#pragma mark - Interface Methods

- (void)setWeatherReport:(PFWeatherReport*)weatherReport
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        LogDebug(@"Set weather report: %@", weatherReport);
        _weatherReport = weatherReport;

        [_conditionsIcon setHidden:NO];
        [_temperatureLabelContainer setHidden:NO];

        NSArray* indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:1 inSection:0],
                [NSIndexPath indexPathForRow:2 inSection:0]];

        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        [_cityNameLabel setText:[_weatherReport cityDisplayName]];
        [_temperatureLabel setText:[_weatherReport.currentConditions.temperature asShortStringInDefaultUnits]];
        [_conditionsDescriptionLabel setText:[_weatherReport.currentConditions longSummary]];
        [_conditionsIcon setImage:[self uiImageForImageUri:weatherReport.currentConditions.imageUri]];
        [_lastUpdateLabel setText:[NSString stringWithFormat:@"Updated %@", [weatherReport reportDateAsString]]];


    });
}

- (void)showSpinner
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [_spinner setHidden:NO];
    });
}

- (void)hideSpinner
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [_spinner setHidden:YES];
    });
}

- (void)setDelegate:(id <PFWeatherReportViewDelegate>)delegate
{
    _delegate = delegate;
}

/* ====================================================================================================================================== */
#pragma mark - Overridden Methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_backgroundView setFrame:self.bounds];
    [_spinner setFrame:(CGRectMake((self.width - _spinner.width) / 2, 20, _spinner.width, _spinner.height))];

    [_cityNameLabel setFrame:CGRectMake(0, 60, self.width, 40)];
    [_conditionsDescriptionLabel setFrame:CGRectMake(0, 90, 320, 50)];
    [_conditionsIcon setFrame:CGRectMake(40, 143, 130, 120)];
    [_temperatureLabelContainer setFrame:CGRectMake(180, 155, 88, 88)];

    [_toolbar setFrame:CGRectMake(0, self.frame.size.height - 44, 320, 44)];
    [_tableView setFrame:CGRectMake(0, self.frame.size.height - _toolbar.frame.size.height - 150, 320, 150)];
    [_lastUpdateLabel setFrame:CGRectMake(20, self.frame.size.height - 44, self.frame.size.width - 40, 44)];
}

/* ====================================================================================================================================== */
#pragma mark - Protocol Methods
#pragma mark <UITableVieDelegate> & <UITableViewDataSource>


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    PFForecastConditions* forecastConditions;
    if ([[_weatherReport forecast] count] > indexPath.row)
    {
        forecastConditions = [[_weatherReport forecast] objectAtIndex:indexPath.row];
    }
    static NSString* reuseIdentifier = @"weatherForecast";
    PFForecastTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
    {
        cell = [[PFForecastTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    [cell.dayLabel setText:forecastConditions.longDayOfTheWeek];
    [cell.descriptionLabel setText:forecastConditions.summary];
    [cell.lowTempLabel setText:[forecastConditions.low asShortStringInDefaultUnits]];
    [cell.highTempLabel setText:[forecastConditions.high asShortStringInDefaultUnits]];
    [cell.conditionsIcon setImage:[self uiImageForImageUri:forecastConditions.imageUri]];

    [cell.backgroundView setBackgroundColor:[self colorForRow:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{

}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView
        editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 50;
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell
        forRowAtIndexPath:(NSIndexPath*)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

/* ====================================================================================================================================== */
#pragma mark - Private Methods

- (void)initBackgroundView
{
    [self setBackgroundColor:UIColorFromRGB(0x837758)];
    _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg1.png"]];
    [self addSubview:_backgroundView];
}

- (void)initSpinner
{
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_spinner startAnimating];
    [self hideSpinner];
    [self addSubview:_spinner];
}

- (void)initCityNameLabel
{
    _cityNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_cityNameLabel setFont:[UIFont applicationFontOfSize:35]];
    [_cityNameLabel setTextColor:UIColorFromRGB(0xf9f7f4)];
    [_cityNameLabel setBackgroundColor:[UIColor clearColor]];
    [_cityNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_cityNameLabel];
}

- (void)initConditionsDescriptionLabel
{
    _conditionsDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_conditionsDescriptionLabel setFont:[UIFont applicationFontOfSize:16]];
    [_conditionsDescriptionLabel setTextColor:UIColorFromRGB(0xf9f7f4)];
    [_conditionsDescriptionLabel setBackgroundColor:[UIColor clearColor]];
    [_conditionsDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [_conditionsDescriptionLabel setNumberOfLines:0];
    [self addSubview:_conditionsDescriptionLabel];
}

- (void)initConditionsIcon
{
    _conditionsIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_conditionsIcon setImage:[UIImage imageNamed:@"icon_cloudy"]];
    [_conditionsIcon setHidden:YES];
    [self addSubview:_conditionsIcon];
}

- (void)initTemperatureLabel
{
    _temperatureLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 88)];
    [self addSubview:_temperatureLabelContainer];

    UIImageView* labelBackground = [[UIImageView alloc] initWithFrame:_temperatureLabelContainer.bounds];
    [labelBackground setImage:[UIImage imageNamed:@"temperature_circle"]];
    [_temperatureLabelContainer addSubview:labelBackground];

    _temperatureLabel = [[UILabel alloc] initWithFrame:_temperatureLabelContainer.bounds];
    [_temperatureLabel setFont:[UIFont temperatureFontOfSize:35]];
    [_temperatureLabel setTextColor:UIColorFromRGB(0x7f9588)];
    [_temperatureLabel setBackgroundColor:[UIColor clearColor]];
    [_temperatureLabel setTextAlignment:NSTextAlignmentCenter];

    [_temperatureLabelContainer setHidden:YES];
    [_temperatureLabelContainer addSubview:_temperatureLabel];
}

- (void)initTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setAllowsSelection:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setBounces:NO];
    [self addSubview:_tableView];
}

- (void)initToolbar
{
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [_toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [_toolbar setBarTintColor:UIColorFromRGBWithAlpha(0x2d7194, 0.9)];
    [self addSubview:_toolbar];

    UIBarButtonItem* cityListButton = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(cityListPressed)];
    [cityListButton setTintColor:[UIColor whiteColor]];

    UIBarButtonItem* space = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(cityListPressed)];

    UIBarButtonItem* refreshButton =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPressed)];
    [refreshButton setTintColor:[UIColor whiteColor]];

    [_toolbar setItems:@[cityListButton, space, refreshButton]];
}

- (void)initLastUpdateLabel
{
    _lastUpdateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_lastUpdateLabel setFont:[UIFont applicationFontOfSize:10]];
    [_lastUpdateLabel setTextColor:UIColorFromRGB(0xf9f7f4)];
    [_lastUpdateLabel setBackgroundColor:[UIColor clearColor]];
    [_lastUpdateLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_lastUpdateLabel];
}

/* ====================================================================================================================================== */

- (UIColor*)colorForRow:(NSUInteger)row
{
    switch (row)
    {
        case 0:
            return UIColorFromRGBWithAlpha(0x2d7194, 0.5);
        case 1:
            return UIColorFromRGBWithAlpha(0x2d7194, 0.7);
        default:
            return UIColorFromRGBWithAlpha(0x2d7194, 0.9);
    }
}

- (UIImage*)uiImageForImageUri:(NSString*)imageUri
{

    if ([imageUri length] > 0)
    {
        LogDebug(@"Retrieving image for URI: %@", imageUri);
        if ([imageUri hasSuffix:@"sunny.png"])
        {
            return [UIImage imageNamed:@"icon_sunny"];
        }
        else if ([imageUri hasSuffix:@"sunny_intervals.png"])
        {
            return [UIImage imageNamed:@"icon_cloudy"];
        }
        else if ([imageUri hasSuffix:@"partly_cloudy.png"])
        {
            return [UIImage imageNamed:@"icon_cloudy"];
        }
        else if ([imageUri hasSuffix:@"low_cloud.png"])
        {
            return [UIImage imageNamed:@"icon_cloudy"];
        }
        else if ([imageUri hasSuffix:@"light_rain_showers.png"])
        {
            return [UIImage imageNamed:@"icon_rainy"];
        }
        else if ([imageUri hasSuffix:@"heavy_rain_showers.png"])
        {
            return [UIImage imageNamed:@"icon_rainy"];
        }
        else
        {
            LogDebug(@"*** No icon for %@ . . rerturning sunny ***", imageUri);
            return [UIImage imageNamed:@"icon_sunny"];
        }
    }
    return nil;
}

/* ====================================================================================================================================== */
#pragma mark - Actions

- (void)cityListPressed
{
    [_delegate presentCitiesList];
}

- (void)refreshPressed
{
    [_delegate refreshData];
}

@end