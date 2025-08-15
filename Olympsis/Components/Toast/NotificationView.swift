//
//  NotificationView.swift
//  Olympsis
//
//  Created by Joel Joseph on 8/13/25.
//

import SwiftUI

struct NotificationView: View {
    var metadata: NotificationMetadata
    var body: some View {
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

#Preview {
    let metadata = NotificationMetadata(type: .newPost, userID: UUID().uuidString, username: "johndoe", postID: UUID().uuidString, groupName: "SLCFC")
    NotificationView(metadata: metadata)
}
