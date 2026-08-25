//
//  RoomViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/20/24.
//

import os
import SwiftUI
import Foundation

@Observable
class RoomViewModel {
    var text = ""
    var messages: [Message] = []
    var state: VIEW_STATE = .pending
    var connectionState: CONNECTION_STATE = .disconnected
    
    let room: Room
    let observer: ChatService

    private var isConnected = false

    private let log = Logger(subsystem: "com.olympsis.client", category: "room_view_model")

    init(room: Room, observer: ChatService) {
        self.room = room
        self.observer = observer
    }
    
    @MainActor
    func loadInitialData() async {
        guard let id = room.id else { return }
        
        state = .loading
        if let response = await observer.GetRoom(id: id) {
            messages = response.history ?? []
            state = .success
        } else {
            state = .failure
        }
    }
    
    func startWebSocketConnection() async {
        guard let id = room.id else { return }
        
        await observer.initiateSocketConnection(id: id)
        isConnected = true
        
        // Start message receiving loop
        while isConnected {
            if let message = await observer.receiveMessage() {
                await MainActor.run {
                    messages.append(message)
                }
            } else {
                log.error("Failed to get message.")
                await observer.initiateSocketConnection(id: id)
            }
        }
    }
    
    @MainActor
    func startMessageReceiving() async {
        guard isConnected else { return }
        connectionState = .connected
        
        do {
            while isConnected {
                if let message = await observer.receiveMessage() {
                    messages.append(message)
                } else {
                    connectionState = .reconnecting
                    log.error("Failed to receive message, attempting reconnection...")
                    try await reconnect()
                }
            }
        } catch {
            log.error("Message receiving loop failed: \(error.localizedDescription)")
            connectionState = .disconnected
        }
    }
    
    func sendMessage(userID: String?) async -> Bool {
        guard !text.isEmpty, let userID = userID else { return false }
        
        let message = Message(type: "text", sender: userID, body: text)
        let success = await observer.sendMessage(msg: message)
        
        if success {
            await MainActor.run {
                text = ""
            }
        } else {
            log.error("Failed to send message")
        }
        
        return success
    }
    
    private func reconnect() async throws {
        guard let id = room.id else { return }
        
        connectionState = .reconnecting
        await observer.closeSocketConnection()
        
        // Add exponential backoff
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await observer.initiateSocketConnection(id: id)
        connectionState = .connected
    }
    
    func disconnect() async {
        isConnected = false
        await observer.closeSocketConnection()
    }
}
