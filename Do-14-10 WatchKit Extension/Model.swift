//
//  Model.swift
//  Do-14-10 WatchKit Extension
//
//  Created by bjorn on 2022-02-01.
//

import SwiftUI
import ClockKit

@MainActor
class Model: ObservableObject {
	static let shared = Model()
	
	static var timepointasstring: String = "xx:yy" // Used in ComplicationController to auto-update complication
	static var timepointasdate: Date = Date() //  -""-
	static var counter = 1
	static var dayofweek: String = "ddd"
	@Published var timepointinstancestring: String = "xx:yy"  // Used to auto-update ContentView
		
	public func setTimepointasdate(new: Date)  -> Void
	{
		let dateFormatter = DateFormatter()

		Model.timepointasdate = new		
		dateFormatter.dateFormat = "HH:mm"
		Model.timepointasstring = dateFormatter.string(from: new)
		self.timepointinstancestring = Model.timepointasstring
		dateFormatter.dateFormat = "EEE"
		Model.dayofweek = dateFormatter.string(from: new)

		Model.counter += 1
		
		Task.detached {
				await self.updateComplications()
		}
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
