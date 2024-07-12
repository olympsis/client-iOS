//
//  EditorClubViewModel.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/22/24.
//

import os
import UIKit
import Foundation

class EditorClubViewModel: ObservableObject {
    
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
    
    @Published var clubName: String = ""
    @Published var description: String = ""
    @Published var status: LOADING_STATE = .pending
    
    @Published var selectedTags: Set<String> = []
    @Published var selectedSports: Set<String> = []
    
    private var club: Club
    private var clubObserver = ClubObserver()
    private var uploadObserver = UploadObserver()
    
    private var log: Logger = Logger(subsystem: "com.olympsis.client", category: "editor_group_view_model")
    
    init(club: Club) {
        self.club = club
    }
    
    @MainActor
    func uploadLogo() async throws {
        if let data = logoPhotoData {
            let id = UUID().uuidString.lowercased()
            guard let resp = await uploadObserver.UploadImage(location: "/olympsis-club-images", fileName: id, data: data) else {
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
    func uploadBanner() async throws {
        if let data = bannerPhotoData {
            let id = UUID().uuidString.lowercased()
            guard let resp = await uploadObserver.UploadImage(location: "/olympsis-club-images", fileName: id, data: data) else {
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
    func deleteImage(image: String) async {
        _ = await uploadObserver.DeleteObject(path: "/olympsis-club-images", name: GrabImageIdFromURL(image))
    }
    
    @MainActor
    func imagesCleanUp() async {
        if logoURL != "" {
            await deleteImage(image: logoURL)
        }
        
        if bannerURL != "" {
            await deleteImage(image: bannerURL)
        }
    }
    
    func createClubDTO() -> ClubDao {
        return ClubDao(
            name: clubName,
            logo: logoURL != "" ? logoURL : nil,
            banner: bannerURL != "" ? bannerURL : nil,
            description: description != "" ? description : nil,
            sports: selectedSports.isEmpty ? nil : Array(selectedSports),
            tags: selectedTags.isEmpty ? nil : Array(selectedTags)
        )
    }
    
    @MainActor
    func updateClub() async {
        status = .loading
        
        do {
            try await uploadLogo()
            try await uploadBanner()
        } catch {
            log.error("Failed to upload club images: \(error.localizedDescription)")
        }
        
        let dto = createClubDTO()
        
        let resp = await clubObserver.updateClub(id: club.id, dto: dto)
        guard resp else {
            status = .failure
            return
        }
        
        club.name = clubName
        if logoURL != "" {
            club.logo = logoURL
        }
        if bannerURL != "" {
            club.banner = bannerURL
        }
        if description != "" {
            club.description = description
        }
        if !selectedSports.isEmpty {
            club.sports = Array(selectedSports)
        }
        if !selectedTags.isEmpty {
            club.tags = Array(selectedTags)
        }
        
        status = .success
    }
}

