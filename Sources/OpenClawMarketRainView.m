#import <ScreenSaver/ScreenSaver.h>
#import <AppKit/AppKit.h>

@interface OpenClawMarketRainView : ScreenSaverView
@property NSMutableArray *streams;
@end

@implementation OpenClawMarketRainView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1.0/30.0];
        self.streams = [NSMutableArray array];
        // reset later after real bounds exist
    }
    return self;
}

- (NSString *)token {
    NSArray *t = @[@"NVDA",@"BTC",@"ETH",@"RKLB",@"LUNR",@"ASTS",@"PLTR",@"SPY",@"QQQ"];
    NSString *s = t[arc4random_uniform((uint32_t)t.count)];
    int r = arc4random_uniform(100);
    if (r < 55) return s;
    if (r < 75) return [s stringByAppendingString:(arc4random_uniform(2) ? @"▲" : @"▼")];
    if (r < 90) return [NSString stringWithFormat:@"%@%.2f%%", arc4random_uniform(2) ? @"+" : @"-", ((float)arc4random_uniform(500))/100.0 + 0.1];
    return [NSString stringWithFormat:@"$%.2f", ((float)arc4random_uniform(50000))/100.0];
}

- (void)resetStreams {
    [self.streams removeAllObjects];
    CGFloat width = MAX(self.bounds.size.width, 800);
    int count = MAX(12, (int)(width / 86));
    for (int i = 0; i < count; i++) {
        NSMutableArray *tokens = [NSMutableArray array];
        for (int j = 0; j < 24; j++) [tokens addObject:[self token]];
        [self.streams addObject:@{
            @"x": @(i * 86 + 12),
            @"y": @(self.bounds.size.height + arc4random_uniform(600)),
            @"speed": @(((float)arc4random_uniform(240))/100.0 + 1.8),
            @"tokens": tokens
        }.mutableCopy];
    }
}

- (void)animateOneFrame {
    if (self.streams.count == 0 || self.bounds.size.width < 10 || self.bounds.size.height < 10) { [self resetStreams]; }
    for (NSMutableDictionary *s in self.streams) {
        CGFloat y = [s[@"y"] doubleValue];
        CGFloat speed = [s[@"speed"] doubleValue];
        y -= speed;

        NSMutableArray *tokens = s[@"tokens"];
        if (y + tokens.count * 22 < 0) {
            y = self.bounds.size.height + arc4random_uniform(300);
        }

        [tokens removeLastObject];
        [tokens insertObject:[self token] atIndex:0];
        s[@"y"] = @(y);
    }
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
    if (self.streams.count == 0) { [self resetStreams]; }
    [[NSColor blackColor] setFill];
    NSRectFill(rect);

    NSFont *font = [NSFont monospacedSystemFontOfSize:18 weight:NSFontWeightRegular];
    NSFont *hudFont = [NSFont monospacedSystemFontOfSize:14 weight:NSFontWeightRegular];

    for (NSDictionary *s in self.streams) {
        CGFloat x = [s[@"x"] doubleValue];
        CGFloat y = [s[@"y"] doubleValue];
        NSArray *tokens = s[@"tokens"];

        for (NSUInteger i = 0; i < tokens.count; i++) {
            CGFloat yy = y + i * 22;
            if (yy < -40 || yy > self.bounds.size.height + 40) continue;

            CGFloat alpha = MAX(0.05, 1.0 - ((CGFloat)i / tokens.count));
            NSColor *color = i == 0
                ? [NSColor colorWithCalibratedRed:0.85 green:1.0 blue:0.85 alpha:1.0]
                : [NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.35 alpha:alpha * 0.85];

            [tokens[i] drawAtPoint:NSMakePoint(x, yy)
                     withAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: color}];
        }
    }

    NSString *hud = @"OpenClaw Market Rain · Native ObjC Saver · Version 1.9.9";
    [hud drawAtPoint:NSMakePoint(14, 14)
      withAttributes:@{
        NSFontAttributeName: hudFont,
        NSForegroundColorAttributeName: [NSColor colorWithCalibratedRed:0 green:1 blue:0.35 alpha:0.95]
      }];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    // reset later after real bounds exist
}

@end
