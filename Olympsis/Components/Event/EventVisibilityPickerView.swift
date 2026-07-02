//
//  EventVisibilityPicker.swift
//  Olympsis
//
//  Created by Joel on 12/13/23.
//

import SwiftUI

/// A simple view to help users pick and understand the event visibility settings
struct EventVisibilityPickerView: View {

    @Binding var visibility: EVENT_VISIBILITY_TYPES
    @Environment(\.dismiss) private var dismiss

    func pickVisibility(_ visibilityType: EVENT_VISIBILITY_TYPES) {
        withAnimation(.easeIn) {
            visibility = visibilityType
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss();
        }
    }

    @ViewBuilder
    func pickerItem(_ visibilityType: EVENT_VISIBILITY_TYPES) -> some View {
        Button(action: { pickVisibility(visibilityType) }) {
            VStack(alignment: .leading) {
                HStack {
                    visibilityType.image()
                        .foregroundStyle(Color.Foreground.yellow)
                    Text(visibilityType.name())
                        .fontWeight(.bold)
                        .foregroundStyle(Color.Foreground.default)
                }.padding(.bottom, 5)

                Text(visibilityType.description())
                    .multilineTextAlignment(.leading)

                if let tip = visibilityType.tip() {
                    Text(tip)
                        .italic()
                        .font(.caption)
                        .fontWeight(.light)
                        .padding(.top, 5)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 26)
                    .foregroundStyle(Color.Background.secondary)
                    .overlay {
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(visibility == visibilityType ? Color.Foreground.default : Color.border, lineWidth: visibility == visibilityType ? 2 : 1)
                    }
            }
        }
        .padding(.horizontal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text(String(localized: "visibility-title", table: "Events"))
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }

                Rectangle()
                    .frame(height: 1)
                    .padding(.top, 15)
                    .foregroundStyle(Color.border)
            }
            .padding(.top, 20)
            .padding(.bottom, 5)

            ScrollView {
                pickerItem(.Public)
                pickerItem(.Private)
//                pickerItem(.Group)

                Spacer(minLength: 50)
            }.contentMargins(.top, 5)
        }
        .ignoresSafeArea(.all)
        .presentationDragIndicator(.visible)
        .background { Color.Background.primary }
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            EventVisibilityPickerView(visibility: .constant(.Public))
        }
}
