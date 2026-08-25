//
//  EditorGroupViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/22/24.
//

import os
import UIKit
import Foundation

class EditorGroupViewModel: ObservableObject {
    
    @Published var logoPhoto: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.logoPhotoData = self.logoPhoto?.jpegData(compressionQuality: 0.5)
            }
        }
    }
    @Published private var logoPhotoData: Data?
    
    
    @Published var bannerPhoto: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.bannerPhotoData = self.bannerPhoto?.jpegData(compressionQuality: 0.5)
            }
        }
    }
    @Published private var bannerPhotoData: Data?
    
    @Published var logoURL: String = ""
    @Published var bannerURL: String = ""
    
    @Published var groupName: String = ""
    @Published var description: String = ""
    @Published var status: LOADING_STATE = .pending
    
    @Published var selectedTags: Set<String> = []
    @Published var selectedSports: Set<String> = []
    
    private var type: GROUP_TYPE
    
    private var orgObserver = OrgObserver()
    private var clubObserver = ClubObserver()
    private var uploadService = UploadService()
    
    private var log: Logger = Logger(subsystem: "com.olympsis.client", category: "editor_group_view_model")
    
    init(type: GROUP_TYPE) {
        self.type = type
    }
    
    @MainActor
    func uploadClubLogo(_ location: String) async throws {
        if let data = logoPhotoData {
            let id = UUID().uuidString.lowercased()
            guard let resp = await uploadService.UploadImage(location: location, fileName: id, data: data) else {
                return
            }
            if resp.score > 4 {
                throw MediaUploadError.innapropriateContent
            } else {
                logoURL = "club-images/\(id).jpeg"
            }
        }
    }
    
    @MainActor
    func uploadClubBanner(_ location: String) async throws {
        if let data = bannerPhotoData {
            let id = UUID().uuidString.lowercased()
            guard let resp = await uploadService.UploadImage(location: location, fileName: id, data: data) else {
                return
            }
            if resp.score > 4 {
                throw MediaUploadError.innapropriateContent
            } else {
                bannerURL = "club-images/\(id).jpeg"
            }
        }
    }
    
    @MainActor
    func deleteClubLogo(_ location: String, image: String) async {
        _ = await uploadService.DeleteObject(path: "/olympsis-club-images", name: GrabImageIdFromURL(image))
    }
    
    @MainActor
    func deleteClubBanner(_ location: String, image: String) async {
        _ = await uploadService.DeleteObject(path: "/olympsis-club-images", name: GrabImageIdFromURL(image))
    }
    
    @MainActor
    func uploadOrgLogo(_ location: String) async throws {
        if let data = logoPhotoData {
            let id = UUID().uuidString.lowercased()
            guard let resp = await uploadService.UploadImage(location: location, fileName: id, data: data) else {
                return
            }
            if resp.score > 4 {
                throw MediaUploadError.innapropriateContent
            } else {
                logoURL = "org-images/\(id).jpeg"
            }
        }
    }
    
    @MainActor
    func uploadOrgBanner(_ location: String) async throws {
        if let data = bannerPhotoData {
            let id = UUID().uuidString.lowercased()
            guard let resp = await uploadService.UploadImage(location: location, fileName: id, data: data) else {
                return
            }
            if resp.score > 4 {
                throw MediaUploadError.innapropriateContent
            } else {
                bannerURL = "org-images/\(id).jpeg"
            }
        }
    }
    
    @MainActor
    func deleteOrgLogo(_ location: String, image: String) async {
        _ = await uploadService.DeleteObject(path: "/olympsis-org-images", name: GrabImageIdFromURL(image))
    }
    
    @MainActor
    func deleteOrgBanner(_ location: String, image: String) async {
        _ = await uploadService.DeleteObject(path: "/olympsis-org-images", name: GrabImageIdFromURL(image))
    }
    
    @MainActor
    func imagesCleanUp(_ location: String) async {
        switch type {
        case .Club:
            if logoURL != "" {
                await deleteClubLogo(location, image: logoURL)
            }
            
            if bannerURL != "" {
                await deleteClubBanner(location, image: bannerURL)
            }
        case .Organization:
            if logoURL != "" {
                await deleteOrgLogo(location, image: logoURL)
            }
            
            if bannerURL != "" {
                await deleteOrgBanner(location, image: bannerURL)
            }
        }
    }
    
    @MainActor
    func createClubDTO() async -> ClubDao {
        return ClubDao(
            name: groupName,
            logo: logoURL != "" ? logoURL : nil,
            banner: bannerURL != "" ? bannerURL : nil,
            description: description != "" ? description : nil,
            sports: selectedSports.isEmpty ? nil : Array(selectedSports)
        )
    }
    
    @MainActor
    func createOrganizationDTO() async -> OrganizationDao {
        return OrganizationDao(
            name: groupName,
            description: description != "" ? description : nil,
            sports: selectedSports.isEmpty ? nil : Array(selectedSports),
            logo: logoURL != "" ? logoURL : nil,
            banner: bannerURL != "" ? bannerURL : nil
        )
    }
    
    func updateGroup() async {
        
    }
}
