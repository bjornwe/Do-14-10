//
//  ComplicationController.swift
//  Do_10-14 WatchKit Extension
//
//  Created by bjorn on 2022-01-20.
//  See https://developer.apple.com/documentation/clockkit/creating_and_updating_a_complication_s_timeline
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
	let oneHour: TimeInterval = 3600.0 // seconds
	let elevenHours: TimeInterval = 11.0 * 3600.0
	let fourteenHours: TimeInterval = 14.0 * 3600.0 // Modify this to eg one hour to easier debug its function
	
	// Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
	// Define how far into the future the app can provide data.
	func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		let pastNextBreakfast: Date = Model.timepointasdate + fourteenHours
		print("getTimelineEndDate pastNextBreakfast " + DateFormatter.short.string(from: pastNextBreakfast))
		handler(pastNextBreakfast) //.distantFuture)
	}
	
	func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		let approachingBreakfast: Date = Model.timepointasdate + elevenHours
		print("getTimelineStartDate approachingBreakfast " + DateFormatter.short.string(from: approachingBreakfast))
		handler(approachingBreakfast)
	}
	
	// Call the handler with your desired behavior when the device is locked
	func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
		handler(.showOnLockScreen)
	}
	
	func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
		let descriptors = [
			CLKComplicationDescriptor(
				identifier: "Do 14/10",
				displayName: "Do 14/10",
				supportedFamilies: CLKComplicationFamily.allCases
			)
		]
		
		handler(descriptors)
	}
	
	// Return the current timeline entry
	// "For the current timeline entry, you must specify a date equal to or earlier than the current time."
	func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
		
		let nextTimelineEntry: Date = Date() - 1.0
		let template = createTemplate(forComplication: complication, date: nextTimelineEntry)
		let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
		print("getCurrentTimelineEntry nextTimelineEntry " + DateFormatter.short.string(from: nextTimelineEntry))
		handler(entry)
	}
	
	// Batch load future timeline entries
	func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
		print("getTimelineEntries"
					+ " after " + DateFormatter.short.string(from: date)
					+ " limit " + String(limit))

		// Call the handler with the timeline entries after the given date
		let template = createTemplate(forComplication: complication, date: date)
		var entries: [CLKComplicationTimelineEntry] = []  // Create an array to hold the timeline entries.
		
		let timeFasting: TimeInterval = Date().timeIntervalSince(Model.timepointasdate)
		
		if timeFasting < fourteenHours {
			var nextEntry: Date = Model.timepointasdate + elevenHours
			
			// Three hours before breakfast we need to updates every 20 minutes for three hours (if limit so permits)
			for _ in 0...min(9,limit) {
				// Don't add entries in the past
				// If we're e.g. at 13:00h we don't add entries at 12:50h
				if(nextEntry > date) {
					let entry = CLKComplicationTimelineEntry(
						date: nextEntry,
						complicationTemplate: template)
					
					print("getTimelineEntries nextEntry " + DateFormatter.short.string(from: nextEntry))
					entries.append(entry)
				}
				nextEntry = nextEntry + (20.0 * 60.0) // 20 minutes
			}
		}
		
		handler(entries)
	}
	
	func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
		// This method will be called once per supported complication, and the results will be cached
		
		// Calculate the date 14 + 3 hours from now.
		let future = Date().addingTimeInterval(fourteenHours + (3.0 * oneHour))
		let template = createTemplate(forComplication: complication, date: future)
		print("getLocalizableSampleTemplate future " + DateFormatter.short.string(from: future))
		
		handler(template)
	}
	
	// Select the correct template based on the complication's family.
	func createTemplate(
		forComplication complication: CLKComplication,
		date: Date) -> CLKComplicationTemplate
	{
		switch complication.family {
			case .modularSmall:
				return createModularSmallTemplate(forDate: date)
			case .graphicCircular:
				return createGraphicCircleTemplate(forDate: date)
			case .circularSmall:
				return createCircularSmallTemplate(forDate: date)
			case .graphicCorner:
				return createGraphicCornerTemplate(forDate: date)
				
			case .modularLarge:
				return createModularLargeTemplate(forDate: date)
			case .utilitarianSmall, .utilitarianSmallFlat:
				return createUtilitarianSmallFlatTemplate(forDate: date)
			case .utilitarianLarge:
				return createUtilitarianLargeTemplate(forDate: date)
			case .extraLarge:
				return createExtraLargeTemplate(forDate: date)
			case .graphicRectangular:
				return createGraphicRectangularTemplate(forDate: date)
			case .graphicBezel:
				return createGraphicBezelTemplate(forDate: date)
			case .graphicExtraLarge:
				return createGraphicExtraLargeTemplate(forDate: date)
				
			default:
				return createModularSmallTemplate(forDate: date) // Try the small one as last resort
		}
	}
	
	// Make sure the functions below are not private as they are used in ContentView
	
	// Return a modular small template.
	func createModularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let label = CLKSimpleTextProvider(text: Model.timepointasstring)
		let actualValue = CLKSimpleTextProvider(text: Model.dayofweek)
		
		// Create the template using the providers.
		return CLKComplicationTemplateModularSmallStackText(line1TextProvider: label,
																												line2TextProvider: actualValue)
	}
	
	// After setting a time point we have 14 hours of fasting until we can eat breakfast again
	// We want to know when we are approaching breakfast.
	// Start notifying at 3 hours before so e.g 2 hours before equals 0.33
	// 3 hours ahead is chosen because during weekend we might select to fast only 12 hours
	func getFillFraction() -> Float {
		var timeFraction: Float
		let timeFasting: TimeInterval = Date().timeIntervalSince(Model.timepointasdate)
				
		// At 3 hours before breakfast the time fraction starts to rise from zero
		// and it goes up to one at breakfast time
		if (timeFasting < elevenHours) { timeFraction = 0.0 }
		else if (timeFasting > (fourteenHours + oneHour + oneHour)) { timeFraction = 0.0 } // At 2h after breakfast we skip the reminder
		else if (timeFasting > fourteenHours) { timeFraction = 1.0 }
		else {
			timeFraction = Float((timeFasting - elevenHours) / ( 3.0 * oneHour))
		}
		return timeFraction
	}
	
	// Return a graphic circle template.
	func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
		
		let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
																							 gaugeColors: [.black, .darkGray, .lightGray, .white],
																							 gaugeColorLocations: [0.01, 0.33, 0.66, 0.99] as [NSNumber],
																							 fillFraction: (getFillFraction()))
		
		let atHour = CLKSimpleTextProvider(text: Model.timepointasstring)
		
		// Extract first two char's of week day e.g 'MO'
		let t = Model.dayofweek
		let dayofweek = CLKSimpleTextProvider(text: String(t[t.startIndex]) + String(t[t.index(after: t.startIndex)]))
		print("GraphicCircle " + Model.timepointasstring + " " + Model.dayofweek)
		
		// Create the template using the providers.
		return CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gaugeProvider,
																																		 bottomTextProvider: atHour,
																																		 centerTextProvider: dayofweek)
	}
	
	// Return a circular small template.
	func createCircularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let label = CLKSimpleTextProvider(text: Model.timepointasstring)
		let actualValue = CLKSimpleTextProvider(text: Model.dayofweek)
		print("CircularSmall "+Model.timepointasstring)
		
		// Create the template using the providers.
		return CLKComplicationTemplateCircularSmallStackText(line1TextProvider: label,
																												 line2TextProvider: actualValue)
	}
	
	// Return a graphic corner small template.
	func createGraphicCornerTemplate(forDate date: Date) -> CLKComplicationTemplate {
		print("GraphicCornerStackText " + Model.timepointasstring)
		
		return CLKComplicationTemplateGraphicCornerStackText(
			innerTextProvider: CLKSimpleTextProvider(text: Model.dayofweek),
			outerTextProvider: CLKSimpleTextProvider(text: Model.timepointasstring) )
	}
	
	// Return a modular large template.
	func createModularLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let titleTextProvider = CLKSimpleTextProvider(text: Model.timepointasstring)
		let actualValue = CLKSimpleTextProvider(text: Model.dayofweek)
		print("ModularLarge "+Model.timepointasstring)
		
		// Create the template using the providers.
		let imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "55x55")!)
		return CLKComplicationTemplateModularLargeStandardBody(headerImageProvider: imageProvider,
																													 headerTextProvider: titleTextProvider,
																													 body1TextProvider: actualValue,
																													 body2TextProvider: CLKSimpleTextProvider(text: ""))
	}
	
	// Return a utilitarian small flat template.
	func createUtilitarianSmallFlatTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let flatUtilitarianImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "55x55")!)
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring + " " + Model.dayofweek)
		print("UtilitarianSmall "+Model.timepointasstring)
		
		// Create the template using the providers.
		return CLKComplicationTemplateUtilitarianSmallFlat(textProvider: actualValue,
																											 imageProvider: flatUtilitarianImageProvider)
	}
	
	// Return a utilitarian large template.
	func createUtilitarianLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let flatUtilitarianImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "55x55")!)
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring + " " + Model.dayofweek)
		print("UtilitarianLarge "+Model.timepointasstring)
		
		// Create the template using the providers.
		return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: actualValue,
																											 imageProvider: flatUtilitarianImageProvider)
	}
	
	// Return an extra large template.
	func createExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let label = CLKSimpleTextProvider(text: Model.timepointasstring)
		let actualValue = CLKSimpleTextProvider(text: Model.dayofweek)
		print("ExtraLarge "+Model.timepointasstring)
		
		// Create the template using the providers.
		return CLKComplicationTemplateExtraLargeStackText(line1TextProvider: label,
																											line2TextProvider: actualValue)
	}
	
	// Return a large rectangular graphic template.
	func createGraphicRectangularTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let image = UIImage(named: "55x55")
		let imageProvider = CLKFullColorImageProvider(fullColorImage: image!)
		let titleTextProvider = CLKSimpleTextProvider(text: "  " + Model.timepointasstring + " " + Model.dayofweek)
		let actualValue = CLKSimpleTextProvider(text: "")
		
		print("GraphicRectangular "+Model.timepointasstring)
		
		let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
																							 gaugeColors: [.black, .darkGray, .lightGray, .white],
																							 gaugeColorLocations: [0.01, 0.33, 0.66, 0.99] as [NSNumber],
																							 fillFraction: (getFillFraction()))
		
		return CLKComplicationTemplateGraphicRectangularTextGauge(headerImageProvider: imageProvider,
																															headerTextProvider: titleTextProvider,
																															body1TextProvider: actualValue,
																															gaugeProvider: gaugeProvider)
	}
	
	// Return a circular template with text that wraps around the top of the watch's bezel.
	func createGraphicBezelTemplate(forDate date: Date) -> CLKComplicationTemplate {
		
		// Create a graphic circular template with an image provider
		let image = UIImage(named: "55x55")
		let circle = CLKComplicationTemplateGraphicCircularImage(
			imageProvider: CLKFullColorImageProvider(fullColorImage: image!))
		let actualValue = CLKSimpleTextProvider(text: (Model.timepointasstring + "  " + Model.dayofweek))
		print("GraphicBezel "+Model.timepointasstring)
		
		// Create the bezel template using the circle template and the text provider.
		return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: circle,
																													 textProvider: actualValue)
	}
	
	// Returns an extra large graphic template.
	func createGraphicExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
		
		print("GraphicExtraLarge "+Model.timepointasstring)
		
		return CLKComplicationTemplateGraphicExtraLargeCircularStackText(
			line1TextProvider: CLKSimpleTextProvider(text: Model.timepointasstring),
			line2TextProvider: CLKSimpleTextProvider (text: Model.dayofweek))
	}
}

// https://sarunw.com/posts/how-to-use-dateformatter/
extension DateFormatter {
	static let short: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "y-MM-dd E HH:mm"
		return df
	}()
}
