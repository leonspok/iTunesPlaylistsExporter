//
//  File.swift
//  
//
//  Created by Igor Savelev on 21.11.2021.
//

import Foundation

public struct Parameters {
    public var basePath: String?
    public var pathToPrepend: String?
    public var options: ExportOptions

    public init(basePath: String? = nil,
                pathToPrepend: String? = nil,
                options: ExportOptions = []) {
        self.basePath = basePath
        self.pathToPrepend = pathToPrepend
        self.options = options
    }
}

public struct ExportOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let createDirectoryIfNeeded = ExportOptions(rawValue: 1 << 0)
    public static let overwrite = ExportOptions(rawValue: 1 << 1)
    public static let useRelativePaths = ExportOptions(rawValue: 1 << 2)
}

public func exportPlaylists(from library: Library,
                            to outputDirectory: URL,
                            options: ExportOptions = []) throws {
    try exportPlaylists(from: library, to: outputDirectory, parameters: Parameters(options: options))
}

public func exportPlaylists(from library: Library,
                            to outputDirectory: URL,
                            parameters: Parameters) throws {

    let fileManager = FileManager.default
    if parameters.options.contains(.createDirectoryIfNeeded),
       fileManager.fileExists(atPath: outputDirectory.standardizedFileURL.path) == false {
        try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    try library.playlists.forEach({ playlist in
        try export(playlist, from: library, to: outputDirectory, parameters: parameters)
    })
}

public func export(_ playlist: Playlist,
                   from library: Library,
                   to outputDirectory: URL,
                   parameters: Parameters) throws {
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
        if parameters.options.contains(.useRelativePaths) {
            let baseURL = parameters.basePath.flatMap(URL.init(fileURLWithPath:)) ?? outputDirectory
            let relativePath = calculateRelativePath(targetURL: track.location, baseURL: baseURL)
            if let pathToPrepend = parameters.pathToPrepend {
                return pathToPrepend + relativePath
            } else {
                return relativePath
            }
        } else {
            return (track.location.canonical ?? track.location.standardizedFileURL).path
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
