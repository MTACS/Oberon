@interface SBMediaController
+ (id)sharedInstance;
- (BOOL)playForEventSource:(long long)arg1;
- (BOOL)pauseForEventSource:(long long)arg1;
- (BOOL)isPaused;
- (BOOL)isPlaying; 
@end

@interface SBSApplicationShortcutIcon: NSObject
@end

@interface SBSApplicationShortcutItem : NSObject
@property (nonatomic, retain) NSString *type;
@property (nonatomic,copy) NSString * localizedTitle;
@property (nonatomic,copy) SBSApplicationShortcutIcon * icon;
@property (nonatomic,copy) NSString * bundleIdentifierToLaunch;
@end

@interface SBSApplicationShortcutCustomImageIcon : SBSApplicationShortcutIcon
@property (nonatomic, readwrite) BOOL isTemplate;   
- (id)initWithImagePNGData:(id)arg1;
- (BOOL)isTemplate;
@end

@interface SBIcon
-(id)applicationBundleID;
@end

@interface SBIconView 
- (SBIcon *)icon;
@end

%hook SBIconView

- (void)setApplicationShortcutItems:(NSArray *)arg1 {

	NSMutableArray *originalItems = [[NSMutableArray alloc] init];

	for (SBSApplicationShortcutItem *item in arg1) {

		[originalItems addObject:item];

	}

	SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];

	BOOL isPlaying = [mediaController isPlaying];

	BOOL isPaused = [mediaController isPaused];

	NSData *playData = UIImagePNGRepresentation([[UIImage imageWithContentsOfFile:@"/Library/Application Support/Oberon/play.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]);

	NSData *pauseData = UIImagePNGRepresentation([[UIImage imageWithContentsOfFile:@"/Library/Application Support/Oberon/pause.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]);

	SBSApplicationShortcutItem *playPauseItem = [%c(SBSApplicationShortcutItem) alloc];
	
	if (isPaused == YES && isPlaying == NO) {
	
		playPauseItem.localizedTitle = @"Play";

		SBSApplicationShortcutCustomImageIcon *icon = [[SBSApplicationShortcutCustomImageIcon alloc] initWithImagePNGData:playData];
		
		[playPauseItem setIcon:icon];

	} else if (isPaused == NO && isPlaying == YES) {

		playPauseItem.localizedTitle = @"Pause";

		SBSApplicationShortcutCustomImageIcon *icon = [[SBSApplicationShortcutCustomImageIcon alloc] initWithImagePNGData:pauseData];
		
		[playPauseItem setIcon:icon];

	}

	playPauseItem.type = @"com.mtac.oberon.playpause";

	if (isPlaying || isPaused) {
	
		[originalItems addObject:playPauseItem];
	
	}

	if ([self.icon.applicationBundleID isEqualToString:@"com.apple.Music"] || [self.icon.applicationBundleID isEqualToString:@"com.spotify.client"]) {

		%orig(originalItems);

	}

	%orig;

}

+ (void)activateShortcut:(SBSApplicationShortcutItem*)item withBundleIdentifier:(NSString*)bundleID forIconView:(SBIconView *)iconView {

	if ([[item type] isEqualToString:@"com.mtac.oberon.playpause"]) {

		SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];

		BOOL isPlaying = [mediaController isPlaying];

		BOOL isPaused = [mediaController isPaused];

		if (isPaused) {

			[mediaController playForEventSource:1];

		} 

		if (isPlaying) {

			[mediaController pauseForEventSource:1];

		}

	} else {

		%orig;

	}

}

%end