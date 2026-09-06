//
//  EventTypePicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 2/5/25.
//


import SwiftUI

/// A simple view to help users pick and understand the event type settings
struct EventTypePicker: View {

    @Binding var type: EVENT_TYPES
    @Environment(\.dismiss) private var dismiss
    
    func pickEventType(_ eventType: EVENT_TYPES) {
        withAnimation(.easeIn) {
            type = eventType
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss();
        }
    }
    
    @ViewBuilder
    func pickerItem(_ eventType: EVENT_TYPES) -> some View {
        Button(action: { pickEventType(eventType) }) {
            VStack(alignment: .leading) {
                HStack {
                    eventType.image()
                        .foregroundStyle(Color.Foreground.yellow)
                    Text(eventType.displayName())
                        .fontWeight(.bold)
                        .foregroundStyle(Color.Foreground.default)
                }.padding(.bottom, 5)
                
                Text(eventType.description())
                    .multilineTextAlignment(.leading)
                
                if let tip = eventType.tip() {
                    Text(tip)
                        .italic()
                        .font(.caption)
                        .fontWeight(.light)
                        .padding(.top, 5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 26)
                    .foregroundStyle(Color.Background.secondary)
                    .overlay {
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(type == eventType ? Color.Foreground.default : Color.border, lineWidth: type == eventType  ? 2 : 1)
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
                    Text(String(localized: "event-type-title", table: "Events"))
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
                pickerItem(.Regular)
                pickerItem(.Class)
//                pickerItem(.Tournament)
//                pickerItem(.Match)
//                pickerItem(.League)
                
                Spacer(minLength: 50)
            }.contentMargins(.top, 5)
        }
        .ignoresSafeArea(.all)
        .presentationDragIndicator(.visible)
        .background(Color.Background.primary.ignoresSafeArea())
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            EventTypePicker(type: .constant(.Regular))
        }
}
