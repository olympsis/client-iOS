//
//  CircularButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/2/26.
//

import SwiftUI

/// A circular, icon-only button that adapts its material to the OS version and can
/// reflect the progress of an async action through loading / success / failure states.
///
/// Material behaviour:
/// - On **iOS 26+** it uses the system **Liquid Glass** effect (`glassEffect`).
/// - On **iOS 17 and earlier** it falls back to a **frosted glass** look built from
///   `.ultraThinMaterial`.
///
/// Note: `glassEffect(_:in:)` is only available starting in iOS 26, so the availability
/// check gates on iOS 26 (the version that actually exposes the API) rather than iOS 18.
///
/// Pass a `tint` to render a prominent, filled variant (like the blue "+" button in the
/// New Event header); leave it `nil` for a clear/frosted variant (like the "X" close button).
struct CircularButton: View {

    /// The visual + interaction state that drives which glyph the button shows.
    enum ButtonState: Equatable {
        /// Default state: shows the passed-in `systemImage`.
        case idle
        /// In-flight: shows a spinner and ignores taps.
        case loading
        /// Operation succeeded: shows a checkmark.
        case success
        /// Operation failed: shows an exclamation mark.
        case failure
    }

    /// SF Symbol shown while the button is idle.
    let systemImage: String

    /// Optional tint. When provided the button renders as a filled/prominent glass button;
    /// when `nil` it renders as a clear (frosted/liquid) glass button.
    var tint: Color? = nil

    /// Diameter of the button in points.
    var size: CGFloat = 60

    /// Current state. Drive this from the parent's `@State` while an async task runs.
    var state: ButtonState = .idle

    /// Action performed on tap. Ignored while the button is in the `.loading` state.
    var action: () -> Void

    var body: some View {
        Button {
            // Guard against re-triggering the action while an operation is already in flight.
            guard state != .loading else { return }
            action()
        } label: {
            iconContent
                // Scale the symbol relative to the button so it looks right at any `size`.
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(foregroundColor)
                .frame(width: size, height: size)
                .modifier(CircularGlassBackground(tint: tint))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(state == .loading)
        // Animate the crossfade/scale between the different state glyphs.
        .animation(.easeInOut(duration: 0.2), value: state)
    }

    /// Chooses which glyph (or spinner) to display for the current state.
    @ViewBuilder
    private var iconContent: some View {
        switch state {
        case .idle:
            Image(systemName: systemImage)
                .transition(.scale.combined(with: .opacity))
        case .loading:
            ProgressView()
                .tint(foregroundColor)
                .transition(.opacity)
        case .success:
            Image(systemName: "checkmark")
                .transition(.scale.combined(with: .opacity))
        case .failure:
            Image(systemName: "exclamationmark")
                .transition(.scale.combined(with: .opacity))
        }
    }

    /// Symbol/spinner color. Prominent (tinted) buttons use white for contrast against the
    /// fill; clear buttons use a state-appropriate color so success/failure read clearly.
    private var foregroundColor: Color {
        if tint != nil {
            return .white
        }
        switch state {
        case .success: return .green
        case .failure: return .red
        default:       return .primary
        }
    }
}

/// Applies the version-appropriate circular background:
/// Liquid Glass on iOS 26+, frosted glass (`.ultraThinMaterial`) below.
private struct CircularGlassBackground: ViewModifier {

    let tint: Color?

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            liquidGlass(content)
        } else {
            frostedGlass(content)
        }
    }

    @available(iOS 26.0, *)
    @ViewBuilder
    private func liquidGlass(_ content: Content) -> some View {
        if let tint {
            content.glassEffect(.regular.tint(tint).interactive(), in: Circle())
        } else {
            content.glassEffect(.regular.interactive(), in: Circle())
        }
    }

    @ViewBuilder
    private func frostedGlass(_ content: Content) -> some View {
        content.background {
            Group {
                if let tint {
                    Circle().fill(tint)
                } else {
                    Circle().fill(.ultraThinMaterial)
                }
            }
            .overlay {
                Circle().strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
        }
    }
}

#Preview {
    // Interactive preview that cycles a button through its states on tap so you can
    // see the loading -> success/failure transitions.
    struct PreviewHost: View {
        @State private var state: CircularButton.ButtonState = .idle

        var body: some View {
            VStack(spacing: 40) {
                CircularButton(systemImage: "plus", tint: Color("color-prime"), state: state) {
                    runDemo()
                }

                // Clear/frosted "X" close button.
                CircularButton(systemImage: "xmark") {}

                // Static previews of each state for quick visual reference.
                HStack(spacing: 20) {
                    CircularButton(systemImage: "checkmark", size: 44, state: .loading) {}
                    CircularButton(systemImage: "checkmark", size: 44, state: .success) {}
                    CircularButton(systemImage: "checkmark", size: 44, state: .failure) {}
                }
            }
            .padding(40)
            .background(Color("color-prime").opacity(0.15))
        }

        /// Simulates an async task: loading -> success, then reset.
        private func runDemo() {
            state = .loading
            Task {
                try? await Task.sleep(for: .seconds(1.2))
                state = .success
                try? await Task.sleep(for: .seconds(1))
                state = .idle
            }
        }
    }

    return PreviewHost()
}
