//
//  UIImage+Resize.swift
//  Grocery List
//
//  Created by Joe Benton on 06/07/2020.
//  Copyright © 2020 Joe Benton. All rights reserved.
//

import UIKit

func cropSquareImageAndResize(image: UIImage, size: CGSize) -> UIImage {
    let croppedSquareImage = cropSquareImage(image: image)
    return resizeImage(image: croppedSquareImage, targetSize: size)
}

func cropSquareImage(image: UIImage) -> UIImage {
    let imageSize = image.size
    let cgimage = image.cgImage!
    let contextImage: UIImage = UIImage(cgImage: cgimage)
    let contextSize: CGSize = contextImage.size
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat = imageSize.width
    var cgheight: CGFloat = imageSize.height

    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }

    let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

    let imageRef: CGImage = cgimage.cropping(to: rect)!

    let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

    return image
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size

    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height

    let newSize: CGSize
    if widthRatio > heightRatio {
        newSize = CGSize(width: floor(size.width * heightRatio), height: floor(size.height * heightRatio))
    } else {
        newSize = CGSize(width: floor(size.width * widthRatio), height: floor(size.height * widthRatio))
    }

    let rect = CGRect(origin: .zero, size: newSize)

    let format = UIGraphicsImageRendererFormat()
    format.scale = image.scale
    format.opaque = true
    let newImage = UIGraphicsImageRenderer(bounds: rect, format: format).image() { _ in
        image.draw(in: rect)
    }
    
    return newImage
}
