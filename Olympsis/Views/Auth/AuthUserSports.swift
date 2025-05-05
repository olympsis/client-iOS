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
            let dao = UserDao(sports: selectedSports.map { $0.name.components(separatedBy: " ")[1] })
            
            guard let updates = await session.userObserver.UpdateUserData(update: dao) else {
                state = .failure
                return
            }
            cacheService.cacheUser(user: updates)
            authType = nil
            authStatus = .authenticated
        }
        
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Which sports are you into?")
                    .font(.custom("Archivo-Bold", size: 25, relativeTo: .title))
                
                Text("Pick the sports you play or want to learn. We’re adding more soon. Let us know if there’s one you’d like to see!")
                    .font(.subheadline)
                    .padding(.bottom)
            }.padding(.vertical, 5)
            
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
                                .background(Color.gray.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .background {
                                    RoundedRectangle(cornerRadius: 20).stroke(isSportSelected(sport) ? Color.Brand.secondary : Color.foreground.opacity(0.5), lineWidth: 2)
                                }
                        }
                    }
                }.padding([.top, .horizontal])
            }.padding(.top, -8)
            
            Button(action: { updateUser() }) {
                LoadingButton(text: "done", status: $state)
                    .padding(.top, -8)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    AuthUserSports(currentView: .constant(.sports))
        .environment(SessionStore())
}
