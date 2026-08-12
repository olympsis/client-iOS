//
//  InAppNotificationPresenter.swift
//  NotificationKit
//
//  The engine: owns the queue, the visible notification, and the
//  auto-dismiss clock. Owns NO geometry or animation — the host
//  (InAppNotificationHost) reacts to `phase` changes and drives motion.
//

import SwiftUI
import UIKit

/// Lifecycle of the visible card. The host animates on transitions:
/// `.presenting` → slide in; `.leaving` → slide out, then the host calls
/// `completeDismissal()` to let the queue advance.
public enum InAppNotificationPhase: Equatable {
    case idle
    case presenting
    case leaving
}

@MainActor
@Observable
public final class InAppNotificationPresenter {
    /// App-wide default instance. Apps can also create their own (e.g. one
    /// per window scene, or a fresh one in tests).
    public static let shared = InAppNotificationPresenter()

    public private(set) var current: InAppNotification?
    public private(set) var phase: InAppNotificationPhase = .idle

    /// Max notifications waiting behind the visible one; the oldest pending
    /// is dropped beyond this. The visible card is never dropped.
    public var maxQueueDepth: Int = 3

    /// When a new notification arrives while one is on screen, the visible
    /// card's remaining time is clipped to this so the queue drains promptly.
    public var interruptGrace: TimeInterval = 1.0

    private var queue: [InAppNotification] = []
    private var dismissTask: Task<Void, Never>?
    /// When the running auto-dismiss timer will fire; nil while paused.
    private var deadline: Date?
    /// Remaining seconds stashed by `pauseAutoDismiss()`.
    private var pausedRemaining: TimeInterval?
    private var isPaused = false

    public init() {}

    // MARK: - Public API

    public func present(_ notification: InAppNotification) {
        // Coalesce: replace a pending duplicate in place instead of stacking.
        if let coalesceID = notification.coalesceID,
           let index = queue.firstIndex(where: { $0.coalesceID == coalesceID }) {
            queue[index] = notification
        } else {
            queue.append(notification)
            if queue.count > maxQueueDepth {
                queue.removeFirst()
            }
        }

        if current == nil {
            advance()
        } else if !isPaused, phase == .presenting,
                  let deadline, deadline.timeIntervalSinceNow > interruptGrace {
            // Something is waiting — hurry the visible card along.
            scheduleAutoDismiss(interruptGrace)
        }
    }

    /// Programmatically dismisses the visible card (queue continues).
    public func dismissCurrent() {
        guard current != nil, phase == .presenting else { return }
        beginDismissal()
    }

    /// Drops everything, including the visible card (e.g. on logout).
    public func dismissAll() {
        queue.removeAll()
        dismissCurrent()
    }

    // MARK: - Host contract
    // Called by InAppNotificationHost in response to gestures/animation.

    /// Tap policy lives here: run the action, then dismiss.
    func handleTap() {
        guard phase == .presenting else { return }
        current?.onTap?()
        beginDismissal()
    }

    /// Moves to `.leaving`; the host observes this and runs the exit
    /// animation, then calls `completeDismissal()`.
    func beginDismissal() {
        guard phase == .presenting else { return }
        cancelAutoDismiss()
        phase = .leaving
    }

    /// Called by the host after the exit animation finishes.
    func completeDismissal() {
        guard phase == .leaving else { return }
        let finished = current
        current = nil
        phase = .idle
        finished?.onDismiss?()

        guard !queue.isEmpty else { return }
        // A visible beat between consecutive cards.
        dismissTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else { return }
            self?.advance()
        }
    }

    /// The user grabbed the card — freeze the auto-dismiss clock.
    func pauseAutoDismiss() {
        guard phase == .presenting, !isPaused else { return }
        isPaused = true
        pausedRemaining = deadline.map { max($0.timeIntervalSinceNow, 0) }
        cancelAutoDismiss()
    }

    /// The user let go without dismissing — restart the clock, giving at
    /// least a short grace so the card doesn't vanish under their finger.
    func resumeAutoDismiss() {
        guard phase == .presenting, isPaused else { return }
        isPaused = false
        if let remaining = pausedRemaining {
            scheduleAutoDismiss(max(remaining, 1.2))
        }
        pausedRemaining = nil
    }

    // MARK: - Private

    private func advance() {
        guard !queue.isEmpty else { return }
        var next = queue.removeFirst()
        _ = next // (kept mutable in case future policy rewrites fields on show)
        current = next
        phase = .presenting
        isPaused = false

        var duration = next.duration
        // Give VoiceOver users time to hear the announcement.
        if UIAccessibility.isVoiceOverRunning {
            duration *= 2.5
        }
        scheduleAutoDismiss(duration)
    }

    private func scheduleAutoDismiss(_ seconds: TimeInterval) {
        cancelAutoDismiss()
        deadline = Date(timeIntervalSinceNow: seconds)
        dismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled else { return }
            self?.beginDismissal()
        }
    }

    private func cancelAutoDismiss() {
        dismissTask?.cancel()
        dismissTask = nil
        deadline = nil
    }
}
