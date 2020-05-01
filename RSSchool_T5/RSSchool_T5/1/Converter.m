#import "Converter.h"

// Do not change
NSString *KeyPhoneNumber = @"phoneNumber";
NSString *KeyCountry = @"country";

@interface PNConverter ()

@property (nonatomic, assign) NSDictionary *format;
@property (nonatomic, assign) NSDictionary *phoneRegion;
@property (nonatomic, assign) NSDictionary *phoneLength;
@property (nonatomic, assign) NSMutableString *region;
@property (nonatomic, assign) NSString *string;
@property (nonatomic, assign) NSMutableString *resultNumber;

@end

@implementation PNConverter
- (NSDictionary*)converToPhoneNumberNextString:(NSString*)string; {
    
    NSString *plusSymbol = @"+";
    self.string = string;
    self.region = [NSMutableString new];
    self.resultNumber = [NSMutableString new];
    self.format = @{@"8": @"(**) ***-***",
                    @"9": @"(**) ***-**-**",
                    @"10": @"(***) ***-**-**"
    };
    self.phoneRegion = @{@"7": @"RU",
                         @"7": @"KZ",
                         @"373": @"MD",
                         @"374": @"AM",
                         @"375": @"BY",
                         @"380": @"UA",
                         @"992": @"TJ",
                         @"993": @"TM",
                         @"994": @"AZ",
                         @"996": @"KG",
                         @"998": @"UZ"};
    self.phoneLength = @{@"RU": @"10",
                         @"KZ": @"10",
                         @"MD": @"8",
                         @"AM": @"8",
                         @"BY": @"9",
                         @"UA": @"9",
                         @"TJ": @"9",
                         @"TM": @"8",
                         @"AZ": @"9",
                         @"KG": @"9",
                         @"UZ":@"9"};
    
    
    NSMutableString *prefix = [NSMutableString new];
    
    for (int i = 0; i < self.string.length; i++) {
        NSString *character = [string substringWithRange:NSMakeRange(i, 1)];
        if (i == 0 && !([character isEqualToString: plusSymbol])) {
            [self.resultNumber insertString:plusSymbol atIndex:0];
        }
        if (![character isEqualToString:plusSymbol]) {
             [prefix appendString:character];
        }
       
        
        if ([self.phoneRegion valueForKey:prefix]) {
            [self.resultNumber appendFormat:@"%@ ", prefix];
            if (prefix.length == 1) {
                if (self.string.length > 1) {
                    NSString *nextCharacter = [string substringWithRange:NSMakeRange(i+1, 1)];
                    if ([nextCharacter isEqualToString:@"7"]) {
                        [self.region appendString:@"KZ"];
                        if (self.string.length > prefix.length) {
                            [self getNumber:prefix.length];
                        }
                        return @{KeyPhoneNumber: self.resultNumber, KeyCountry: self.region};
                    } else {
                        [self.region appendString:@"RU"];
                        [self getNumber:prefix.length];
                        return @{KeyPhoneNumber: self.resultNumber, KeyCountry: self.region};
                    }
                } else {
                     [self.region appendString:@"RU"];
                    [self.resultNumber deleteCharactersInRange:NSMakeRange(2, 1)];
                     return @{KeyPhoneNumber: self.resultNumber, KeyCountry: self.region};
                }
            } else {
                NSString *currentRegion = [self.phoneRegion valueForKey:prefix];
                [self.region appendString:currentRegion];
                if (self.string.length > prefix.length) {
                    [self getNumber:prefix.length];
                } else {
                    [self.resultNumber deleteCharactersInRange:NSMakeRange(4, 1)];
                }
                return @{KeyPhoneNumber: self.resultNumber, KeyCountry: self.region};
            }
        }
    }
    if (prefix.length > 12) {
        [prefix deleteCharactersInRange:NSMakeRange(12, prefix.length - 12)];
    }
    [self.resultNumber appendString:prefix];
    
    if (![[self.resultNumber substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"+"]) {
        [self.resultNumber insertString:@"+" atIndex:0];
    }
    return @{KeyPhoneNumber: self.resultNumber,
             KeyCountry: @""};
}

- (void)getNumber:(NSInteger)prefixCount {
    NSString *phoneLengthString = [self.phoneLength valueForKey:self.region];
    NSMutableString *formatString = [self.format valueForKey:phoneLengthString];
    
    for (NSInteger j = prefixCount; j < self.string.length ; j ++) {
        NSString *character = [self.string substringWithRange:NSMakeRange(j, 1)];
        for (NSInteger k = 1; k <formatString.length; k++) {
            NSString *item = [formatString substringWithRange:NSMakeRange(k, 1)];
            if ([item isEqualToString:@"*"]) {
                formatString = [formatString stringByReplacingCharactersInRange:NSMakeRange(k, 1) withString:character].mutableCopy;
                break;
            }
        }
    }
    
    for (NSInteger j = formatString.length - 1; j > 0 ; j --) {
        NSString *objectToDelete = [formatString substringWithRange:NSMakeRange(j, 1)];
        if ([objectToDelete isEqualToString:@"*"]) {
            [formatString deleteCharactersInRange:NSMakeRange(j, 1)];
        } else if ([objectToDelete isEqualToString:@"-"]) {
            [formatString deleteCharactersInRange:NSMakeRange(j, 1)];
        } else if ([objectToDelete isEqualToString:@" "]) {
            [formatString deleteCharactersInRange:NSMakeRange(j, 1)];
        } else if ([objectToDelete isEqualToString:@")"]){
            [formatString deleteCharactersInRange:NSMakeRange(j, 1)];
        } else {
            break;
        }
    }
    [self.resultNumber appendString:formatString];
    //    return self.resultNumber;
}
@end
