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
    var updateTimer: Timer!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        cpuItem = CPUItem()
        updateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        updateTimer.invalidate()
    }
    
    @objc func update(){
        cpuItem?.update()
    }
}

