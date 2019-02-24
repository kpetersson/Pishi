//
//  AppDelegate.swift
//  Pishi
//
//  Created by Karl Petersson on 2019-02-24.
//  Copyright © 2019 Karl Petersson. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    var cpuItem: CPUItem?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        cpuItem = CPUItem(statusItem: statusItem)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

