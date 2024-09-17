//
//  NetworkMonitor.swift
//  Project_DH
//
//  Created by Yongxiang Jin on 9/17/24.
//

import Foundation
import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    
    init() {
        self.monitor = NWPathMonitor()
        self.monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        self.monitor.start(queue: self.queue)
    }
}
