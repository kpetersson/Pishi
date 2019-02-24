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
    
    var cpuInfo: processor_info_array_t!
    var prevCpuInfo: processor_info_array_t?
    var numCpuInfo: mach_msg_type_number_t = 0
    var numPrevCpuInfo: mach_msg_type_number_t = 0
    var numCPUs: uint = 0
    var updateTimer: Timer!
    let CPUUsageLock: NSLock = NSLock()
    
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        if let button = statusItem.button {
            button.title = "0.0%"
        }
        setupMenu()
        start()
    }

    func setupMenu(){
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: "Q"))
        statusItem?.menu = menu
    }
    
    func start(){
        let mibKeys: [Int32] = [ CTL_HW, HW_NCPU ]
        // sysctl Swift usage credit Matt Gallagher: https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlSysctl.swift
        mibKeys.withUnsafeBufferPointer() { mib in
            var sizeOfNumCPUs: size_t = MemoryLayout<uint>.size
            let status = sysctl(processor_info_array_t(mutating: mib.baseAddress), 2, &numCPUs, &sizeOfNumCPUs, nil, 0)
            if status != 0 {
                numCPUs = 1
            }
            updateTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateInfo(_ timer: Timer) {
        var numCPUsU: natural_t = 0
        let err: kern_return_t = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
        if err == KERN_SUCCESS {
            CPUUsageLock.lock()
            var total: Float = 0.0
            for i in 0 ..< Int32(numCPUs) {
                var inUse: Int32
                var totalPerCore: Int32
                if let prevCpuInfo = prevCpuInfo {
                    inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                    totalPerCore = inUse + (cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                        - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)])
                } else {
                    inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                    totalPerCore = inUse + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                }
                let usage: Float = Float(inUse) / Float(totalPerCore)
                print(String(format: "Core: %u Usage: %f", i, usage))
                total += usage
            }
            total = total / Float(numCPUs)
            print("Total Usage: \(total)")
            print("Idle: \(1.0-total)")
            print("---------------------")
            
            if let button = self.statusItem?.button {
                button.title = String(format: "%.1f", total*100)+"%"
            }

            CPUUsageLock.unlock()
            if let prevCpuInfo = prevCpuInfo {
                // vm_deallocate Swift usage credit rsfinn: https://stackoverflow.com/a/48630296/1033581
                let prevCpuInfoSize: size_t = MemoryLayout<integer_t>.stride * Int(numPrevCpuInfo)
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCpuInfo), vm_size_t(prevCpuInfoSize))
            }
            prevCpuInfo = cpuInfo
            numPrevCpuInfo = numCpuInfo
            cpuInfo = nil
            numCpuInfo = 0
        } else {
            print("Error!")
        }
    }

}
