//
//  NewEventExternalLink.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/14/25.
//

import SwiftUI

struct NewEventExternalLink: View {
    
    @Bindable var manager: NewEventManager
    
    @State private var link: String = ""
    @State private var isValidURL: Bool = false
    
    private func isValidURLFormat(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.host?.contains(".") == true,  // Require at least one dot in host
            !components.host!.hasPrefix("."),        // Don't allow leading dot
            !components.host!.hasSuffix("."),        // Don't allow trailing dot
            components.scheme != nil else {
            return false
        }
        return true
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text("External Link")
                .font(.title3)
                .bold()
            Text("Send the user to this link after RSVP")
                .foregroundColor(.gray)
                .font(.subheadline)
            
            HStack {
                TextField(text: $link) {
                    Text("www.olympsis.com")
                }
                .padding(.horizontal)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .foregroundStyle(isValidURL ? Color.primary : Color.red)
                .onChange(of: link) { _, newValue in
                    guard isValidURLFormat(newValue.contains("https://") ? newValue : "https://" + newValue) else {
                        self.isValidURL = false
                        return
                    }
                    self.isValidURL = true
                    manager.externalLink = newValue.contains("https://") ? newValue : "https://" + newValue
                }
            }.modifier(InputField())
            
            Spacer()
        }
        .padding(.top)
        .padding(.horizontal)
        .background(Color.Background.primary)
    }
}

#Preview {
    NewEventExternalLink(manager: NewEventManager())
}
