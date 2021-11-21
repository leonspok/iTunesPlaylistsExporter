//
//  File.swift
//  
//
//  Created by Igor Savelev on 21.11.2021.
//

import Foundation

public struct ExportOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let createDirectoryIfNeeded = ExportOptions(rawValue: 1 << 0)
    public static let overwrite = ExportOptions(rawValue: 1 << 1)
    public static let useRelativePaths = ExportOptions(rawValue: 1 << 2)
    public static let useMusicDirectoryAsBase = ExportOptions(rawValue: 1 << 3)
}

public func exportPlaylists(from library: Library,
                            to outputDirectory: URL,
                            options: ExportOptions = []) throws {

    let fileManager = FileManager.default
    if options.contains(.createDirectoryIfNeeded),
       fileManager.fileExists(atPath: outputDirectory.standardizedFileURL.path) == false {
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    try library.playlists.forEach({ playlist in
        try export(playlist, from: library, to: outputDirectory, options: options)
    })
}

public func export(_ playlist: Playlist,
                   from library: Library,
                   to outputDirectory: URL,
                   options: ExportOptions = []) throws {
    let sanitizedFileName = playlist.sanitizedFileName
    let sameNamePlaylistIndex = library.playlists
        .filter {
            $0.sanitizedFileName == sanitizedFileName && $0.id < playlist.id
        }
        .count
    let outputFileName = sanitizedFileName + (sameNamePlaylistIndex != 0 ? "(\(sameNamePlaylistIndex))" : "")
    let outputFileURL = outputDirectory
        .appendingPathComponent(outputFileName)
        .appendingPathExtension("m3u8")

    var m3uPlaylist = M3UPlaylist()
    m3uPlaylist.name = playlist.name
    m3uPlaylist.items = playlist.items.compactMap({ track in
        if options.contains(.useRelativePaths) {
            let baseURL = options.contains(.useMusicDirectoryAsBase) ? library.musicFolderLocation : outputDirectory
            return calculateRelativePath(targetURL: track.location, baseURL: baseURL)
        } else {
            return track.location.standardizedFileURL.path
        }
    })

    try write(m3uPlaylist, to: outputFileURL)
}

private extension Playlist {
    var sanitizedFileName: String {
        if self.name == "." || self.name == ".." {
            return String(self.id)
        } else {
            let fileNameAllowedCharacters = CharacterSet.fileNameAllowed
            return self.name.map { character in
                if character.unicodeScalars.contains(where: { fileNameAllowedCharacters.contains($0) == false }) {
                    return String(character).addingPercentEncoding(withAllowedCharacters: CharacterSet()) ?? "_"
                }
                return String(character)
            }.joined()
        }
    }
}

private extension CharacterSet {
    static var fileNameAllowed: CharacterSet {
        CharacterSet(charactersIn: "\0\n\r\"\\:/*?<>|").inverted
    }
}
