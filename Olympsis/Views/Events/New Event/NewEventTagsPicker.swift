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
    
    func addTag(_ tag: Tag) {
        if !selectedTags.contains(where: { $0.name == tag.name }) {
            selectedTags.append(tag)
        } else {
            selectedTags.removeAll(where: { $0.name == tag.name })
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(localized: "new-event-tags-title", table: "Events"))
                .font(.headline)
                .bold()
            Text(String(localized: "new-event-tags-sub-title", table: "Events"))
                .foregroundColor(.gray)
                .font(.subheadline)
            
            HStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(selectedTags, id: \.name) { tag in
                            TagView(tag: tag)
                        }
                    }
                    .padding(.leading, 10)
                }
                .scrollIndicators(.hidden)
                
                Spacer()
                Button(action: { showTags.toggle() }) {
                    Image(systemName: "plus")
                        .padding(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        }
                }
                .padding(.trailing, 5)
            }.modifier(InputFieldModifier())
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
                                        RoundedRectangle(cornerRadius: 14)
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
}
