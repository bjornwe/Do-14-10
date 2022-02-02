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
		
		// Indicate that the app can provide timeline entries for the next 48 hours.
		// let next48hours: Date = Date().addingTimeInterval(48.0 * 60.0 * 60.0)
		
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
				supportedFamilies: CLKComplicationFamily.allCases  //,
				//userInfo: myDictionary
			)
		]
		
		// Call the handler with the currently supported complication descriptors
		handler(descriptors)
	}
	
	// Return the current timeline entry
	func getCurrentTimelineEntry(
		for complication: CLKComplication,
		withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
	) {
		let template = createTemplate(forComplication: complication, date: Date())
		
		let entry = CLKComplicationTimelineEntry(
			date: Date(), complicationTemplate: template)
		
		handler(entry)
	}
	
	// Return future timeline entries.
	func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
		
		// Call the handler with the timeline entries after the given date
		let template = createTemplate(forComplication: complication, date: date)
		
		// Create an array to hold the timeline entries.
		var entries: [CLKComplicationTimelineEntry] = []
		
		for i in 0..<60 {
			entries.append(CLKComplicationTimelineEntry(
				date: date + Double(i), complicationTemplate: template))
		}
		
		/*let marks = [12.0 , 24.0 , 36.0 , 48.0]
		for hour in marks {
			entries.append(CLKComplicationTimelineEntry(
				date: date + hour, complicationTemplate: template))
		}*/
		
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
	private func createTemplate(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTemplate {
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
	
	// Return a modular small template.
	private func createModularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let label = CLKSimpleTextProvider(text: "14/10")
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring)
		print("ModularSmall "+Model.timepointasstring)
	
		// Create the template using the providers.
		return CLKComplicationTemplateModularSmallStackText(line1TextProvider: label,
																												line2TextProvider: actualValue)
	}
	
	// Return a graphic circle template.
	private func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
		
		var timeRemaining: TimeInterval = 0.0
		timeRemaining = Date().timeIntervalSince(Model.timepointasdate) - (24.0 * 60.0 * 60.0)
		if timeRemaining > 1.0 { timeRemaining = 1.0 }
		if timeRemaining < 0.0 { timeRemaining = 0.0 }
		
		// Create the data providers.
			let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
																							 gaugeColors: [.green, .yellow, .red],
																								 gaugeColorLocations: [0.0, 0.5, 0.75] as [NSNumber],
																								 fillFraction: Float(timeRemaining))
		
		let atHour = CLKSimpleTextProvider(text: String(Model.timepointasstring))
		let dayofweek = CLKSimpleTextProvider(text: Model.dayofweek)
		print("GraphicCircle "+Model.timepointasstring+" "+String(Model.counter))

		// Create the template using the providers.
		return CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gaugeProvider,
																																		 bottomTextProvider: atHour,
																																		 centerTextProvider: dayofweek)
	}
	
	// Return a circular small template.
	private func createCircularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let label = CLKSimpleTextProvider(text: "14/10")
		let actualValue = CLKSimpleTextProvider(text: String(Model.counter)) // Model.timepointasstring)
		print("CircularSmall "+Model.timepointasstring)
		
		// Create the template using the providers.
		return CLKComplicationTemplateCircularSmallStackText(line1TextProvider: label,
																												 line2TextProvider: actualValue)
	}
	
	// Return a circular small template.
	private func createGraphicCornerTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		//let label = CLKSimpleTextProvider(text: "14/10")
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring)
		let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
																							 gaugeColors: [.green, .yellow, .red],
																							 gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
																							 fillFraction: 0.5)
		print("GraphicCorner "+Model.timepointasstring)
		
		// Create the template using the providers.
		return CLKComplicationTemplateGraphicCornerGaugeText(gaugeProvider: gaugeProvider,
																												 leadingTextProvider: CLKSimpleTextProvider(text: "a"),
																												 trailingTextProvider: CLKSimpleTextProvider(text: "b"),
																												 outerTextProvider: actualValue)
	}
	
	// Return a modular large template.
	private func createModularLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let titleTextProvider = CLKSimpleTextProvider(text: "14/10", shortText: "14/10")
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring)
		print("ModularLarge "+Model.timepointasstring)
		
		// Create the template using the providers.
		let imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "55x55")!)
		return CLKComplicationTemplateModularLargeStandardBody(headerImageProvider: imageProvider,
																													 headerTextProvider: titleTextProvider,
																													 body1TextProvider: actualValue,
																													 body2TextProvider: CLKSimpleTextProvider(text: "2345"))
	}
	// Return a utilitarian small flat template.
	private func createUtilitarianSmallFlatTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let flatUtilitarianImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "55x55")!)
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring)
		print("UtilitarianSmall "+Model.timepointasstring)
		
		// Create the template using the providers.
		return CLKComplicationTemplateUtilitarianSmallFlat(textProvider: actualValue,
																											 imageProvider: flatUtilitarianImageProvider)
	}
	
	// Return a utilitarian large template.
	private func createUtilitarianLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let flatUtilitarianImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "55x55")!)
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring)
		print("UtilitarianLarge "+Model.timepointasstring)
		
		// Create the template using the providers.
		return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: actualValue,
																											 imageProvider: flatUtilitarianImageProvider)
	}
	
	// Return an extra large template.
	private func createExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let label = CLKSimpleTextProvider(text: "14/10")
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring)
		print("ExtraLarge "+Model.timepointasstring)
		
		// Create the template using the providers.
		return CLKComplicationTemplateExtraLargeStackText(line1TextProvider: label,
																											line2TextProvider: actualValue)
	}
	// Return a large rectangular graphic template.
	private func createGraphicRectangularTemplate(forDate date: Date) -> CLKComplicationTemplate {
		// Create the data providers.
		let image = UIImage(named: "55x55")
		let imageProvider = CLKFullColorImageProvider(fullColorImage: image!)
		let titleTextProvider = CLKSimpleTextProvider(text: "14/10", shortText: "14/10")
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring)
		let percentage = Float(1.0)
		print("GraphicRectangular "+Model.timepointasstring)
		
		let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
																							 gaugeColors: [.green, .yellow, .red],
																							 gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
																							 fillFraction: percentage)
		
		return CLKComplicationTemplateGraphicRectangularTextGauge(headerImageProvider: imageProvider,
																															headerTextProvider: titleTextProvider,
																															body1TextProvider: actualValue,
																															gaugeProvider: gaugeProvider)
	}
	// Return a circular template with text that wraps around the top of the watch's bezel.
	private func createGraphicBezelTemplate(forDate date: Date) -> CLKComplicationTemplate {

		// Create a graphic circular template with an image provider
		let image = UIImage(named: "55x55")
		let circle = CLKComplicationTemplateGraphicCircularImage(
			imageProvider: CLKFullColorImageProvider(fullColorImage: image!))
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring)
		print("GraphicBezel "+Model.timepointasstring)
		
		// Create the bezel template using the circle template and the text provider.
		return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: circle,
																													 textProvider: actualValue)
	}
	
	// Returns an extra large graphic template.
	private func createGraphicExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
		
		// Create the data providers.
		let percentage = Float(1.0)
		let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
																							 gaugeColors: [.green, .yellow, .red],
																							 gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
																							 fillFraction: percentage)
		let actualValue = CLKSimpleTextProvider(text: Model.timepointasstring)
		print("GraphicExtraLarge "+Model.timepointasstring)
		
		return CLKComplicationTemplateGraphicExtraLargeCircularOpenGaugeSimpleText(
			gaugeProvider: gaugeProvider,
			bottomTextProvider: CLKSimpleTextProvider(text: "3456"),
			centerTextProvider: actualValue)
	}
}
