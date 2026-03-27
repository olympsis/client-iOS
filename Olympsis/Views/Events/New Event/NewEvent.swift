//
//  NewEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/19/22.
//

import os
import SwiftUI
//import AlertToast

struct NewEvent: View {
    
    @State var manager: NewEventManager
    
    @State private var showToast: Bool = false
    
    @State private var showTypePicker: Bool = false
    @State private var showVisibilityPicker: Bool = false
    @State private var showSkillLevelPicker: Bool = false
    
    @State private var isEditing: Bool = false
    
    @State private var showVenuePicker: Bool = false
    @State private var showSportsPicker: Bool = false
    
    @State private var showPostViolation: Bool = false
    @State private var showCompletedToast: Bool = false
    
    @State private var showStartTimePicker: Bool = false
    @State private var showStopTimePicker: Bool = false
    
    @State private var showAdvancedSettings: Bool = false
    @State private var showOrganizersPicker: Bool = false
    
    
    @FocusState private var titleFocus: Bool
    @FocusState private var descriptionFocus: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(SessionStore.self) private var session
    
    private let log = Logger(subsystem: "com.olympsis.client", category: "new_event_view")
    
    private func handleFailure() {
        manager.status = .failure
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            manager.status = .pending
        }
    }
    
    private func handleSuccess() {
        manager.status = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    
    private func handleEventCreation(_ value: ScrollViewProxy) {
        Task {
            guard manager.status != .loading else { return }
            
            do {
                try await createEvent(value: value)
            } catch MediaUploadError.innapropriateContent {
                self.showPostViolation.toggle()
            } catch {
                showToast.toggle()
            }
        }
    }
    
    @MainActor
    private func createEvent(value: ScrollViewProxy) async throws {
        guard manager.validateEvent(value: value) == nil  else {
            handleFailure()
            return
        }
        manager.status = .loading

        guard let user = session.user else {
            handleFailure()
            return
        }
        
        guard let id = try await manager.createEvent(user: user),
            let url = URL(string: "olympsis://events?id=\(id)") else {
            log.error("Failed to create event. No ID or failed to construct URL.")
            return
        }
        openURL(url)
        dismiss()
    }
    
    var body: some View {
        ScrollViewReader { value in
            Form {
                // MARK: - Title and sports selection
                Section {
                    NewEventTopView(
                        showTypePicker: $showTypePicker,
                        showVisibilityPicker: $showVisibilityPicker,
                        eventType: $manager.type,
                        eventVisibility: $manager.visibility
                    )
                    
                    VStack(alignment: .leading){
                        TextField("Event Title", text: $manager.title)
                            .focused($titleFocus)
                            .padding(.leading)
                            .modifier(InputFieldModifier())
                    }
                    .listRowBackground(manager.validationStatus == .noTitle ? Color.red.opacity(0.5) : Color(UIColor.secondarySystemGroupedBackground))
                    .id(1)
                    
                    NewEventSportsPicker(sports: session.sports, selectedSports: $manager.selectedSports)
                }
                
                // MARK: - Organizers Picker
                Section {
                    VStack(alignment: .leading){
                        HStack {
                            NewEventOrganizers(manager: manager)
                            Spacer()
                        }
                    }
                    .fullScreenCover(isPresented: $showOrganizersPicker) {
                        EventOrganizersPickerView(
                            selectedOrganizers: $manager.organizers
                        ).environment(session)
                    }
                }
                
                // MARK: - Event start/stop dates
                Section {
                    VStack(alignment: .leading){
                        Text(String(localized: "new-event-start-time-title", table: "Events"))
                            .font(.headline)
                            .bold()
                        
                        Button(action: {
                            titleFocus = false
                            descriptionFocus = false
                            self.showStartTimePicker.toggle()
                        }) {
                            Text(manager.startDateString)
                                .modifier(InputFieldModifier())
                        }
                    }
                    .sheet(isPresented: $showStartTimePicker, content: {
                        EventDatePickerView(eventTime: $manager.startDate)
                            .presentationDetents([.medium])
                    })
                    .id(2)
                    
                    
                    VStack(alignment: .leading){
                        Text(String(localized: "new-event-stop-time-title", table: "Events"))
                            .font(.headline)
                            .bold()
                        
                        Button(action: {
                            titleFocus = false
                            descriptionFocus = false
                            self.showStopTimePicker.toggle()
                        }) {
                            Text(manager.endDateString)
                                .modifier(InputFieldModifier())
                        }
                    }
                    .sheet(isPresented: $showStopTimePicker, content: {
                        EventDatePickerView(eventTime: $manager.endDate, startingPoint: manager.startDate)
                            .presentationDetents([.medium])
                    })
                    .listRowBackground(manager.validationStatus == .unexpected ? Color.red.opacity(0.5) : Color(UIColor.secondarySystemGroupedBackground))
                    .id(3)
                }
                
                // MARK: - Description
                Section {
                    VStack(alignment: .leading){
                        Text(String(localized: "new-event-description-title", table: "Events"))
                            .font(.headline)
                            .bold()
                        Text(String(localized: "new-event-description-sub-title", table: "Events"))
                            .foregroundColor(manager.validationStatus == .noDescription ? .red : .gray)
                            .font(.subheadline)
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.Background.secondary)
                                .frame(height: 150)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                                }
                            TextEditor(text: $manager.body)
                                .focused($descriptionFocus)
                                .frame(height: 145)
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 5)
                        }
                    }
                    .listRowBackground(manager.validationStatus == .noDescription ? Color.red.opacity(0.5) : Color(UIColor.secondarySystemGroupedBackground))
                    .id(4)
                }
                
                // MARK: - Venue picker
                Section {
                    VenuePickerButton(validationStatus: $manager.validationStatus)
                        .environment(session)
                        .environment(manager)
                        .listRowBackground(manager.validationStatus == .noSelectedField ? Color.red.opacity(0.5) : Color(UIColor.secondarySystemGroupedBackground))
                        .id(5)
                }
                
                // MARK: - Image picker
                Section {
                    NewEventImagePicker()
                        .environment(manager)
                }
                
                // MARK: - Tags and advanced settings
                Section {
                    NewEventTagsPicker(tags: session.tags, selectedTags: $manager.selectedTags)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: { self.showAdvancedSettings.toggle() }) {
                            HStack {
                                Text(String(localized: "advanced-settings-title", table: "Events"))
                                    .fontWeight(.bold)
                                Image(systemName: "gearshape.fill")
                            }
                        }
                    }
                }
                
                // MARK: - Action Button
                VStack(alignment: .center){
                    Button(action: { handleEventCreation(value) }) {
                        LoadingButton(text: String(localized: "new-event-create-text", table: "Events"), width: 150, height: 50, status: $manager.status)
                    }
                }.listRowBackground(Color.clear)
                
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                if #available(iOS 26.0, *) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(String(localized: "new-event-view-title", table: "Events"))
                            .italic()
                            .textCase(.uppercase)
                            .fontWeight(.bold)
                    }.sharedBackgroundVisibility(.hidden)
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(String(localized: "new-event-view-title", table: "Events"))
                            .italic()
                            .textCase(.uppercase)
                            .fontWeight(.bold)
                    }
                }
            
            }
            .onChange(of: manager.startDate) { _, v in
                if v > manager.endDate {
                    manager.endDate = manager.startDate.addingTimeInterval(30 * 60)
                }
            }
            .onChange(of: manager.endDate) { _, v in
                if v < manager.startDate {
                    manager.endDate = manager.startDate.addingTimeInterval(30 * 60)
                } else {
                    manager.endDate = v
                }
            }
            .fullScreenCover(isPresented: $showAdvancedSettings, content: {
                NewEventAdvancedSettings()
                    .environment(manager)
            })
            .sheet(isPresented: $showPostViolation, content: {
                PostMediaViolation()
            })
            .task {
                guard let first = session.sports.first else { return }
                manager.selectedSports.append(first)
            }
        }
        .onDisappear {
            manager.clearGeocodeCache()
        }
    }
}

#Preview {
    NavigationStack {
        NewEvent(manager: NewEventManager())
            .environment(SessionStore())
    }
}
