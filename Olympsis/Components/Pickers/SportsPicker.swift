//
//  SportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 7/4/23.
//

import SwiftUI

struct SportsPicker: View {
    
    @Binding var selectedSports: [SPORTS]
    @State private var row1 = [SPORTS.soccer, SPORTS.spike, SPORTS.tennis]
    @State private var row2 = [SPORTS.basketball, SPORTS.volleyball, SPORTS.golf]
    @State private var row3 = [SPORTS.pickleball, SPORTS.climbing, SPORTS.hiking]
    
    func addSport(_ sport: SPORTS) {
        selectedSports.append(sport)
    }
    
    func removeSport(_ sport: SPORTS) {
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
    @State var sport: SPORTS = .spike
    @Binding var selectedSports: [SPORTS]
    
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
                sport.icon()
                    .resizable()
                    .frame(width: 50, height: 55)
                    .foregroundStyle(.black)
                Text(sport.rawValue)
                    .textCase(.uppercase)
                    .foregroundStyle(Color("color-prime"))
                .font(.caption)
            }
        }.frame(width: 100, height: 100)
            .background(Color.white)
            .padding(.horizontal)
            .contentShape(Rectangle())
        
    }
}


struct SportsPicker_Previews: PreviewProvider {
    static var previews: some View {
        SportsPicker(selectedSports: .constant([SPORTS]()))
        SportPickerItem(selectedSports: .constant([SPORTS]()))
    }
}

