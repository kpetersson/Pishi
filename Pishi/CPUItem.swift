//
//  CPUItem.swift
//  Pishi
//
//  Created by Karl Petersson on 2019-02-24.
//  Copyright © 2019 Karl Petersson. All rights reserved.
//

import Foundation
import Cocoa

class CPUItem {
    let statusItem:NSStatusItem?
    var system: System?
    var updateTimer: Timer!
    
    init() {
        let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)

        self.system = System()
        self.statusItem = statusItem
        if let button = statusItem.button {
            button.title = "0.0%"
        }
        setupMenu()
    }
    
    func setupMenu(){
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: "Q"))
        statusItem?.menu = menu
    }
    
    func update(){
        let cpu = system?.usageCPU()
        if let cpu = cpu {
            print(cpu)
            let total = cpu.system + cpu.user + cpu.nice
            if let button = self.statusItem?.button {
                button.title = String(format: "%.1f", total)+"%"
            }
        }
    }
}
