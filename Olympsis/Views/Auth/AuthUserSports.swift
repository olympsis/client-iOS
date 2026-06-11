//
//  AuthUserSports.swift
//  Olympsis
//
//  Created by Joel Joseph on 4/5/25.
//

import SwiftUI

struct AuthUserSports: View {
    
    @Binding var currentView: AuthTab
    
    @State private var selectedSports: [Sport] = []
    @State private var state: LOADING_STATE = .pending
    
    private let userObserver = UserObserver()
    private let cacheService = CacheService()
    
    @AppStorage("auth_type") private var authType: USER_STATUS?
    @AppStorage("auth_status") private var authStatus: AUTH_STATUS?
    
    @Environment(SessionStore.self) private var session
    
    @MainActor
    private func selectSport(_ sport: Sport) {
        if selectedSports.contains(where: { $0.name == sport.name }) {
            selectedSports.removeAll { $0.name == sport.name }
        } else {
            selectedSports.append(sport)
        }
    }
    
    @MainActor
    private func isSportSelected(_ sport: Sport) -> Bool {
        return selectedSports.contains(where: { $0.name == sport.name })
    }
    
    @MainActor
    private func updateUser() {
        guard !selectedSports.isEmpty,
            state != .loading else { return }
        
        Task {
            state = .loading
            let parts = selectedSports.map { sport -> String in
                let components = sport.name.components(separatedBy: " ")
                // Strip emoji prefix if present (e.g. "⚽ soccer" -> "soccer")
                return components.count > 1 ? components.dropFirst().joined(separator: " ") : components[0]
            }
            let dao = UserDao(sports: parts)
            
            guard let updates = await session.userObserver.updateUserData(update: dao) else {
                state = .failure
                return
            }
            
            // Store user into cache and update session store
            session.user = updates
            cacheService.cacheUser(user: updates)
            
            // Move user to the full application
            authType = nil
            authStatus = .authenticated
        }
        
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(String(localized: "auth-user-sports-title", table: "Onboarding"))
                    .font(.custom("Archivo-Bold", size: 25, relativeTo: .title))
                
                Text(String(localized: "auth-user-sports-sub-title", table: "Onboarding"))
                    .font(.subheadline)
                    .padding(.bottom)
            }
            .padding(.vertical, 5)
            .padding(.horizontal)
            
            Rectangle()
                .frame(height: 1)
            
            ScrollView {
                WrappingHStack(alignment: .bottomLeading) {
                    ForEach(session.sports, id: \.name) { sport in
                        Button(action: { selectSport(sport) }) {
                            Text("\(sport.name.capitalized.replacingOccurrences(of: "-", with: " "))")
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background(.regularMaterial)
                                .background(isSportSelected(sport) ? Color.Brand.secondary.opacity(0.7) : Color.gray.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .background {
                                    RoundedRectangle(cornerRadius: 20).stroke(isSportSelected(sport) ? Color.Brand.secondary : Color.Foreground.default.opacity(0.5), lineWidth: isSportSelected(sport) ? 4 : 2)
                                }
                        }
                    }
                }.padding([.top, .horizontal])
            }.padding(.top, -8)
            
            HStack {
                Spacer()
                
                Button(action: { updateUser() }) {
                    LoadingButton(text: String(localized: "done", table: "General"), status: $state)
                        .padding(.top, -8)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    AuthUserSports(currentView: .constant(.sports))
        .environment(SessionStore())
}
