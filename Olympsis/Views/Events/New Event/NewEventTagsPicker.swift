//
//  NewEventTagsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/1/25.
//

import SwiftUI

struct NewEventTagsPicker: View {
    
    var tags: [Tag]
    @Binding var selectedTags: [Tag]
    @State private var showTags: Bool = false
    
    /// Toggles a tag in/out of the selection (tags are multi-select).
    func addTag(_ tag: Tag) {
        if !selectedTags.contains(where: { $0.name == tag.name }) {
            selectedTags.append(tag)
        } else {
            selectedTags.removeAll(where: { $0.name == tag.name })
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "new-event-tags-title", table: "Events").uppercased())
                .font(.caption)
                .bold()
            
            HStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(selectedTags, id: \.name) { tag in
                            TagView(tag: tag, backgroundColor: Color.Background.tertiary)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                
                Button(action: { showTags.toggle() }) {
                    Image(systemName: "plus")
                        .foregroundStyle(.primary)
                }.background {
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.Background.tertiary)
                        .overlay {
                            Circle()
                                .stroke(Color.border)
                        }
                }
                .padding(.trailing, 15)
            }
            .padding(10)
            .frame(height: 67)
            .background {
                Capsule()
                    .foregroundStyle(Color.Background.secondary)
                    .overlay {
                        Capsule()
                            .stroke(Color.border)
                    }
            }
        }
        .sheet(isPresented: $showTags) {
            ScrollView(.vertical) {
                Spacer(minLength: 20)
                WrappingHStack(alignment: .bottomLeading) {
                    ForEach(tags, id: \.name) { tag in
                        Button(action: {
                            addTag(tag)
                        }) {
                            TagView(tag: tag)
                                .overlay {
                                    if selectedTags.contains(where: { $0.name == tag.name }) {
                                        Capsule()
                                            .stroke(Color.Brand.secondary, lineWidth: 1)
                                    }
                                }
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(.horizontal)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NewEventTagsPicker(tags: TAGS_TEMP, selectedTags: .constant([Tag(name: "beginner-friendly")]))
        .padding(.horizontal)
}
