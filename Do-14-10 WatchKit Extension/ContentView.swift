//
//  ContentView.swift
//  Do-14-10 WatchKit Extension
//
//  Created by bjorn on 2022-01-31.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var model: Model
	
	var body: some View {
		
		VStack {
			HStack {
				Button("-10 min") { model.setTimepointasdate(new: Model.timepointasdate - 600)}
				Button("+10 min") { model.setTimepointasdate(new: Model.timepointasdate + 600)}
			}
			.buttonStyle(.bordered)
			
			Text(model.weekdayinstancestring + " " + model.timepointinstancestring).font(.title)
			
			Button("Now") { model.setTimepointasdate(new: Date())}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(model: Model())
	}
}
