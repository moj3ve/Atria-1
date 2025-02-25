//
// Created by ren7995 on 2021-04-25 12:49:07
// Copyright (c) 2021 ren7995. All rights reserved.
//

#import "src/Manager/ARITweak.h"
#import <objc/runtime.h>
#import "src/Manager/ARIEditManager.h"

@implementation ARITweak {
    NSUserDefaults *_preferences;
    NSDictionary *_defaultSettings;
    NSDictionary *_settingsStrings;
    NSDictionary *_settingsRange;
    NSArray *_editorOptions;
    NSMapTable *_listViewModelMap;
    BOOL _firmware14;
    BOOL _didLoad;
}

@synthesize preferences = _preferences;
@synthesize firmware14 = _firmware14;
@synthesize didLoad = _didLoad;
@synthesize listViewModelMap = _listViewModelMap;

// Shared instance and init methods

- (instancetype)init {
    self = [super init];
    if(self) {
        if([[[UIDevice currentDevice] systemVersion] compare:@"14.0" options:NSNumericSearch] != NSOrderedAscending) {
            _firmware14 = YES;
        } else {
            _firmware14 = NO;
        }
        // NSUserDefaults to get what values the user set
        _preferences = [[NSUserDefaults alloc] initWithSuiteName:@"me.lau.AtriaPrefs"];
        _enabled = [_preferences objectForKey:@"enabled"] ? [[_preferences objectForKey:@"enabled"] boolValue] : YES;
        _listViewModelMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
        // Default settings - anything that shouldn't default to 0
        _defaultSettings = @{
            @"showWelcome" : @(YES),
            @"welcomeText" : @"Welcome, user",
            @"welcomeTextColor" : @"#FFFFFF",
            @"blurTintColor" : @"#FFFFFF",
            @"layoutEnabled" : @(YES),
            @"enableAppLibrary" : @(YES),
            @"saveIconState" : @(YES),
            @"hideLabelsAppLibrary" : @(YES),
            @"hideLabels" : @(YES),
            @"hideLabelsFolders" : @(YES),
            @"scaleInsideFolders" : @(YES),

            @"welcome_textSize" : @(30.0),

            @"hs_rows" : @(6),
            @"hs_columns" : @(4),
            @"hs_iconScale" : @(1.0),
            @"hs_widgetIconScale" : @(1.0),

            @"dock_columns" : @(4),
            @"dock_rows" : @(1),
            @"dock_iconScale" : @(1),
            @"dock_bg" : @(1.0),

            @"background_bg" : @(1),
            @"background_corner_radius" : @(12),
            @"background_intensity" : @(1),
        };

        // Editor options
        _editorOptions = @[
            @"welcome_textSize",
            @"welcome_inset_left",
            @"welcome_inset_top",

            @"hs_rows",
            @"hs_columns",
            @"hs_iconScale",
            @"hs_widgetIconScale",

            @"hs_inset_top",
            @"hs_inset_left",
            @"hs_inset_bottom",
            @"hs_inset_right",
            @"hs_spacing_x",
            @"hs_spacing_y",
            @"hs_offset_top",
            @"hs_offset_left",
            @"hs_widgetXOffset",
            @"hs_widgetYOffset",

            @"dock_inset_top",
            @"dock_inset_left",
            @"dock_inset_bottom",
            @"dock_inset_right",

            @"dock_columns",
            @"dock_rows",
            @"dock_iconScale",
            @"dock_bg",
            @"dock_spacing_x",
            @"dock_spacing_y",

            @"background_bg",
            @"background_inset_top",
            @"background_inset_left",
            @"background_inset_bottom",
            @"background_inset_right",
            @"background_corner_radius",
            @"background_intensity",
        ];
        // dictionaryWithObjects:forKeys:

        // Conversions (to display)
        _settingsStrings = [NSDictionary dictionaryWithObjects:@[
            @"Text Size",
            @"Side Inset",
            @"Vertical Inset",

            @"Rows",
            @"Columns",
            @"Icon Scale",
            @"Widget Scale",

            @"Top Inset",
            @"Left Inset",
            @"Bottom Inset",
            @"Right Inset",
            @"Icon Spacing X",
            @"Icon Spacing Y",
            @"Page Top Offset",
            @"Page Left Offset",
            @"Widget X Offset",
            @"Widget Y Offset",

            @"Top Inset",
            @"Left Inset",
            @"Bottom Inset",
            @"Right Inset",

            @"Columns",
            @"Rows",
            @"Icon Scale",
            @"Background Alpha",
            @"Icon Spacing X",
            @"Icon Spacing Y",

            @"Background Alpha",
            @"Top Position",
            @"Left Position",
            @"Bottom Position",
            @"Right Position",
            @"Corner Radius",
            @"Tint Intensity",
        ]
                                                       forKeys:_editorOptions];

        _settingsRange = [NSDictionary dictionaryWithObjects:@[
            @[ @(1), @(60) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],

            @[ @(2), @(20) ],
            @[ @(2), @(20) ],
            @[ @(0), @(2) ],
            @[ @(0.01), @(3) ],

            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],
            @[ @(-100), @(100) ],
            @[ @(-100), @(100) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],

            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],

            @[ @(2), @(20) ],
            @[ @(1), @(5) ],
            @[ @(0.01), @(3) ],
            @[ @(0), @(1) ],
            @[ @(-100), @(100) ],
            @[ @(-100), @(100) ],

            @[ @(0), @(1) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],
            @[ @(-200), @(200) ],
            @[ @(0), @(100) ],
            @[ @(0), @(1) ],
        ]
                                                     forKeys:_editorOptions];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t token;
    static ARITweak *manager;
    dispatch_once(&token, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

// Runtime manager methods

- (void)updateLayoutForEditing:(BOOL)animated {
    NSString *editingLocation = [ARIEditManager sharedInstance].editingLocation;
    if(!editingLocation) return;

    BOOL root = NO, dock = NO;
    if([editingLocation isEqualToString:@"dock"])
        dock = YES;
    else if([editingLocation isEqualToString:@"hs"] || [editingLocation isEqualToString:@"welcome"] || [editingLocation isEqualToString:@"background"])
        root = YES;
    [self updateLayoutForRoot:root forDock:dock animated:animated];
}

// Updates all layout
- (void)updateLayoutForRoot:(BOOL)forRoot forDock:(BOOL)forDock animated:(BOOL)animated {
    SBRootFolderView *rootFolderView = [[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] rootFolderView];

    // What tf is this. Objc explain
    void (^updateVisible)(BOOL finished) = ^void(BOOL finished) {
        SBIconListView *current = [self currentListView];
        // Update visible columns and rows for current list view. Otherwise, SB doesn't
        // update this until we start scrolling
        if([current respondsToSelector:@selector(setVisibleColumnRange:)])
            [current setVisibleColumnRange:NSMakeRange(0, [self intValueForKey:@"hs_columns" forListView:current])];
        if([current respondsToSelector:@selector(setVisibleRowRange:)])
            [current setVisibleRowRange:NSMakeRange(0, [self intValueForKey:@"hs_rows" forListView:current])];
    };

    void (^layout)() = ^void() {
        if(forDock) {
            // Layout dock icons and set alpha
            // -dockListView doesn't exist on 13 but the ivar does
            SBIconListView *listView = (SBIconListView *)[rootFolderView valueForKeyPath:@"_dockListView"];
            listView._atriaNeedsLayout = YES;
            [listView layoutIconsNow];
            [[rootFolderView dockView] _atriaUpdateDockForSettingsChanged];
        }

        if(forRoot) {
            // Enumerate list views in root and lay them out as well
            for(SBIconListView *listView in rootFolderView.iconListViews) {
                listView._atriaNeedsLayout = YES;
                [listView layoutIconsNow];
            }
        }
    };

    // If we want animation, pass the block here. Otherwise, call the block directly
    if(animated) {
        [UIView animateWithDuration:0.6f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:layout
                         completion:updateVisible];
    } else {
        layout();
        updateVisible(YES);
    }
}

- (NSUInteger)indexOfListView:(SBIconListView *)target {
    return [[self allRootListViews] indexOfObject:target];
}

- (NSArray<SBIconListView *> *)allRootListViews {
    return [[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] rootFolderView].iconListViews;
}

- (SBIconListView *)firstIconListView {
    return [[[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] rootFolderView] firstIconListView];
}

- (NSString *)stringIndexOfListView:(SBIconListView *)target {
    // Fallback to global
    if(!target || [target.iconLocation isEqualToString:@"SBIconLocationDock"]) return @"";

    // Return an empty string if list view is not setup for individual config
    int index = (int)[self indexOfListView:target];
    return [NSString stringWithFormat:@"_%d_", index];
}

- (void)feedbackForButton {
    // Create a generator (just like in AppStore apps) and make it give feedback
    static UIImpactFeedbackGenerator *generator = nil;
    if(!generator) generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleSoft];
    [generator impactOccurred];
}

