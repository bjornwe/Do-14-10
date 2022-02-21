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
	
	// Static variables
	static var timepointasstring: String = "..." // Used in ComplicationController to auto-update complication
	static var dayofweek: String = ""
	static var timepointasdate: Date = Date()
	
	// Instance variable
	@Published var timepointinstancestring: String = "..."  // Used to auto-update ContentView
	@Published var dayofweekinstancestring: String = ""
	@Published var timepointinstanceasdate: Date = Date()
	
	init() {
		print("Model init")
		
		// Load from files
		let storedtimepointasstring = self.fetchfromfile(filename: "timepoint.txt")
		
		if(storedtimepointasstring == "ERR 2") // File not initialized
		{
			self.timepointinstancestring = "Not"
			self.dayofweekinstancestring = "set"
			self.timepointinstanceasdate = Date.distantPast
		}
		else
		{
			self.timepointinstancestring = storedtimepointasstring
			self.dayofweekinstancestring = self.fetchfromfile(filename: "dayofweek.txt")
			
			let loadedDate = self.fetchfromfile(filename: "date.txt")
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "y-MM-dd E HH:mm" // Must match DateFormatter.short.dateFormat property
			self.timepointinstanceasdate = dateFormatter.date(from: loadedDate) ?? Date()
		}
		
		// Copy from instance to static variables
		Model.timepointasstring = self.timepointinstancestring
		Model.dayofweek = self.dayofweekinstancestring
		Model.timepointasdate = self.timepointinstanceasdate
		
		Task.detached {
			await self.updateComplications()
		}
	}
	
	public func setTimepointasdate(newDate: Date)  -> Void
	{
		// Set static variables
		Model.timepointasdate = newDate
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		Model.timepointasstring = dateFormatter.string(from: newDate)
		
		dateFormatter.dateFormat = "E"
		Model.dayofweek = dateFormatter.string(from: newDate)
		
		// Set instance variables
		self.timepointinstancestring = Model.timepointasstring
		self.dayofweekinstancestring = Model.dayofweek
		self.timepointinstanceasdate = Model.timepointasdate
		
		// Store to files
		self.storetofile(filename: "timepoint.txt", value: Model.timepointasstring)
		self.storetofile(filename: "dayofweek.txt", value: Model.dayofweek)
		self.storetofile(filename: "date.txt", value: DateFormatter.short.string(from: newDate))

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
			let pathWithFilename = documentDirectory.appendingPathComponent(filename)
			do
			{
				try value.write(to: pathWithFilename, atomically: false, encoding: .utf8)
				print(filename + " is set to " + value)
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
				print("fetchfromfile " + filename + " got " + value)
			}
			catch
			{
				print("fetchfromfile got ERR 2")
			}
		}
		return value
	}
	
	// Asynchronously update any active complications
	private func updateComplications() async {
		// Update any complications on active watch faces.
		print("updateComplications")
		
		let server = CLKComplicationServer.sharedInstance()
		let complications = await server.getActiveComplications()
		
		for complication in complications {
			print("updateComplication " + complication.description)
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
			token = center.addObserver(
				forName: .CLKComplicationServerActiveComplicationsDidChange,
				object: nil,
				queue: mainQueue)
			{ _ in
				center.removeObserver(token!)
				continuation.resume(returning: self.activeComplications!)
			}
			
			// Then check to see if we have a valid active complications array.
			if activeComplications != nil {
				center.removeObserver(token!)
				continuation.resume(returning: self.activeComplications!)
				print("getActiveComplications was not nil")
			}
			else { print("getActiveComplications was nil") }
		}
	}
}
