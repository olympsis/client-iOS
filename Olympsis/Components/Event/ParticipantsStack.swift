//
//  ParticipantsStack.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/11/26.
//

import SwiftUI
import Kingfisher

/// A compact, horizontally-overlapping stack of participant avatars.
///
/// Renders up to `maxVisible` circular avatars; any participants beyond
/// that collapse into a single "+n" overflow badge. Unlike `TransitStack`
/// — where the "+n" badge is tucked *behind* the overlapping line badges —
/// here the overflow badge is pushed to the trailing edge and sits clear of
/// the avatars (no overlap), so the count reads cleanly. Used to surface
/// who's attending an event at a glance without spending a row per person.
struct ParticipantsStack: View {

    let participants: [Participant]

    /// When true, anonymous participants still show their real avatar.
    /// Mirrors `ParticipantView.posterOrAdminViewing` — posters/admins are
    /// allowed to see who's actually behind an anonymous RSVP.
    var revealAnonymous: Bool = false

    /// Whether the viewer is allowed to see the real participants. When
    /// false — e.g. the event hides participants until the viewer RSVPs
    /// (see `EventParticipants.canShowParticipants`) — the stack shows a
    /// fixed run of `hiddenPlaceholderCount` generic avatars instead, so the
    /// row still reads as "people are going" without revealing who.
    var canShowParticipants: Bool = true

    /// Number of generic placeholder avatars shown when participants are
    /// hidden. Defaults to 3.
    var hiddenPlaceholderCount: Int = 3

    /// Maximum number of avatars drawn before the remainder collapses into
    /// the "+n" overflow badge.
    var maxVisible: Int = 4

    /// Diameter of each circular avatar (and the overflow badge).
    var diameter: CGFloat = 30

    /// How far each avatar slides under its left-hand neighbor. Larger
    /// values tighten the stack.
    var overlap: CGFloat = 12

    /// Gap between the last avatar and the "+n" badge. Fixed rather than a
    /// `Spacer`, so the stack hugs its content instead of stretching to fill
    /// its container (both call sites place it in a full-width `.overlay`).
    var badgeSpacing: CGFloat = 4

    /// The participants actually drawn as avatars.
    private var visible: [Participant] {
        Array(participants.prefix(maxVisible))
    }

    /// Number of participants hidden behind the overflow badge (0 when all fit).
    private var overflow: Int {
        max(0, participants.count - maxVisible)
    }

    var body: some View {
        // Outer HStack: the overlapping avatar stack, then the "+n" badge
        // separated by a fixed `badgeSpacing`. The fixed gap is what keeps
        // the badge clear of the avatars (it never tucks under them) while
        // letting the whole row size to its content.
        HStack(spacing: badgeSpacing) {
            // Negative spacing pulls each avatar under the previous one. We
            // reverse the z-order so the leading avatar sits on top — the
            // conventional "stacked" look.
            HStack(spacing: -overlap) {
                if canShowParticipants {
                    ForEach(Array(visible.enumerated()), id: \.element.id) { index, participant in
                        avatar(for: participant)
                            .zIndex(Double(visible.count - index))
                    }
                } else {
                    // Participants are hidden until the viewer RSVPs — show a
                    // fixed run of generic placeholder avatars instead of the
                    // real ones.
                    ForEach(0..<hiddenPlaceholderCount, id: \.self) { index in
                        placeholderAvatar
                            .zIndex(Double(hiddenPlaceholderCount - index))
                    }
                }
            }

            // Only the real, visible stack gets a trailing overflow count —
            // when participants are hidden there's nothing to count up to.
            if canShowParticipants && overflow > 0 {
                overflowBadge
            }
        }
    }

    /// One circular avatar with a background-colored ring so overlapping
    /// neighbors stay visually separated.
    private func avatar(for participant: Participant) -> some View {
        KFImage(imageURL(for: participant))
            .placeholder { placeholder }
            .cacheOriginalImage()
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 200, height: 200)))
            .resizable()
            .scaledToFill()
            .frame(width: diameter, height: diameter)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color(.systemBackground), lineWidth: 2)
            )
    }

    /// Fallback shown while loading, on failure, or for anonymous/imageless
    /// participants: a neutral circle with a person glyph.
    private var placeholder: some View {
        Circle()
            .fill(Color(.systemGray3))
            .overlay(
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: diameter * 0.5, height: diameter * 0.5)
                    .foregroundStyle(.white)
            )
            .frame(width: diameter, height: diameter)
    }

    /// `placeholder` plus the background-colored separation ring. Used for
    /// the hidden-participants state where there's no `KFImage` (whose
    /// `avatar(for:)` wrapper would otherwise supply the ring).
    private var placeholderAvatar: some View {
        placeholder
            .overlay(
                Circle().stroke(Color(.systemBackground), lineWidth: 2)
            )
    }

    /// The trailing "+n" count badge. Same size as an avatar but rendered as
    /// a flat gray circle so it reads as a counter rather than a person.
    private var overflowBadge: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray3))
                .overlay(
                    Circle().stroke(Color(.systemBackground), lineWidth: 2)
                )

            Text("+\(overflow)")
                .font(.system(size: diameter * 0.42, weight: .bold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal, 2)
        }
        .frame(width: diameter, height: diameter)
    }

    /// Resolve a participant's avatar URL, respecting anonymity. Returns nil
    /// (so the placeholder shows) for anonymous participants — unless the
    /// viewer is allowed to reveal them — or when no image is set.
    private func imageURL(for participant: Participant) -> URL? {
        let isAnonymous = revealAnonymous ? false : participant.isAnonymous
        guard !isAnonymous,
              let img = participant.user?.imageURL else {
            return nil
        }
        return generateImageURL(img)
    }
}

#Preview("Overflow") {
    ParticipantsStack(participants: EVENTS[0].participants, maxVisible: 1)
        .padding()
}

#Preview("Fits") {
    ParticipantsStack(participants: Array(EVENTS[0].participants.prefix(2)))
        .padding()
}

#Preview("Hidden") {
    ParticipantsStack(participants: EVENTS[0].participants, canShowParticipants: false)
        .padding()
}
