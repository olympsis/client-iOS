//
//  RSVPOptions.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/27/26.
//

import SwiftUI


/// A single RSVP choice rendered as a bold, tappable bar.
///
/// The bar animates through the async lifecycle of committing an RSVP —
/// `pending → loading → success / failure` — and, once it represents the
/// user's active RSVP (`isSelected`), reveals a red cancel bar that slides in
/// from the trailing edge so the user can retract their response.
///
/// The view is purely presentational: it renders whatever `loadingState` /
/// `isSelected` it is given and reports intent through `onClick` / `onCancel`.
/// Driving the state machine (loading → success, auto‑reverting after a beat,
/// etc.) is the parent's job — see the `RSVPOptions` preview harness below for
/// a reference implementation.
struct RSVPOption: View {

    var option: EVENT_RSVP_STATUS
    @Binding var isSelected: Bool
    @Binding var loadingState: LOADING_STATE

    var onClick: (() -> Void)
    var onCancel: (() -> Void)

    /// The bar shrinks slightly once selected so the cancel bar has a little
    /// room to breathe.
    private var size: CGFloat {
        isSelected ? 75 : 80
    }

    private var color: Color {
        switch option {
        case .Yes:
            return Color.Brand.primary
        case .Maybe:
            return Color.Brand.secondary
        case .Waitlist:
            return Color.Brand.tertiary
        case .Cant:
            return .gray
        }
    }

    /// Localization key for this option's label. Kept as a `LocalizedStringKey`
    /// so SwiftUI resolves it against the Events catalog at display time. Every
    /// key here must exist in `Events.xcstrings`.
    private var labelKey: LocalizedStringKey {
        switch option {
        case .Yes:
            return "rsvp-yes"
        case .Maybe:
            return "rsvp-maybe"
        case .Waitlist:
            return "rsvp-waitlist"
        case .Cant:
            return "rsvp-cant"
        }
    }

    private var optionText: some View {
        Text(labelKey, tableName: "Events")
            .textCase(.uppercase)
            .foregroundStyle(.white)
            .font(.custom("Archivo-BlackItalic", size: 30, relativeTo: .largeTitle))
            .lineLimit(1)
            .minimumScaleFactor(0.6) // keep longer translations on a single line
    }

