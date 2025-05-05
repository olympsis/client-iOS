//
//  LocalesPicker.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/17/25.
//

import os
import SwiftUI

struct LocalesPicker: View {
    
    @Binding var selectedCountry: Country?
    @Binding var selectedAdministrativeArea: AdministrativeArea?
    @Binding var selectedSubAdministrativeArea: SubAdministrativeArea?
    
    @State private var state: VIEW_STATE = .pending
    @State private var stateLoading: VIEW_STATE = .pending
    @State private var cityLoading: VIEW_STATE = .pending
    
    @State private var countries: [Country] = []
    @State private var adminAreas: [AdministrativeArea] = []
    @State private var subAdminAreas: [SubAdministrativeArea] = []
    
    private let managementService = ManagementService()
    private let logger: Logger = Logger(subsystem: "com.olympsis.client", category: "locales_picker")
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            switch state {
            case .pending, .success:
                List {
                    Picker("Country", selection: $selectedCountry) {
                        ForEach(countries.sorted(by: { $0.name < $1.name })) { country in
                            Text(country.name)
                                .tag(country as Country?)  // Tag with the actual Country object
                        }
                    }

                    if !adminAreas.isEmpty {
                        switch stateLoading {
                        case .pending, .success:
                            Picker("State", selection: $selectedAdministrativeArea) {
                                ForEach(adminAreas.sorted(by: { $0.name < $1.name })) { admin in
                                    Text(admin.name)
                                        .tag(admin as AdministrativeArea?)  // Tag with the actual AdministrativeArea object
                                }
                            }
                        case .loading:
                            ProgressView()
                        case .failure:
                            HStack {
                                Image(systemName: "xmark")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.red)
                                Text("Failed to get states!")
                            }
                        }
                    }

                    if !subAdminAreas.isEmpty {
                        switch cityLoading {
                        case .pending, .success:
                            Picker("City", selection: $selectedSubAdministrativeArea) {
                                ForEach(subAdminAreas.sorted(by: { $0.name < $1.name })) { sub in
                                    Text(sub.name)
                                        .tag(sub as SubAdministrativeArea?)  // Tag with the actual SubAdministrativeArea object
                                }
                            }
                        case .loading:
                            ProgressView()
                        case .failure:
                            HStack {
                                Image(systemName: "xmark")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.red)
                                Text("Failed to get cities!")
                            }
                        }
                    }
                }
            case .loading:
                ProgressView()
                    .padding(.vertical, 50)
            case .failure:
                VStack {
                    Image("illustrations/error")
                        .resizable()
                        .frame(width: 150, height: 100)
                    
                    Text("Something went wrong. Please try again later.")
                        .padding()
                        .font(.callout)
                        .fontWeight(.bold)
                        .frame(width: 200)
                        .multilineTextAlignment(.center)
                        
                }
                .padding(.vertical, 50)
            }
            
            Button(action: { dismiss() }) {
                Text("Done")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 40)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.Brand.primary)
            }
        }
        .frame(height: 300)
        .onChange(of: selectedCountry, { _, newValue in
            guard let ctry = newValue else {
                return
            }
            
            Task { @MainActor in
                do {
                    stateLoading = .loading
                    let resp = try await managementService.getAdministrativeAreas(ctry)
                    selectedAdministrativeArea = resp.first
                    adminAreas = resp
                    stateLoading = .success
                } catch {
                    logger.error("Failed to get admin areas. Error: \(error)")
                    stateLoading = .failure
                }
            }
        })
        .onChange(of: selectedAdministrativeArea, { oldValue, newValue in
            guard oldValue != nil,
                let admin = newValue else {
                return
            }
            
            Task { @MainActor in
                do {
                    cityLoading = .loading
                    let resp = try await managementService.getSubAdministrativeAreas(admin)
                    selectedSubAdministrativeArea = resp.first
                    subAdminAreas = resp
                    cityLoading = .success
                } catch {
                    logger.error("Failed to get sub admin areas. Error: \(error)")
                    cityLoading = .failure
                }
            }
        })
        .task {
            do {
                state = .loading
                selectedCountry = nil
                selectedAdministrativeArea = nil
                selectedSubAdministrativeArea = nil
                
                let resp = try await managementService.getCountries()
                selectedCountry = resp.first
                countries = resp
                state = .success
            } catch {
                logger.error("Failed to get countries. Error: \(error)")
                state = .failure
            }
        }
    }
}

#Preview {
    LocalesPicker(selectedCountry: .constant(nil), selectedAdministrativeArea: .constant(nil), selectedSubAdministrativeArea: .constant(nil))
}
