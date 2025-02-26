//
//  GroupSelectionListItem.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/3/24.
//

import SwiftUI
import Kingfisher

struct GroupSelectionListItem: View {
    
    @State private var imageFailed: Bool = false
    
    var selectedGroup: GroupSelection
    @Binding var selectionID: UUID?
    
    var logo: URL? {
        switch selectedGroup.type {
        case .Club:
            guard let url = selectedGroup.club?.logo else {
                return nil
            }
            return generateImageURL(url)
        case .Organization:
            guard let url = selectedGroup.organization?.logo else {
                return nil
            }
            return generateImageURL(url)
        }
    }
    
    var name: String {
        switch selectedGroup.type {
        case .Club:
            guard let name = selectedGroup.club?.name else {
                return "Olympsis Club"
            }
            return name
        case .Organization:
            guard let name = selectedGroup.organization?.name else {
                return "Olympsis Organization"
            }
            return name
        }
    }
    
    var body: some View {
        HStack {
            KFImage(logo)
                .placeholder({
                    ImageLoadingView()
                })
                .onFailure({ _ in
                    imageFailed = true
                })
                .resizable()
                .frame(width: 40, height: 40)
                .aspectRatio(contentMode: .fill)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    if imageFailed {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(Color.Background.secondary))
                            .opacity(0.3)
                            .overlay {
                                Image(systemName: "person.2")
                            }
                    }
                }
                .overlay {
                    if selectionID == selectedGroup.id {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary, lineWidth: 4)
                            .frame(width: 40, height: 40)
                    }
                }
            
            Text(name)
                .foregroundStyle(.primary)
                .fontWeight(selectionID == selectedGroup.id ? .bold : .regular)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    GroupSelectionListItem(selectedGroup: GroupSelection(type: .Club, club: CLUBS[0]), selectionID: .constant(nil))
}