    /// The content shown inside the primary bar for the current loading state.
    /// Each branch is tagged with `.id(loadingState)` at the call site so
    /// SwiftUI treats a state change as a view swap and runs the transition
    /// (scale + fade) rather than snapping instantly.
    @ViewBuilder
    private var stateContent: some View {
        switch loadingState {
        case .loading:
            ProgressView()
                .tint(.white)
        case .pending:
            optionText
        case .success:
            Image(systemName: "checkmark")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .symbolEffect(.bounce, value: loadingState) // little pop on success
        case .failure:
            Image(systemName: "exclamationmark.triangle.fill")
                .imageScale(.large)
                .foregroundStyle(.yellow)
                .symbolEffect(.bounce, value: loadingState) // little pop on failure
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Rectangle()
                .foregroundStyle(color)
                .overlay {
                    stateContent
                        .transition(.scale(scale: 0.7).combined(with: .opacity))
                        .id(loadingState)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Only accept a tap while the bar is idle and not already the
                    // user's active RSVP — ignore taps mid-request or post-commit.
                    guard loadingState == .pending, !isSelected else { return }
                    onClick()
                }
                .accessibilityLabel(Text(labelKey, tableName: "Events"))
                .accessibilityAddTraits(.isButton)

            if isSelected {
                Rectangle()
                    .foregroundStyle(.red)
                    .overlay {
                        Image(systemName: "xmark")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: size)
                    .contentShape(Rectangle())
                    .onTapGesture { onCancel() }
                    .accessibilityLabel(Text("rsvp-cancel", tableName: "Events"))
                    .accessibilityAddTraits(.isButton)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .frame(maxHeight: size)
        .animation(.spring(response: 0.25, dampingFraction: 0.72), value: loadingState)
        .animation(.spring(response: 0.25, dampingFraction: 0.72), value: isSelected)
    }
}



/// A vertical stack of `RSVPOption` bars — the reusable RSVP control intended
/// to drop into `RSVPSheet` (or anywhere an event RSVP is offered).
///
/// This view is presentational and driven entirely by its inputs:
/// - `options`      — which choices to show, in order.
/// - `selected`     — the user's active RSVP; that bar reveals the cancel affordance.
/// - `loadingStates`— per-option loading state; keys without an entry default to `.pending`.
/// - `onSelect`     — a bar was tapped to RSVP.
/// - `onCancel`     — the cancel bar was tapped to retract the active RSVP.
///
/// The parent owns the async work (calling the observer, flipping loading →
/// success/failure, updating `selected`). See the `#Preview` for a fake-async
/// reference implementation of that state machine.
struct RSVPOptions: View {

    var options: [EVENT_RSVP_STATUS] = [.Yes, .Maybe, .Cant]
    var selected: EVENT_RSVP_STATUS?
    @Binding var loadingStates: [EVENT_RSVP_STATUS: LOADING_STATE]

    var onSelect: (EVENT_RSVP_STATUS) -> Void
    var onCancel: (EVENT_RSVP_STATUS) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                RSVPOption(
                    option: option,
                    // `isSelected` is derived from `selected`; the bar only reads it.
                    isSelected: .constant(selected == option),
                    loadingState: Binding(
                        get: { loadingStates[option] ?? .pending },
                        set: { loadingStates[option] = $0 }
                    ),
                    onClick: { onSelect(option) },
                    onCancel: { onCancel(option) }
                )
            }
        }
    }
}


#if DEBUG
/// Interactive harness that fakes the async RSVP round-trip so the full
/// experience — loading → success (or failure) → selected-with-cancel → back
/// to idle — can be tapped through in previews / the simulator without a
/// backend. Flip "Simulate failure" to preview the error path. Preview-only.
private struct RSVPOptionsPreviewHarness: View {

    /// The option that is currently the user's active RSVP (nil == none).
    @State private var selected: EVENT_RSVP_STATUS?
    /// Per-option loading state, defaulting to `.pending`.
    @State private var states: [EVENT_RSVP_STATUS: LOADING_STATE] = [:]
    /// When on, `commit(_:)` routes through the failure branch instead.
    @State private var simulateFailure = false

    var body: some View {
        VStack(spacing: 0) {
            RSVPOptions(
                options: [.Yes, .Maybe],
                selected: selected,
                loadingStates: $states,
                onSelect: commit,
                onCancel: cancel
            )

            Toggle(isOn: $simulateFailure) {
                Text(verbatim: "Simulate failure")
            }.padding([.top, .horizontal])
        }
    }

    /// Fakes committing an RSVP: spin, then either land on success (and become
    /// the selected option) or bounce to failure and reset back to idle.
    private func commit(_ option: EVENT_RSVP_STATUS) {
        states[option] = .loading
        Task {
            try? await Task.sleep(for: .seconds(1))
            if simulateFailure {
                states[option] = .failure
                try? await Task.sleep(for: .seconds(1.2))
                states[option] = .pending
            } else {
                states[option] = .success
                try? await Task.sleep(for: .seconds(0.8))
                selected = option          // reveals the cancel bar
                states[option] = .pending  // show the label again beneath it
            }
        }
    }

    /// Fakes retracting an RSVP: spin briefly, then clear the selection.
    private func cancel(_ option: EVENT_RSVP_STATUS) {
        states[option] = .loading
        Task {
            try? await Task.sleep(for: .seconds(0.8))
            selected = nil
            states[option] = .pending
        }
    }
}

#Preview {
    RSVPOptionsPreviewHarness()
}
#endif
