//
//  InAppNotificationImage.swift
//  NotificationKit
//
//  Image sources for notification cards, plus a pluggable remote-image
//  loader so host apps can inject their own pipeline (e.g. Kingfisher)
//  without the kit depending on it.
//

import SwiftUI
import UIKit

/// Where a notification card image comes from.
public enum InAppNotificationImage {
    case none
    /// An SF Symbol, optionally tinted.
    case system(String, tint: Color? = nil)
    /// An image already in memory.
    case local(UIImage)
    /// A remote image, rendered through the injected `InAppNotificationImageLoader`.
    case remote(URL)

    public var isVisible: Bool {
        if case .none = self { return false }
        return true
    }
}

/// Clipping shape for a card image slot.
public enum InAppNotificationImageShape {
    case circle
    case rounded(CGFloat)
}

/// Pluggable renderer for `.remote` images. The default uses `AsyncImage`
/// (no dependencies). Host apps can inject their own via
/// `.inAppNotificationImageLoader(...)` to reuse an existing cache:
///
///     .inAppNotificationImageLoader(.init { url in
///         AnyView(KFImage(url).resizable())
///     })
///
/// The returned view is clipped and sized by the card, so loaders only need
/// to produce a resizable image view.
public struct InAppNotificationImageLoader {
    public let makeView: (URL) -> AnyView

    public init(_ makeView: @escaping (URL) -> AnyView) {
        self.makeView = makeView
    }

    public static let asyncImage = InAppNotificationImageLoader { url in
        AnyView(
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                default:
                    // Placeholder & failure both show a neutral fill; the
                    // slot's fallback symbol sits on top (see ImageView below).
                    Color.gray.opacity(0.2)
                }
            }
        )
    }
}

private struct InAppNotificationImageLoaderKey: EnvironmentKey {
    static let defaultValue = InAppNotificationImageLoader.asyncImage
}

public extension EnvironmentValues {
    var inAppNotificationImageLoader: InAppNotificationImageLoader {
        get { self[InAppNotificationImageLoaderKey.self] }
        set { self[InAppNotificationImageLoaderKey.self] = newValue }
    }
}

public extension View {
    /// Injects a custom remote-image renderer for all notification cards
    /// below this view.
    func inAppNotificationImageLoader(_ loader: InAppNotificationImageLoader) -> some View {
        environment(\.inAppNotificationImageLoader, loader)
    }
}

/// Draws a single image slot at a fixed size with shape clipping and a
/// symbol fallback for empty/failed remote loads.
struct InAppNotificationImageView: View {
    let image: InAppNotificationImage
    let size: CGFloat
    let shape: InAppNotificationImageShape
    /// Symbol shown behind remote images while loading/failed
    /// (e.g. "person.fill" for avatars, "photo.fill" for content art).
    let fallbackSymbol: String

    @Environment(\.inAppNotificationImageLoader) private var loader

    var body: some View {
        content
            .frame(width: size, height: size)
            .clipShape(clipShape)
    }

    @ViewBuilder private var content: some View {
        switch image {
        case .none:
            EmptyView()
        case .system(let name, let tint):
            Image(systemName: name)
                .resizable()
                .scaledToFit()
                .padding(size * 0.22)
                .foregroundStyle(tint ?? .primary)
                .background(Color.gray.opacity(0.15))
        case .local(let uiImage):
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        case .remote(let url):
            ZStack {
                Color.gray.opacity(0.15)
                Image(systemName: fallbackSymbol)
                    .foregroundStyle(.secondary)
                loader.makeView(url)
                    .scaledToFill()
            }
        }
    }

    private var clipShape: AnyShape {
        switch shape {
        case .circle:
            AnyShape(Circle())
        case .rounded(let radius):
            AnyShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
    }
}
