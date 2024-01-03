//
//  SportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/4/23.
//

import SwiftUI

struct SportsPicker: View {
    
    @Binding var selectedSports: [SPORT]
    @State private var row1 = [SPORT.soccer, SPORT.spikeball, SPORT.tennis]
    @State private var row2 = [SPORT.basketball, SPORT.volleyball, SPORT.golf]
    @State private var row3 = [SPORT.pickleball, SPORT.climbing, SPORT.hiking]
    
    func addSport(_ sport: SPORT) {
        selectedSports.append(sport)
    }
    
    func removeSport(_ sport: SPORT) {
        selectedSports.removeAll(where: { $0.rawValue == sport.rawValue })
    }
    var body: some View {
        ScrollView {
            HStack(spacing: -10) {
                ForEach(row1, id: \.self){ _sport in
                    SportPickerItem(sport: _sport, selectedSports: $selectedSports)
                        .onTapGesture {
                            selectedSports.contains(where: { $0.rawValue == _sport.rawValue}) == true ? removeSport(_sport) : addSport(_sport)
                        }
                }
            }.padding(.vertical, 10)
            HStack(spacing: -10) {
                ForEach(row2, id: \.self){ _sport in
                    SportPickerItem(sport: _sport, selectedSports: $selectedSports)
                        .onTapGesture {
                            selectedSports.contains(where: { $0.rawValue == _sport.rawValue}) == true ? removeSport(_sport) : addSport(_sport)
                        }
                }
            }
            HStack(spacing: -10) {
                ForEach(row3, id: \.self){ _sport in
                    SportPickerItem(sport: _sport, selectedSports: $selectedSports)
                        .onTapGesture {
                            selectedSports.contains(where: { $0.rawValue == _sport.rawValue}) == true ? removeSport(_sport) : addSport(_sport)
                        }
                }
            }.padding(.vertical, 10)
        }
    }
}

struct SportPickerItem: View {
    enum STYLE {
        case normal
        case outline
    }
    @State var sport: SPORT = .spikeball
    @Binding var selectedSports: [SPORT]
    
    var style: STYLE {
        selectedSports.contains(where: { $0.rawValue == sport.rawValue }) == true ? .normal : .outline
    }
    
    var body: some View {
        ZStack {
            switch style {
            case.normal:
                Rectangle()
                    .stroke(Color("color-prime"), lineWidth: 3)
            case .outline:
                Rectangle()
                    .stroke(Color("color-secnd"), lineWidth: 1)
            }
            VStack {
                sport.Icon()
                    .resizable()
                    .frame(width: 50, height: 55)
                Text(sport.rawValue)
                    .textCase(.uppercase)
                .font(.caption)
            }
        }.frame(width: 100, height: 100)
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