- (void)notifyDidLoad {
    _didLoad = YES;
}

- (NSArray<NSString *> *)allSettingsKeys {
    return _editorOptions;
}

- (NSString *)stringRepresentationForSettingsKey:(NSString *)key {
    return _settingsStrings[key];
}

- (NSArray<NSNumber *> *)rangeForSettingsKey:(NSString *)key {
    return _settingsRange[key];
}

- (SBIconListView *)currentListView {
    return [[[objc_getClass("SBIconController") sharedInstance] _rootFolderController] rootFolderView].currentIconListView;
}

// Helper methods for use elsewhere
// Beware, boilerplate code below

- (int)intValueForKey:(NSString *)key {
    return [_preferences objectForKey:key] ? [[_preferences objectForKey:key] integerValue] : [[_defaultSettings objectForKey:key] integerValue];
}

- (BOOL)boolValueForKey:(NSString *)key {
    return [_preferences objectForKey:key] ? [[_preferences objectForKey:key] boolValue] : [[_defaultSettings objectForKey:key] boolValue];
}

- (id)rawValueForKey:(NSString *)key {
    return [_preferences objectForKey:key] ?: [_defaultSettings objectForKey:key];
}

- (float)floatValueForKey:(NSString *)key {
    return [_preferences objectForKey:key] ? [[_preferences objectForKey:key] floatValue] : [[_defaultSettings objectForKey:key] floatValue];
}

