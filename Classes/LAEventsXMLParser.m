//
//  LAEventsXMLParser.m
//  fosdem
//
//  Created by Leon on 10/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LAEventsXMLParser.h"


@implementation LAEventsXMLParser

@synthesize delegate;

- (LAEventsXMLParser *) initWithData: (NSData *) xmlData delegate: (id) newDelegate {
    if (self = [super init]) {
        [self setDelegate: newDelegate];
        
        eventsXMLParser = [[NSXMLParser alloc] initWithData: xmlData];
        [eventsXMLParser setDelegate: self];
    }
    
    return self;
}

- (BOOL) parse {
    return [eventsXMLParser parse];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentStringValue) {
        // currentStringValue is an NSMutableString instance variable
        currentStringValue = [[NSMutableString alloc] init];
    }
    [currentStringValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString: @"event"]) {
        
        currentEvent = [[LAEvent alloc] init];
        [currentEvent setIdentifier: [attributeDict objectForKey: @"id"]];
    }
    
    if ([elementName isEqualToString: @"day"]) {
        currentDayString = [attributeDict objectForKey: @"date"];
    }
    
    if ([elementName isEqualToString: @"start"] || [elementName isEqualToString: @"duration"] || 
        [elementName isEqualToString: @"room"] || [elementName isEqualToString: @"title"] ||
        [elementName isEqualToString: @"subtitle"] || [elementName isEqualToString: @"track"] ||
        [elementName isEqualToString: @"type"] || [elementName isEqualToString: @"abstract"] ||
        [elementName isEqualToString: @"description"] || [elementName isEqualToString: @"person"]) {
        [currentStringValue setString: @""];
    }
    
    
}
                                        
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

    if ([elementName isEqualToString: @"start"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm"];
        
        NSString *eventStartDateString = [NSString stringWithFormat: @"%@ %@", currentDayString, currentStringValue];
        
        NSDate *eventStartDate = [dateFormatter dateFromString: eventStartDateString];
        
        [currentEvent setStartDate: eventStartDate];
        
        [dateFormatter release];
    }
    
    
    if ([elementName isEqualToString: @"duration"]) {
        // Crude XML format, crude parsing... here we go!
        // The duration looks something like this HH:mm
        
        NSRange hoursRange = {0, 2};
        NSRange minutesRange = {3, 2};
        int hours = [[currentStringValue substringWithRange: hoursRange] intValue];
        int minutes = [[currentStringValue substringWithRange: minutesRange] intValue];
        
        NSTimeInterval duration = (double) (hours * 3600) + (minutes * 60);
        NSDate *eventEndDate;
        
        if ([currentEvent startDate] != nil) {
            eventEndDate = [[currentEvent startDate] addTimeInterval: duration];
        }
        else {
            eventEndDate = [NSDate date];
        }

        [currentEvent setEndDate: eventEndDate];
    }
    
    if ([elementName isEqualToString: @"room"]) {
        [currentEvent setRoom: [NSString stringWithString: currentStringValue]];
    }
    if ([elementName isEqualToString: @"title"]) {
        [currentEvent setTitle: [NSString stringWithString: currentStringValue]];
    }
    if ([elementName isEqualToString: @"subtitle"]) {
        [currentEvent setSubtitle: [NSString stringWithString: currentStringValue]];
    }
    if ([elementName isEqualToString: @"track"]) {
        [currentEvent setTrack: [NSString stringWithString: currentStringValue]];
    }
    if ([elementName isEqualToString: @"type"]) {
        [currentEvent setType: [NSString stringWithString: currentStringValue]];
    }
    if ([elementName isEqualToString: @"abstract"]) {
        [currentEvent setContentAbstract: [NSString stringWithString: currentStringValue]];
    }
    if ([elementName isEqualToString: @"description"]) {
        [currentEvent setContentDescription: [NSString stringWithString: currentStringValue]];
    }
    if ([elementName isEqualToString: @"person"]) {
        [currentEvent setSpeaker: [NSString stringWithString: currentStringValue]];
    }
    
    if ([elementName isEqualToString: @"event"]) {
        [delegate parser: self foundEvent: [currentEvent autorelease]];
    }
    
    if ([elementName isEqualToString: @"schedule"]) {
        [delegate parserDidEndDocument: self];
    }
    

}

@end