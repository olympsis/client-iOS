//
//  ImageProcessors.swift
//  Olympsis
//
//  Created by Joel Joseph on 6/14/24.
//

import Kingfisher
import Foundation

func venueImageProcessor(size: CGSize) -> ImageProcessor {
    return DownsamplingImageProcessor(size: size)
}

func announcementImageProcessor(size: CGSize) -> ImageProcessor {
    return DownsamplingImageProcessor(size: size)
}

func postImageProcessor(size: CGSize) -> ImageProcessor {
    return DownsamplingImageProcessor(size: size)
}

func profileImageProcessor(size: CGSize) -> ImageProcessor {
    return DownsamplingImageProcessor(size: size)
}

func smallProfileImageProcessor(size: CGSize) -> ImageProcessor {
    return DownsamplingImageProcessor(size: size)
}

func groupSmallImageProcessor(size: CGSize) -> ImageProcessor {
    return DownsamplingImageProcessor(size: size)
}

func groupLogoImageProcessor(size: CGSize) -> ImageProcessor {
    return DownsamplingImageProcessor(size: size)
}

func groupBannerImageProcessor(size: CGSize) -> ImageProcessor {
    return DownsamplingImageProcessor(size: size)
}

func postImageNotificationProcessor() -> ImageProcessor {
    DownsamplingImageProcessor(size: CGSize(width: 80, height: 80))
}

func postUserImageNotificationProcessor() -> ImageProcessor {
    DownsamplingImageProcessor(size: CGSize(width: 100, height: 100))
}
