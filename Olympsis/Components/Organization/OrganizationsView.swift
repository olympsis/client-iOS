//
//  OrganizationsView.swift
//  Olympsis
//
//  Created by Joel on 11/26/23.
//

import os
import SwiftUI
import CoreLocation

struct OrganizationsView: View {
    
    @State private var text: String = ""
    @State var organizations = [Organization]()
    @State private var showCancel: Bool = false
    @EnvironmentObject private var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    var organizationID: String {
        guard let selectedGroup = session.selectedGroup,
              let organization = selectedGroup.organization,
              let id = organization.id else {
            return ""
        }
        return id
    }
    
    private var filteredOrganizations: [Organization] {
        if text == "" {
            return organizations
        } else {
            return organizations.filter{ $0.name!.lowercased().contains(text.lowercased()) }
        }
    }
    
    private var geoCoder = CLGeocoder()
    private var log = Logger(subsystem: "com.josephlabs.olympsis", category: "clubs_list_view")
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    HStack {
                        SearchBar(text: $text, onCommit: {
                            showCancel = false
                        }).onTapGesture {
                                if !showCancel {
                                    showCancel = true
                                }
                            }
                        .frame(maxWidth: SCREEN_WIDTH-10, maxHeight: 40)
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                        .padding(.top)
                        if showCancel {
                            Button(action:{
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                                showCancel = false
                            }){
                                Text("Cancel")
                                    .foregroundColor(.gray)
                                    .frame(height: 40)
                                    .padding(.top)
                            }.padding(.trailing)
                        }
                    }
                    if filteredOrganizations.count > 0 {
                        ForEach(filteredOrganizations) { org in
                            OrgListView(organization: org, showToast: .constant(false))
                        }
                    } else {
                        Text("No Organizations")
                    }
                    
                }.refreshable {
                    guard let location = session.locationManager.location else {
                        return
                    }
                    
                    let l = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    
                    do {
                        let locale = Locale(identifier: "en_US")
                        let pk = try await geoCoder.reverseGeocodeLocation(l, preferredLocale: locale)
                        guard let country = pk.first?.country,
                              let state = pk.first?.administrativeArea,
                              let res = await session.orgObserver.getOrganizations(country: country, state: state) else {
                            return
                        }
                        await MainActor.run {
                            organizations = res
                        }
                    } catch {
                        log.error("\(error)")
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{self.presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color("color-prime"))
                    }
                }
            }
            .navigationTitle("Organizations")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                guard let location = session.locationManager.location else {
                    return
                }
                
                let l = CLLocation(latitude: location.latitude, longitude: location.longitude)
                
                do {
                    let locale = Locale(identifier: "en_US")
                    let pk = try await geoCoder.reverseGeocodeLocation(l, preferredLocale: locale)
                    guard let country = pk.first?.country,
                          let state = pk.first?.administrativeArea,
                          let res = await session.orgObserver.getOrganizations(country: country, state: state) else {
//                        status = .failure
                        return
                    }
                    
                    await MainActor.run {
                        organizations = res
                    }
                } catch {
                    log.error("\(error)")
                }
            }
        }
    }
}

#Preview {
    OrganizationsView()
        .environmentObject(SessionStore())
}
