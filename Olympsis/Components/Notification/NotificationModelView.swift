//
//  NotificationView.swift
//  Olympsis
//
//  Created by Joel on 12/24/23.
//

import SwiftUI

struct NotificationModelView: View {
    
    @State var notification: NotificationModel
    
    var body: some View {
        VStack {
            if notification.type == "invitation" {
                if let invitation = notification.invite {
                    InvitationView(invitation: invitation)
                }
            }
        }
    }
}

#Preview {
    NotificationModelView(notification: NotificationModel(id: UUID().uuidString, type: "invitation", invite: INVITATIONS[0], body: ""))
}
