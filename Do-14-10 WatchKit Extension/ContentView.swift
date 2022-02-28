//
//  ContentView.swift
//  Do-14-10 WatchKit Extension
//
//  Created by bjorn on 2022-01-31.
//
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-read-the-digital-crown-on-watchos-using-digitalcrownrotation
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var model: Model
	@State var crownValue: Float = 0.0
	
	var body: some View {
		
		VStack {
			HStack {
				Button("-10 min")
				 {
					 model.setTimepointasdate(newDate: Model.timepointasdate - 600)
					 crownValue = 0.0
				 }
				 .buttonStyle(.borderedProminent)
				 .buttonBorderShape(.capsule)
				
				Button("+10 min")
				{
					model.setTimepointasdate(newDate: Model.timepointasdate + 600)
					crownValue = 0.0
				}
				.buttonStyle(.borderedProminent)
				.buttonBorderShape(.capsule)
			}
			
			Text(model.timepointinstancestring + " " + model.dayofweekinstancestring).font(.title)
			
			HStack(alignment: .center) {
				Button( (crownValue == 0.0) ? "Now" : "Add" ) {
					model.setTimepointasdate(newDate: (Date() + Double(crownValue * 3600.0)))
					crownValue = 0.0
				}
				.buttonStyle(.borderedProminent)
				.buttonBorderShape(.capsule)

				Text(" \(crownValue, specifier: "%.0f")h")
					.focusable(true)
					.digitalCrownRotation(
						$crownValue,
						from: -24.0, through: +24.0, by: 1.0,
						sensitivity: .low,
						isHapticFeedbackEnabled: true
					)
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		Group {  // Max 10 items in group
			//ComplicationController().createModularSmallTemplate(forDate: Date()).previewContext()
			//ComplicationController().createGraphicCircleTemplate(forDate: Date()).previewContext()
			//ComplicationController().createCircularSmallTemplate(forDate: Date()).previewContext()
			//ComplicationController().createGraphicCornerTemplate(forDate: Date()).previewContext()
			//ComplicationController().createModularLargeTemplate(forDate: Date()).previewContext()
			//ComplicationController().createUtilitarianSmallFlatTemplate(forDate: Date()).previewContext()
			//ComplicationController().createUtilitarianLargeTemplate(forDate: Date()).previewContext()
			//ComplicationController().createExtraLargeTemplate(forDate: Date()).previewContext()
			//ComplicationController().createGraphicRectangularTemplate(forDate: Date()).previewContext()
			//ComplicationController().createGraphicBezelTemplate(forDate: Date()).previewContext()
			ComplicationController().createGraphicExtraLargeTemplate(forDate: Date()).previewContext()
		}
	}
}
