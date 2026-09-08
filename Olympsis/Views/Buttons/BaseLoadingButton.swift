//
//  BaseLoadingButton.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/23/26.
//

import SwiftUI

/// A full-width, pill shaped button that reflects the progress of the async work
/// it kicks off: it shows its title while `.pending`, a spinner while `.loading`,
/// a checkmark on `.success` and an xmark on `.failure`.
///
/// It was extracted from the paired Decline / RSVP buttons in
/// `NotificationEventInvite` — both were hand rolled `RoundedRectangle` stacks
/// that differed only in fill and text color — so the two are now the same view
/// with different `background` / `foreground` values.
///
/// The button always stretches to fill the width its parent gives it (that's what
/// keeps two of them splitting an `HStack` evenly) and pins to a fixed `height`,
/// so the layout does not jump when the label swaps for a spinner or a glyph.
struct BaseLoadingButton: View {

    /// The label shown in the `.pending` state. Callers pass a `Text` rather than
    /// a `String` so already-localized / styled text can be handed straight in
    /// (e.g. `NotificationEventInvite`'s `primaryActionText`).
    let title: Text

    /// Fill of the pill in every state except `.success` / `.failure`, which use
    /// green and red so the outcome reads at a glance.
    var background: Color = Color.Brand.primary

    /// Tint of the title and the spinner.
    var foreground: Color = .white

    var cornerRadius: CGFloat = 20

    var height: CGFloat = 40

    /// Driven by the caller's async work. Bound rather than owned so the parent
    /// can reset several buttons at once (e.g. after the note is dismissed).
    @Binding var state: LOADING_STATE

    var action: () -> Void

    /// The outcome states override the caller's palette — a red pill with a white
    /// xmark is legible regardless of what `background` was.
    private var fill: Color {
        switch state {
        case .success: return .green
        case .failure: return .red
        default:       return background
        }
    }

    private var contentColor: Color {
        switch state {
        case .success, .failure: return .white
        default:                 return foreground
        }
    }

    @ViewBuilder
    private var label: some View {
        switch state {
        case .pending:
            title
                .foregroundStyle(contentColor)
        case .loading:
            ProgressView()
                .tint(contentColor)
        case .success:
            Image(systemName: "checkmark")
                .imageScale(.large)
                .fontWeight(.bold)
                .foregroundStyle(contentColor)
        case .failure:
            Image(systemName: "xmark")
                .imageScale(.large)
                .fontWeight(.bold)
                .foregroundStyle(contentColor)
        }
    }

    private var content: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundStyle(fill)
            .overlay { label }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.border, lineWidth: 1)
            }
            // Expand across the parent's width, but keep the height fixed so the
            // row doesn't resize as the label changes.
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .animation(.snappy, value: state)
    }

    var body: some View {
        Button(action: action) { content }
            .buttonStyle(.plain)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            // Blocked while in flight and once it has succeeded; `.failure` stays
            // tappable so the request can be retried.
            .disabled(state == .loading || state == .success)
    }
}

#Preview("Pending") {
    HStack {
        BaseLoadingButton(
            title: Text("Decline"),
            background: Color.Background.secondary,
            foreground: Color.Foreground.default,
            state: .constant(.pending)
        ) {}

        BaseLoadingButton(title: Text("RSVP"), state: .constant(.pending)) {}
    }
    .padding()
}

#Preview("Loading") {
    BaseLoadingButton(title: Text("RSVP"), state: .constant(.loading)) {}
        .padding()
}

#Preview("Success") {
    BaseLoadingButton(title: Text("RSVP"), state: .constant(.success)) {}
        .padding()
}

#Preview("Failure") {
    BaseLoadingButton(title: Text("RSVP"), state: .constant(.failure)) {}
        .padding()
}
