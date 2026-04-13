//
//  HTMLTextView.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/12/26.
//

import UIKit
import SwiftUI
import Foundation


struct HTMLTextView: UIViewRepresentable {
    let html: String
    var fontSize: CGFloat = 16
    @Binding var collapsedHeight: CGFloat
    @Binding var fullHeight: CGFloat
    @Binding var isTruncated: Bool
    var maxLines: Int = 5

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.isEditable = false
        tv.textColor = .label 
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tv
    }

    func updateUIView(_ tv: UITextView, context: Context) {
        let isHTML = html.contains("<")

        let finalAttr: NSAttributedString
        if isHTML {
            guard let data = html.data(using: .utf8),
                  let attr = try? NSAttributedString(
                      data: data,
                      options: [
                          .documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue
                      ],
                      documentAttributes: nil
                  )
            else { return }
            finalAttr = attr
        } else {
            finalAttr = NSAttributedString(string: html)
        }

        let mutable = NSMutableAttributedString(attributedString: finalAttr)
        mutable.addAttribute(.font,
                             value: UIFont.systemFont(ofSize: fontSize),
                             range: NSRange(location: 0, length: mutable.length))
        mutable.addAttribute(.foregroundColor,
                             value: UIColor.label,
                             range: NSRange(location: 0, length: mutable.length))
        tv.attributedText = mutable

        // Always show full text — SwiftUI frame handles clipping
        tv.textContainer.maximumNumberOfLines = 0
        tv.textContainer.lineBreakMode = .byWordWrapping

        DispatchQueue.main.async {
            let width = tv.bounds.width
            guard width > 0 else { return }
            let size = CGSize(width: width, height: .infinity)

            // Full height
            let full = tv.sizeThatFits(size).height

            // Collapsed height
            tv.textContainer.maximumNumberOfLines = maxLines
            tv.sizeToFit()
            let collapsed = tv.sizeThatFits(size).height

            // Restore
            tv.textContainer.maximumNumberOfLines = 0

            if fullHeight != full { fullHeight = full }
            if collapsedHeight != collapsed { collapsedHeight = collapsed }
            isTruncated = full > collapsed + 1
        }
    }
}

struct ExpandableHTMLText: View {
    let html: String
    var fontSize: CGFloat = 16
    var maxLines: Int = 5

    @State private var isExpanded = false
    @State private var collapsedHeight: CGFloat = 0
    @State private var fullHeight: CGFloat = 0
    @State private var isTruncated = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HTMLTextView(
                html: html,
                fontSize: fontSize,
                collapsedHeight: $collapsedHeight,
                fullHeight: $fullHeight,
                isTruncated: $isTruncated,
                maxLines: maxLines
            )
            .frame(height: isExpanded ? fullHeight : collapsedHeight, alignment: .top)
            .clipped()
            

            if isTruncated && !isExpanded {
                Button("See more") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isExpanded = true
                    }
                }
                .font(.system(size: fontSize - 1, weight: .medium))
                .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    let html = """
    <p>Adult Pickleball is back on for spring! 🌸 Event is on the 5th floor. 
    Bring a paddle and a friend (let me know if you need one)</p>
    <p>This is the location: 217 E. 87th St, New York, NY</p>
    <p>In association with the Phoenix sober movement</p>
    """
    
    ExpandableHTMLText(html: html)
        .padding()
}

#Preview("Longer text") {
    let html = """
    <p>Adult Pickleball is back on for spring! 🌸 Event is on the 5th floor. 
    Bring a paddle and a friend (let me know if you need one)</p>
    <p>This is the location: 217 E. 87th St, New York, NY</p>
    <p>In association with the Phoenix sober movement</p>
    <p>We meet every Saturday from 10am to 12pm. All skill levels are welcome. 
    Equipment is provided but feel free to bring your own paddle if you have one.</p>
    <p>Please RSVP so we can plan accordingly. Space is limited to 20 players per session.</p>
    """
    
    ExpandableHTMLText(html: html)
        .frame(width: 350)  // 👈 constrain width to simulate phone screen
}
