//
//  ComplicationController.swift
//  Do_10-14 WatchKit Extension
//
//  Created by bjorn on 2022-01-20.
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
	var model = Model.shared
	
	// MARK: - Complication Configuration
	
	func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		// Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
		
		// Define how far into the future the app can provide data.
		handler(.distantFuture)
	}
	
	func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
		// Call the handler with your desired behavior when the device is locked
		
		handler(.showOnLockScreen)
	}
	
	func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
		//let myDictionary = ["timepoint":timepointasstring]
		let descriptors = [
			CLKComplicationDescriptor(
				identifier: "Do_14/10",
				displayName: "14/10",
				supportedFamilies: CLKComplicationFamily.allCases
			)
		]

		handler(descriptors)
	}
	
	// Return the current timeline entry
	func getCurrentTimelineEntry(
		for complication: CLKComplication,
		withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
	) {
		let template = createTemplate(forComplication: complication, date: Date())
		let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
		
		handler(entry)
	}
	
	// Return future timeline entries.
	func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
		
		// Call the handler with the timeline entries after the given date
		let template = createTemplate(forComplication: complication, date: date)
		
		// Create an array to hold the timeline entries.
		var entries: [CLKComplicationTimelineEntry] = []
		
		let hours = [12 , 24 , 36 , 48]
	
		for i in hours {
			let entry = CLKComplicationTimelineEntry(
				date: date + Double(i),
				complicationTemplate: template)
			
			entries.append(entry)
		}
		
		handler(entries)
	}
	
	func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
		// This method will be called once per supported complication, and the results will be cached
		
		// Calculate the date 49 hours from now.
		// Since it's more than 48 hours in the future,
		// Our template will always show zero cups and zero mg caffeine.
		let future = Date().addingTimeInterval(49.0 * 60.0 * 60.0)
		let template = createTemplate(forComplication: complication, date: future)
		
		handler(template)
	}

	// MARK: - Sample Templates
	
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
				return createModularSmallTemplate(forDate: date) // Try the small one anyway
		}
	}
	
	// Make sure the functions below are not private as they are used in ContentView
	
	// Return a modular small template.
	func createModularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let label = CLKSimpleTextProvider(text: Model.timepointasstring)
		let actualValue = CLKSimpleTextProvider(text: Model.dayofweek)
		print("ModularSmall "+Model.timepointasstring)
	
		// Create the template using the providers.
		return CLKComplicationTemplateModularSmallStackText(line1TextProvider: label,
																												line2TextProvider: actualValue)
	}
	
	// Return a graphic circle template.
	func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
		
		var timeRemaining: TimeInterval = 0.0
		timeRemaining = (24.0 * 60.0 * 60.0) - Date().timeIntervalSince(Model.timepointasdate)
		if timeRemaining > 1.0 { timeRemaining = 1.0 }
		if timeRemaining < 0.0 { timeRemaining = 0.0 }
		
		// Create the data providers.
			let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
																								 gaugeColors: [.black, .darkGray, .lightGray, .white],
																								 gaugeColorLocations: [0.0, 0.5, 0.75, 0.99] as [NSNumber],
																								 fillFraction: Float(timeRemaining))
		
		let atHour = CLKSimpleTextProvider(text: Model.timepointasstring)
		let t = Model.dayofweek
		let dayofweek = CLKSimpleTextProvider(text: String(t[t.startIndex]) + String(t[t.index(after: t.startIndex)]))  // First two char's
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
		
		var timeRemaining: TimeInterval = 0.0
		timeRemaining = (24.0 * 60.0 * 60.0) - Date().timeIntervalSince(Model.timepointasdate)
		if timeRemaining > 1.0 { timeRemaining = 1.0 }
		if timeRemaining < 0.0 { timeRemaining = 0.0 }
		
		// Create the data providers.
		let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
																							gaugeColors: [.black, .darkGray, .lightGray, .white],
																							gaugeColorLocations: [0.0, 0.5, 0.75, 0.99] as [NSNumber],
																							fillFraction: (1.0 - Float(timeRemaining)))
		
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
		
		return CLKComplicationTemplateExtraLargeStackText(
			line1TextProvider: CLKSimpleTextProvider(text: Model.timepointasstring),
			line2TextProvider: CLKSimpleTextProvider (text: Model.dayofweek))
	}
}
