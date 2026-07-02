//
//  NewEventView.swift
//  Olympsis
//
//  Created by Joel Joseph on 11/19/22.
//

import os
import SwiftUI

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
    
    /// The date/time picker currently being presented, if any. Using an
    /// item-based sheet lets each pill open the picker scoped to just the
    /// component it represents (date-only or time-only).
    @State private var activeDatePicker: DatePickerTarget?
    
    @State private var showAdvancedSettings: Bool = false
    @State private var showOrganizersPicker: Bool = false
    
    
    @FocusState private var titleFocus: Bool
    @FocusState private var descriptionFocus: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(SessionStore.self) private var session
    
    private let log = Logger(subsystem: "com.olympsis.client", category: "new_event_view")
    
    /// Dismisses the keyboard and presents the picker scoped to the given target.
    private func openPicker(_ target: DatePickerTarget) {
        titleFocus = false
        descriptionFocus = false
        activeDatePicker = target
    }

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
                handleFailure()
                self.showPostViolation.toggle()
            } catch {
                handleFailure()
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
            handleFailure()
            return
        }
        // Open the newly created event, then flip the button to its success state
        // (checkmark) and dismiss after a brief beat.
        openURL(url)
        handleSuccess()
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                HStack {
                    CircularButton(systemImage: "xmark", size: 44) { dismiss() }
                    
                    Spacer()
                    
                    Text(String(localized: "new-event-view-title", table: "Events"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Rectangle()
                        .opacity(0)
                        .frame(width: 44, height: 0)
                }.padding([.top, .horizontal])
                
                ScrollView {
                    NewEventTopView(
                        showTypePicker: $showTypePicker,
                        showVisibilityPicker: $showVisibilityPicker,
                        eventType: $manager.type,
                        eventVisibility: $manager.visibility
                    ).padding(.leading)
                    
                    // MARK: - Title and sports selection
                    VStack(alignment: .leading){
                        TextField(String(localized: "new-event-title-placeholder", table: "Events"), text: $manager.title)
                            .focused($titleFocus)
                            .padding(.leading)
                            .font(.custom("Archivo-BlackItalic", size: 30, relativeTo: .title))
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 5)
                    .id(1)
                    
                    // MARK: - Organizers Picker
                    NewEventOrganizers(manager: manager)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        .sheet(isPresented: $showOrganizersPicker) {
                            EventOrganizersPickerView(
                                selectedOrganizers: $manager.organizers
                            ).environment(session)
                        }
                    
                    // MARK: - Sports Picker
                    NewEventSportsPicker(sports: session.sports, selectedSports: $manager.selectedSports)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    // MARK: - Event start/stop dates
                    VStack(alignment: .leading) {
                        Text(String(localized: "new-event-time-title", table: "Events").uppercased())
                            .font(.caption)
                            .bold()

                        // Card containing the "Starts" and "Ends" rows, each with a
                        // date pill and a time pill that open the date picker sheet.
                        VStack(spacing: 0) {
                            // MARK: Starts row
                            HStack {
                                Text(String(localized: "new-event-starts-title", table: "Events"))
                                    .bold()

                                Spacer()

                                TimePill(text: manager.startDayString) { openPicker(.startDate) }
                                TimePill(text: manager.startTimeString) { openPicker(.startTime) }
                            }
                            .padding(.vertical, 12)
                            .id(2)

                            Divider()

                            // MARK: Ends row
                            HStack {
                                Text(String(localized: "new-event-ends-title", table: "Events"))
                                    .bold()

                                Spacer()

                                TimePill(text: manager.endDayString) { openPicker(.endDate) }
                                TimePill(text: manager.endTimeString) { openPicker(.endTime) }
                            }
                            .padding(.vertical, 12)
                            .id(3)
                        }
                        .padding(.horizontal)
                        // A single item-based sheet presents the picker scoped to
                        // whichever pill was tapped (date-only or time-only).
                        .sheet(item: $activeDatePicker) { target in
                            switch target {
                            case .startDate:
                                EventDatePickerView(eventTime: $manager.startDate, displayedComponents: .date)
                                    .presentationDetents([.medium])
                            case .startTime:
                                EventDatePickerView(eventTime: $manager.startDate, displayedComponents: .hourAndMinute)
                                    .presentationDetents([.medium])
                            case .endDate:
                                EventDatePickerView(eventTime: $manager.endDate, startingPoint: manager.startDate, displayedComponents: .date)
                                    .presentationDetents([.medium])
                            case .endTime:
                                EventDatePickerView(eventTime: $manager.endDate, startingPoint: manager.startDate, displayedComponents: .hourAndMinute)
                                    .presentationDetents([.medium])
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 26)
                                .foregroundStyle(manager.validationStatus == .unexpected ? Color.red.opacity(0.5) : Color.Background.secondary)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(Color.border)
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                    // MARK: - Description
                    VStack(alignment: .leading) {
                        Text(String(localized: "new-event-description-title", table: "Events").uppercased())
                            .font(.caption)
                            .bold()
                            .foregroundStyle(manager.validationStatus == .noDescription ? Color.red : Color.primary)

                        ZStack {
                            RoundedRectangle(cornerRadius: 26)
                                .foregroundStyle(Color.Background.secondary)
                                .frame(height: 250)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(manager.validationStatus == .noDescription ? Color.red : Color.border)
                                }
                            TextEditor(text: $manager.body)
                                .focused($descriptionFocus)
                                .frame(height: 230)
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 12)
                        }
                        .id(4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    // MARK: - Venue picker
                    VenuePickerButton(validationStatus: $manager.validationStatus)
                        .environment(session)
                        .environment(manager)
                        .listRowBackground(manager.validationStatus == .noSelectedField ? Color.red.opacity(0.5) : Color(UIColor.secondarySystemGroupedBackground))
                        .id(5)
                        .padding(.bottom, 10)
                    
                    // MARK: - Image picker
                    NewEventImagePicker()
                        .environment(manager)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    // MARK: - Tags and advanced settings
                    NewEventTagsPicker(tags: session.tags, selectedTags: $manager.selectedTags)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: { self.showAdvancedSettings.toggle() }) {
                            HStack {
                                Text(String(localized: "advanced-settings-title", table: "Events"))
                                    .fontWeight(.bold)
                                Image(systemName: "gearshape.fill")
                            }
                        }
                        .padding()
                        .background {
                                RoundedRectangle(cornerRadius: 26)
                                    .foregroundStyle(Color.Background.secondary)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 26)
                                            .stroke(Color.border)
                                    }
                            }
                        .padding(.trailing)
                        .padding(.bottom, 10)
                    }
                    
                    // MARK: - Action Button
                    HStack {
                        Spacer()
                        
                        Button(action: { handleEventCreation(value) }) {
                            LoadingButton(text: String(localized: "new-event-create-text", table: "Events"), width: 150, height: 50, status: $manager.status)
                        }
  
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .listRowBackground(Color.clear)
                    
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
                        manager.endDate = manager.startDate.addingTimeInterval(60 * 60)
                    }
                }
                .onChange(of: manager.endDate) { _, v in
                    if v < manager.startDate {
                        manager.endDate = manager.startDate.addingTimeInterval(60 * 60)
                    } else {
                        manager.endDate = v
                    }
                }
                .sheet(isPresented: $showAdvancedSettings, content: {
                    NewEventAdvancedSettings()
                        .environment(manager)
                })
                .sheet(isPresented: $showPostViolation, content: {
                    PostMediaViolation()
                })
                .task {
                    if let user = session.user {
                        manager.poster = user.toSnippet()
                    }
                    guard let first = session.sports.first else { return }
                    manager.selectedSports.append(first)
                }
            }
        }
        .background(Color.Background.primary.ignoresSafeArea())
        .onDisappear {
            manager.clearGeocodeCache()
        }
    }
}

/// Identifies which pill's picker is being presented so a single item-based
/// sheet can show the correct binding and scope (date-only vs time-only).
private enum DatePickerTarget: Identifiable {
    case startDate, startTime, endDate, endTime
    var id: Self { self }
}

/// A tappable, capsule-shaped pill used to display the event's date or time
/// inside the time card. Tapping it opens the associated date picker sheet.
private struct TimePill: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background {
                    Capsule()
                        .foregroundStyle(Color.Background.tertiary)
                }
        }
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true)) {
            NewEvent(manager: NewEventManager())
                .environment(SessionStore())
        }
}
