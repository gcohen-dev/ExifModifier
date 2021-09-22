//
//  File.swift
//  
//
//  Created by Guy Cohen on 20/09/2021.
//

import UIKit

public extension UIImage {

    func addExif(_ container: ExifData) -> Data? {

        let imageData = self.jpegData(compressionQuality: 1.0)

        // create an imagesourceref
        var source: CGImageSource? = nil
        if let data = imageData as CFData? {
            source = CGImageSourceCreateWithData(data, nil)
        }

        // this is the type of image (e.g., public.jpeg)
        var UTI: CFString? = nil
        if let source = source {
            UTI = CGImageSourceGetType(source)
        }

        // create a new data object and write the new image into it
        let dest_data = Data()
        var destination: CGImageDestination? = nil
        if let UTI = UTI {
            destination = CGImageDestinationCreateWithData(dest_data as! CFMutableData, UTI, 1, nil)
        }

        if destination == nil {
            print("Error: Could not create image destination")
        }

        // add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
        if let destination = destination, let source = source {
            CGImageDestinationAddImageFromSource(destination, source, 0, container.exifData as! CFDictionary?)
        }
        var success = false
        if let destination = destination {
            success = CGImageDestinationFinalize(destination)
        }

        if !success {
            print("Error: Could not create data from image destination")
        }


        return dest_data
    }

}
