//
//  File.swift
//  
//
//  Created by Guy Cohen on 20/09/2021.
//

import Foundation
import ImageIO
import CoreLocation

public class ExifData {
    
    var imageMetaData = [String: Any]()
    
    public init() { }
    
    public func exifData() -> [String: Any] { imageMetaData }
    
    public func addDescripton(_ description: String) { tiffDictionary[kCGImagePropertyTIFFImageDescription as String] = description }
    
    public func addProjection(_ projection: String) { exifDictionary[Self.kCGImagePropertyProjection as String] = projection }
    
    public func addCreationDate(_ date: Date?) {
        guard let dateStr = getUTCFormattedDate(date) else { return }
        exifDictionary[kCGImagePropertyExifDateTimeOriginal as String] = dateStr
        exifDictionary[kCGImagePropertyExifDateTimeDigitized as String] = dateStr
    }
    
    public func addUserComment(_ comment: String){ exifDictionary[kCGImagePropertyExifUserComment as String] = comment }
    
    public func add(_ currentLocation: CLLocation?) {

        var latitude = currentLocation?.coordinate.latitude ?? 0
        var longitude = currentLocation?.coordinate.longitude ?? 0

        var latitudeRef: String? = nil
        var longitudeRef: String? = nil

        if latitude < 0.0 {
            latitude *= CLLocationDegrees(-1)
            latitudeRef = "S"
        } else {
            latitudeRef = "N"
        }

        if longitude < 0.0 {
            longitude *= CLLocationDegrees(-1)
            longitudeRef = "W"
        } else {
            longitudeRef = "E"
        }

        gpsDictionary[kCGImagePropertyGPSTimeStamp as String] = getUTCFormattedDate(currentLocation?.timestamp)

        gpsDictionary[kCGImagePropertyGPSLatitudeRef as String] = latitudeRef ?? ""
        gpsDictionary[kCGImagePropertyGPSLatitude as String] = NSNumber(value: Float(latitude))

        gpsDictionary[kCGImagePropertyGPSLongitudeRef as String] = longitudeRef ?? ""
        gpsDictionary[kCGImagePropertyGPSLongitude as String] = NSNumber(value: Float(longitude))

        gpsDictionary[kCGImagePropertyGPSDOP as String] = NSNumber(value: Float(currentLocation?.horizontalAccuracy ?? 0.0))
        gpsDictionary[kCGImagePropertyGPSAltitude as String] = NSNumber(value: Float(currentLocation?.altitude ?? 0.0))
    }
    
}

fileprivate extension ExifData {
    
    func dictionaryForKey(key: String) -> [String: Any] {
        if let existedDict = imageMetaData[key] as? [String: Any] {
            return existedDict
        }
        let dic =  [String: Any]()
        imageMetaData[key] = dic
        return dic
    }
    
    func getUTCFormattedDate(_ localDate: Date?) -> String? {
        if let localDate = localDate {
            return Self.getUTCDateFormatter?.string(from: localDate)
        }
        return nil
    }
    
    var exifDictionary: [AnyHashable : Any] {
        get {
            if let existedDict = imageMetaData[kCGImagePropertyExifDictionary as String] as? [String: Any] {
                return existedDict
            }
            let dic =  [String: Any]()
            imageMetaData[kCGImagePropertyExifDictionary as String] = dic
            return dic
        }
        set { imageMetaData[kCGImagePropertyExifDictionary as String] = newValue }
    }
    
    var tiffDictionary: [AnyHashable : Any] {
        get {
            if let existedDict = imageMetaData[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
                return existedDict
            }
            let dic =  [String: Any]()
            imageMetaData[kCGImagePropertyTIFFDictionary as String] = dic
            return dic
        }
        set { imageMetaData[kCGImagePropertyTIFFDictionary as String] = newValue }
    }
    
    var gpsDictionary: [AnyHashable : Any] {
        get {
            if let existedDict = imageMetaData[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
                return existedDict
            }
            let dic =  [String: Any]()
            imageMetaData[kCGImagePropertyGPSDictionary as String] = dic
            return dic
        }
        set { imageMetaData[kCGImagePropertyGPSDictionary as String] = newValue }
    }
    
    static let getUTCDateFormatter: DateFormatter? = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return dateFormatter
    }()
    
    static let kCGImagePropertyProjection = "ProjectionType"
    
}
