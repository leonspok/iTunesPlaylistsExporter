//
//  File.swift
//  
//
//  Created by Igor Savelev on 21.11.2021.
//

import Foundation

public func write(_ playlist: M3UPlaylist, to outputFileURL: URL, overwrite: Bool = false) throws {
    if overwrite {
        try? FileManager.default.removeItem(at: outputFileURL)
    }

    let formattedPlaylist = format(playlist)
    try formattedPlaylist.write(
        to: outputFileURL,
        atomically: true,
        encoding: .utf8
    )
}
