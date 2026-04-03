//
//  NewEventExternalLink.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/14/25.
//

import SwiftUI

struct NewEventExternalLink: View {
    
    /// Local editable copy of the links, synced to the manager on disappear.
    @State private var links: [EventLink] = []
    
    @Environment(NewEventManager.self) private var manager
    
    // MARK: - Validation
    
    private func isValidURLFormat(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.host?.contains(".") == true,
            !components.host!.hasPrefix("."),
            !components.host!.hasSuffix("."),
            components.scheme != nil else {
            return false
        }
        return true
    }
    
    /// Normalizes a URL string by prepending https:// if no scheme is present.
    private func normalizedURL(_ raw: String) -> String {
        raw.contains("://") ? raw : "https://" + raw
    }
    
    private func isLinkValid(_ link: EventLink) -> Bool {
        !link.url.isEmpty && isValidURLFormat(normalizedURL(link.url))
    }
    
    // MARK: - Actions
    
    private func addLink() {
        links.append(EventLink(title: "", url: ""))
    }
    
    private func removeLink(at offsets: IndexSet) {
        links.remove(atOffsets: offsets)
    }
    
    // MARK: - View
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "advanced-settings-external-link", table: "Events"))
                    .font(.headline)
                    .bold()
                Text(String(localized: "advanced-settings-external-link-sub-title", table: "Events"))
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                ForEach(Array(links.enumerated()), id: \.offset) { index, link in
                    VStack(spacing: 8) {
                        // Title field
                        HStack {
                            TextField(text: $links[index].title) {
                                Text(String(localized: "event-notification-title-label", table: "Events"))
                            }
                            .padding(.horizontal)
                            .disableAutocorrection(true)
                            
                            // Delete button
                            Button(action: {
                                links.remove(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .padding(.trailing, 8)
                        }
                        .modifier(InputFieldModifier())
                        
                        // URL field
                        HStack {
                            TextField(text: $links[index].url) {
                                Text("www.olympsis.com")
                            }
                            .padding(.horizontal)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .foregroundStyle(
                                links[index].url.isEmpty || isLinkValid(links[index])
                                ? Color.primary
                                : Color.red
                            )
                        }
                        .modifier(InputFieldModifier())
                    }
                    .padding(.top, index > 0 ? 8 : 0)
                }
                
                // Add link button
                Button(action: { addLink() }) {
                    Label(String(localized: "event-add-link", table: "Events"), systemImage: "plus.circle.fill")
                        .font(.subheadline)
                }
                .padding(.top, 4)
                
                Spacer()
            }
            .padding([.top, .horizontal])
            .onAppear {
                // Populate from manager if links already exist
                if !manager.externalLinks.isEmpty {
                    links = manager.externalLinks
                } else {
                    // Start with one empty link row for convenience
                    links = [EventLink(title: "", url: "")]
                }
            }
            .onDisappear {
                // Only save links that have a valid URL
                manager.externalLinks = links.filter { isLinkValid($0) }
            }
        }
    }
}

#Preview {
    NewEventExternalLink()
        .environment(NewEventManager())
    
}
