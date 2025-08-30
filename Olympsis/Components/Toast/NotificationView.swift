//
//  NotificationView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/13/25.
//

import SwiftUI

struct NotificationView: View {
    
    var metadata: NotificationMetadata
    let onTap: () -> Void
    let onDismiss: () -> Void
    
    @State private var opacity: Double = 1
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: 60)
//            .padding(.horizontal, 10)
            .foregroundStyle(Color.Background.secondary)
            .overlay {
                Group {
                    switch metadata.type {
                    case .newClubApplication, .clubApplicationUpdate, .clubRankingChange, .clubSuspension, .clubExpulsion, .postApprovalRequest, .postApprovalRequestUpdate:
                        GroupNotificationToast(metadata: metadata)
                    case .newEvent, .eventComment, .eventParticipantUpdate, .eventReminder, .dailyEventSummary, .weeklyEventSummary:
                        EventNotificationToast(metadata: metadata)
                    case .newPost, .postLike, .postComment, .newAnnouncement:
                        PostNotificationToast(metadata: metadata)
                    case .memberReport, .postReport, .postCommentReport:
                        ReportNotificationToast(metadata: metadata)
                    case .directMessage, .groupMessage, .removedFromGroup:
                        MessageNotificationToast(metadata: metadata)
                    }
                }
            }
            .opacity(opacity)
            .offset(dragOffset)
            .onTapGesture {
                onTap()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset.height = min(0, value.translation.height)
                        
                        // Calculate opacity based on drag distance
                        let distance = abs(value.translation.height)
    //                    opacity = max(0, 1-(distance / 100))
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        let shouldDismiss = value.translation.height < -threshold
                        
                        if shouldDismiss {
                            withAnimation(.spring(response: 0.3)) {
                                dragOffset.height = -200
                                opacity = 0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDismiss()
                            }
                        } else {
                            withAnimation(.spring()) {
                                dragOffset = .zero
                                opacity = 1
                            }
                        }
                    }
            )
    }
}

#Preview {
    let metadata = NotificationMetadata(type: .newPost, userID: UUID().uuidString, username: "johndoe", postID: UUID().uuidString, groupName: "SLCFC")
    
    NotificationView(
        metadata: metadata,
        onTap: {},
        onDismiss: {}
    ).padding(.horizontal, 10)
}