// Per page layout
// We try to locate value for the current list view, if it exists

- (int)intValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:list], key];
    return [_preferences objectForKey:pageKey] ? [[_preferences objectForKey:pageKey] integerValue] : [self intValueForKey:key];
}

- (BOOL)boolValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:list], key];
    return [_preferences objectForKey:pageKey] ? [[_preferences objectForKey:pageKey] boolValue] : [self boolValueForKey:key];
}

- (id)rawValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:list], key];
    return [_preferences objectForKey:pageKey] ?: [self rawValueForKey:key];
}

- (float)floatValueForKey:(NSString *)key forListView:(SBIconListView *)list {
    NSString *pageKey = [NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:list], key];
    return [_preferences objectForKey:pageKey] ? [[_preferences objectForKey:pageKey] floatValue] : [self floatValueForKey:key];
}

- (void)setValue:(id)val forKey:(NSString *)key listView:(SBIconListView *)listView {
    if(!listView) {
        [self setValue:val forKey:key];
        return;
    }
    [self setValue:val forKey:[NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:listView], key]];
}

- (void)resetValueForKey:(NSString *)key listView:(SBIconListView *)listView {
    if(!listView) {
        [self resetValueForKey:key];
        return;
    }
    [self.preferences removeObjectForKey:[NSString stringWithFormat:@"%@%@", [self stringIndexOfListView:listView], key]];
}

- (void)deleteCustomForListView:(SBIconListView *)listView {
    // Delete any keys for that list view
    NSString *prefix = [self stringIndexOfListView:listView];
    NSDictionary *preferences = [_preferences dictionaryRepresentation];
    for(NSString *key in [preferences allKeys]) {
        if([key hasPrefix:prefix]) {
            [self.preferences removeObjectForKey:key];
        }
    }

    NSMutableArray *perPage = [(NSArray *)[self rawValueForKey:@"_perPageListViews"] mutableCopy] ?: [NSMutableArray new];
    [perPage removeObject:prefix];
    [self setValue:perPage forKey:@"_perPageListViews"];

    [self updateLayoutForEditing:YES];
}

- (void)createCustomForListView:(SBIconListView *)listView {
    // Freeze list view settings to what the current global config is
    NSString *prefix = [self stringIndexOfListView:listView];

    NSMutableArray *perPage = [(NSArray *)[self rawValueForKey:@"_perPageListViews"] mutableCopy] ?: [NSMutableArray new];
    [perPage addObject:prefix];
    [self setValue:perPage forKey:@"_perPageListViews"];

    for(NSString *key in _editorOptions) {
        [self.preferences setObject:[self rawValueForKey:key] forKey:[NSString stringWithFormat:@"%@%@", prefix, key]];
    }
    [self updateLayoutForEditing:YES];
}

- (BOOL)doesCustomConfigForListViewExist:(SBIconListView *)listView;
{
    NSArray *perPage = [self rawValueForKey:@"_perPageListViews"];
    if(!perPage) return NO;

    NSString *prefix = [self stringIndexOfListView:listView];

    return [perPage containsObject:prefix];
}

// Other util

- (void)setValue:(id)val forKey:(NSString *)key {
    if([val isEqual:_defaultSettings[key]]) {
        [self.preferences removeObjectForKey:key];
    } else {
        if(![val isEqual:[self.preferences valueForKey:key]])
            [self.preferences setValue:val forKey:key];
    }
}

- (void)resetValueForKey:(NSString *)key {
    [self.preferences removeObjectForKey:key];
}

@end
