//
//  InAppNotificationCard.swift
//  NotificationKit
//
//  The visual card: layout only. No gestures, no timers, no offsets —
//  those live in InAppNotificationHost so this view stays fully
//  previewable in isolation.
//

import SwiftUI

public struct InAppNotificationCard: View {
    public let notification: InAppNotification

    @Environment(\.inAppNotificationStyle) private var style

    public init(notification: InAppNotification) {
        self.notification = notification
    }

    public var body: some View {
        HStack(alignment: .center, spacing: style.contentSpacing) {
            if notification.leadingImage.isVisible {
                InAppNotificationImageView(
                    image: notification.leadingImage,
                    size: style.imageSize,
                    shape: style.leadingImageShape,
                    fallbackSymbol: "person.fill"
                )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title.resolvingFonts(
                    base: style.titleFont,
                    emphasis: style.titleEmphasisFont
                ))
                .foregroundStyle(style.titleColor)
                .lineLimit(style.titleLineLimit)

                if let subtitle = notification.subtitle {
                    Text(subtitle.resolvingFonts(
                        base: style.subtitleFont,
                        emphasis: style.subtitleEmphasisFont
                    ))
                    .foregroundStyle(style.subtitleColor)
                    .lineLimit(style.subtitleLineLimit)
                }
            }

            Spacer(minLength: 0)

            if notification.trailingImage.isVisible {
                InAppNotificationImageView(
                    image: notification.trailingImage,
                    size: style.imageSize,
                    shape: style.trailingImageShape,
                    fallbackSymbol: "photo.fill"
                )
            }
        }
        .padding(style.contentPadding)
        .frame(maxWidth: .infinity, minHeight: style.minHeight, alignment: .leading)
        .background(style.background, in: cardShape)
        .overlay {
            cardShape.strokeBorder(style.borderColor, lineWidth: style.borderWidth)
        }
        .shadow(
            color: style.shadowColor,
            radius: style.shadowRadius,
            x: 0,
            y: style.shadowYOffset
        )
        // Whole rounded rect (including padding) is tappable and draggable.
        .contentShape(cardShape)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
    }
}
