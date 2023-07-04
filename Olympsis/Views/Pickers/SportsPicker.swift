//
//  SportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/4/23.
//

import SwiftUI

struct SportsPicker: View {
    
    @Binding var selectedSports: [SPORT]
    
    func addSport(_ sport: SPORT) {
        selectedSports.append(sport)
    }
    
    func removeSport(_ sport: SPORT) {
        selectedSports.removeAll(where: { $0.rawValue == sport.rawValue })
    }
    var body: some View {
        ScrollView {
            ForEach(SPORT.allCases, id: \.self){ _sport in
                SportPickerItem(sport: _sport, selectedSports: $selectedSports)
                    .onTapGesture {
                        selectedSports.contains(where: { $0.rawValue == _sport.rawValue}) == true ? removeSport(_sport) : addSport(_sport)
                    }
            }
        }
    }
}

struct SportPickerItem: View {
    enum STYLE {
        case normal
        case outline
    }
    @State var sport: SPORT = .soccer
    @Binding var selectedSports: [SPORT]
    
    var style: STYLE {
        selectedSports.contains(where: { $0.rawValue == sport.rawValue }) == true ? .normal : .outline
    }
    
    var body: some View {
        ZStack {
            switch style {
            case.normal:
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color("secondary-color"))
                    .opacity(0.3)
            case .outline:
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("secondary-color"), lineWidth: 1)
            }
            Text(sport.rawValue)
        }.frame(height: 45)
            .padding(.horizontal)
            .contentShape(Rectangle())
    }
}


struct SportsPicker_Previews: PreviewProvider {
    static var previews: some View {
        SportsPicker(selectedSports: .constant([SPORT]()))
        SportPickerItem(selectedSports: .constant([SPORT]()))
    }
}

