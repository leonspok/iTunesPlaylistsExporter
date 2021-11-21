//
//  File.swift
//  
//
//  Created by Igor Savelev on 21.11.2021.
//

import Foundation

enum ReadError: Error {
    case canNotDecodeLibraryXML
    case invalidMusicFolderLocation
    case noPlaylists
    case noTracks
    case trackNotFound(trackId: Int)
}

public func readLibrary(at path: String) throws -> Library {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
        throw ReadError.canNotDecodeLibraryXML
    }
    return try readLibrary(from: plist)
}

private func readLibrary(from libraryPlist: [String: Any]) throws -> Library {
    struct LibraryKeys {
        static let musicFolder = "Music Folder"
        static let playlists = "Playlists"
        static let tracks = "Tracks"
    }

    struct PlaylistKeys {
        static let id = "Playlist ID"
        static let name = "Name"
        static let description = "Description"
        static let items = "Playlist Items"
    }

    struct PlaylistItemKeys {
        static let trackId = "Track ID"
    }

    struct TrackKeys {
        static let id = "Track ID"
        static let location = "Location"
    }

    guard let musicFolderLocationString = libraryPlist[LibraryKeys.musicFolder] as? String,
          let musicFolderLocation = URL(string: musicFolderLocationString) else {
        throw ReadError.invalidMusicFolderLocation
    }

    guard let playlistsPlist = libraryPlist[LibraryKeys.playlists] as? [[String: Any]] else {
        throw ReadError.noPlaylists
    }

    guard let tracksPlist = libraryPlist[LibraryKeys.tracks] as? [String: [String: Any]] else {
        throw ReadError.noTracks
    }

    var unknownPlaylistsCount = 0
    let playlists: [Playlist] = try playlistsPlist.compactMap { playlistPlist in
        guard let id = playlistPlist[PlaylistKeys.id] as? Int else {
            return nil
        }
        let name: String = {
            if let name = playlistPlist[PlaylistKeys.name] as? String {
                return name
            } else {
                defer {
                    unknownPlaylistsCount += 1
                }
                return "Unknown playlist \(unknownPlaylistsCount)"
            }
        }()
        let playlistItemsPlist: [[String: Int]] = playlistPlist[PlaylistKeys.items] as? [[String: Int]] ?? []
        let items: [Track] = try playlistItemsPlist.compactMap { itemPlist in
            guard let trackId = itemPlist[PlaylistItemKeys.trackId] else {
                return nil
            }
            guard let trackPlist = tracksPlist[String(trackId)] else {
                throw ReadError.trackNotFound(trackId: trackId)
            }
            guard let id = trackPlist[TrackKeys.id] as? Int,
                  let locationString = trackPlist[TrackKeys.location] as? String,
                  let location = URL(string: locationString) else {
                return nil
            }
            return Track(id: id, location: location)
        }

        return Playlist(
            id: id,
            name: name,
            items: items
        )
    }

    return Library(
        musicFolderLocation: musicFolderLocation,
        playlists: playlists
    )
}
