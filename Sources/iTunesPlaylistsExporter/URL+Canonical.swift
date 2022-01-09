//
//  File.swift
//  
//
//  Created by Igor Savelev on 09/01/2022.
//

import Foundation

extension URL {
    // Returns absolute URL with correct case even if `self` has incorrect case somewhere
    var canonical: URL? {
        if #available(macOS 10.12, *) {
            guard let values = try? self.resourceValues(forKeys: [.canonicalPathKey]),
                  let canonicalPath = values.canonicalPath else {
                return nil
            }
            return URL(fileURLWithPath: canonicalPath)
        }
        return nil
    }
}
