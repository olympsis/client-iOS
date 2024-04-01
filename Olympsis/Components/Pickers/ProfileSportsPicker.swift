//
//  ProfileSportsPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 3/28/24.
//

import SwiftUI

struct ProfileSportsPicker: View {
    
    @Binding var selectedSports: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: .infinity, idealHeight: 40, maxHeight: 40)
                        .padding(.horizontal)
                        .foregroundStyle(Color("background"))
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(selectedSports), id: \.self) { sport in
                                HStack {
                                    Text(sport)
                                        .foregroundStyle(.white)
                                    Button(action: {
                                        selectedSports.remove(sport)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Color("background"))
                                    }
                                }.padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color("color-prime"))
                                    }
                            }
                        }
                    }.scrollIndicators(.never)
                    .padding(.horizontal, 20)
                }.padding(.top)
                
                ScrollView {
                    ForEach(SPORT.allCases, id: \.self){ _sport in
                        HStack {
                            Button(action: { selectedSports.insert(_sport.rawValue) }){
                                Text(_sport.rawValue)
                                    .font(.body)
                            }
                            Spacer()
                        }.padding(.top)
                    }
                }.scrollIndicators(.never)
                .padding(.horizontal)
                
            }.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .foregroundStyle(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileSportsPicker(selectedSports: .constant(["soccer", "tennis"]))
}
