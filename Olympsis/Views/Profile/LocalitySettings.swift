//
//  LocalitySettings.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/14/26.
//

import SwiftUI

/// "Locality" settings — regional presentation preferences. Currently
/// houses the distance unit used for the search radius and venue
/// distances. The unit defaults to the device region on first launch
/// (see ``DistanceUnit/deviceDefault``); the picker here lets the user
/// override it, and that choice is persisted under
/// ``DistanceUnit/storageKey``.
struct LocalitySettings: View {

    @Environment(\.dismiss) private var dismiss

    /// Stored as the unit's raw value. An empty string means "not chosen
    /// yet", which `DistanceUnit.resolved(from:)` maps to the device
    /// default — so the picker shows the right unit on first open without
    /// us having to seed storage.
    @AppStorage(DistanceUnit.storageKey) private var distanceUnitRaw: String = ""

    /// Two-way binding that resolves the stored raw value to a concrete
    /// `DistanceUnit` for the picker and writes the user's pick straight
    /// back to storage.
    private var distanceUnit: Binding<DistanceUnit> {
        Binding(
            get: { DistanceUnit.resolved(from: distanceUnitRaw) },
            set: { distanceUnitRaw = $0.rawValue }
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "locality-distance-unit", table: "Settings"))
                    .fontWeight(.medium)
                    .padding(.horizontal)

                Picker(
                    String(localized: "locality-distance-unit", table: "Settings"),
                    selection: distanceUnit
                ) {
                    ForEach(DistanceUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Text(String(localized: "locality-distance-unit-sub-title", table: "Settings"))
                    .font(.caption)
                    .padding(.horizontal)
                    .foregroundStyle(.gray)
            }

            Spacer()
        }
        .padding(.top)
        .navigationTitle(String(localized: "locality-title", table: "Settings"))
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
}

#Preview {
    LocalitySettings()
}
