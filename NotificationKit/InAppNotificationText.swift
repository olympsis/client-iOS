//
//  InAppNotificationText.swift
//  NotificationKit
//
//  Rich-text policy: how a plain string becomes styled AttributedString.
//

import SwiftUI

public extension AttributedString {
    /// Parses inline Markdown (`**bold**`, `*italic*`, `` `code` ``) into an
    /// AttributedString, preserving whitespace and newlines.
    ///
    /// Never throws: a malformed Markdown string (e.g. a stray `[` coming from
    /// a server payload) silently degrades to plain text instead of crashing.
    static func inAppMarkdown(_ string: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return (try? AttributedString(markdown: string, options: options))
            ?? AttributedString(string)
    }
}

extension AttributedString {
    /// Applies concrete fonts to the string's runs.
    ///
    /// SwiftUI's `Text(AttributedString)` renders `**bold**` runs by adding a
    /// bold *trait* to the environment font. That works for system fonts, but
    /// with a custom font family (e.g. Archivo) it produces a synthesized
    /// (faux) bold. Passing an explicit `emphasis` font here rewrites those
    /// runs with the family's real bold face instead.
    ///
    /// - Parameters:
    ///   - base: font applied to all non-emphasized runs.
    ///   - emphasis: font for `**strongly emphasized**` runs. Pass `nil` to
    ///     leave emphasis to SwiftUI's default trait handling (fine for
    ///     system fonts — this becomes a cheap single-run pass).
    func resolvingFonts(base: Font, emphasis: Font?) -> AttributedString {
        var result = self
        guard let emphasis else {
            result.font = base
            return result
        }
        for run in result.runs {
            let isStrong = run.inlinePresentationIntent?.contains(.stronglyEmphasized) ?? false
            result[run.range].font = isStrong ? emphasis : base
        }
        return result
    }
}
