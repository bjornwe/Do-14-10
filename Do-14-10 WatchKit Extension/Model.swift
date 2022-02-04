//
//  Model.swift
//  Do-14-10 WatchKit Extension
//
//  Created by bjorn on 2022-02-01.
//

import SwiftUI
import ClockKit

//@MainActor
class Model: ObservableObject {
	static let shared = Model()
	
	// Static variables
	static var timepointasstring: String = "xx:yy" // Used in ComplicationController to auto-update complication
	static var timepointasdate: Date = Date()
	static var dayofweek: String = ""
	
	// Instance variable
	@Published var timepointinstancestring: String = "xx:yy"  // Used to auto-update ContentView
	@Published var weekdayinstancestring: String = ""
	
	init() {
		print("Model init")
		
		// Load from files
		self.timepointinstancestring = self.fetchfromfile(filename: "timepoint.txt")
		self.weekdayinstancestring = self.fetchfromfile(filename: "dayofweek.txt")
		
		// Copy from instance to static variables
		Model.timepointasstring = self.timepointinstancestring
		Model.dayofweek = self.weekdayinstancestring
		
		Task.detached {
			await self.updateComplications()
		}
	}
	
	public func setTimepointasdate(new: Date)  -> Void
	{
		Model.timepointasdate = new
		
		// Set static variables
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		Model.timepointasstring = dateFormatter.string(from: new)
		
		dateFormatter.dateFormat = "E"
		Model.dayofweek = dateFormatter.string(from: new)
		
		// Set instance variables
		self.timepointinstancestring = Model.timepointasstring
		self.weekdayinstancestring = Model.dayofweek

		// Store to files
		self.storetofile(filename: "timepoint.txt", value: Model.timepointasstring)
		self.storetofile(filename: "dayofweek.txt", value: Model.dayofweek)

		Task.detached {
			await self.updateComplications()
		}
	}
	
	func storetofile(filename: String, value: String) -> Void
	{
		if let documentDirectory = FileManager.default.urls(
			for: .documentDirectory,
				 in: .userDomainMask).first
		{
			print(filename + " is set to " + value)
			
			let pathWithFilename = documentDirectory.appendingPathComponent(filename)
			do
			{
				try value.write(to: pathWithFilename, atomically: false, encoding: .utf8)
			}
			catch
			{
				print("storetofile got ERR 1")
			}
		}
	}
	
	// https://stackoverflow.com/questions/24097826/read-and-write-a-string-from-text-file
	func fetchfromfile(filename: String) -> String
	{
		var value: String = "ERR 2"
		
		// file:///Users/bjorn/Library/Developer/CoreSimulator/Devices/DE061987-206E-49FF-8CBF-09DA249220A3/data/Containers/Data/PluginKitPlugin/87C33D9C-DA0F-4EF9-9798-14A78E01C9D0/Documents/
		if let documentDirectory = FileManager.default.urls(
			for: .documentDirectory,
			in: .userDomainMask).first
		{
			
			let pathWithFilename = documentDirectory.appendingPathComponent(filename)
			
			do
			{
				value = try String(contentsOf: pathWithFilename, encoding: .utf8)
			}
			catch
			{
				print("fetchfromfile got ERR 2")
			}
		}
		
		print(filename + " contained " + value)
		return value
	}
	
	// Asynchronously update any active complications
	private func updateComplications() async {
		// Update any complications on active watch faces.
		let server = CLKComplicationServer.sharedInstance()
		let complications = await server.getActiveComplications()
		
		for complication in complications {
			server.reloadTimeline(for: complication)
		}
	}
}

extension CLKComplicationServer {
	
	// Safely access the server's active complications.
	@MainActor
	func getActiveComplications() async -> [CLKComplication] {
		return await withCheckedContinuation { continuation in
			
			// First, set up the notification.
			let center = NotificationCenter.default
			let mainQueue = OperationQueue.main
			var token: NSObjectProtocol?
			token = center.addObserver(forName: .CLKComplicationServerActiveComplicationsDidChange, object: nil, queue: mainQueue) { _ in
				center.removeObserver(token!)
				continuation.resume(returning: self.activeComplications!)
			}
			
			// Then check to see if we have a valid active complications array.
			if activeComplications != nil {
				center.removeObserver(token!)
				continuation.resume(returning: self.activeComplications!)
			}
		}
	}
}
