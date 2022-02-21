//
//  Do_14_10App.swift
//  Do-14-10 WatchKit Extension
//
//  Created by bjorn on 2022-01-31.
//	https://stackoverflow.com/questions/64507461/how-do-i-access-my-model-or-other-state-in-the-app-struct-from-a-complicationc
//	https://developer.apple.com/videos/play/wwdc2020/10049/

import SwiftUI

@main
struct Do_14_10App: App {
	var body: some Scene {
		WindowGroup {
			NavigationView {
				ContentView(model: Model())
			}
		}
	}
}
