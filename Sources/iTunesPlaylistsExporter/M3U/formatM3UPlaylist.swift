//
//  File.swift
//  
//
//  Created by Igor Savelev on 21.11.2021.
//

import Foundation

public func format(_ playlist: M3UPlaylist) -> String {
    var output = "#EXTM3U\n"

    if let name = playlist.name {
        let sanitizedName = name
            .replacingOccurrences(of: "\n", with: " ")
        output += "#PLAYLIST:\(sanitizedName)\n"
    }

    playlist.items.forEach { item in
        output += item
        output += "\n"
    }

    return output
}
