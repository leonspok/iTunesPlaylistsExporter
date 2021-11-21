import Foundation
import ArgumentParser
import iTunesPlaylistsExporter

struct Export: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "A utility that exports all playlists in iTunes library as m3u8 files"
    )

    @Option(name: [.short, .long],
            help: "Path to Library.xml. Use File > Library > Export Library... to generate this file")
    var libraryPath: String

    @Option(name: [.short, .long],
            help: "Path to the output directory")
    var outputDirectory: String

    @Flag(name: [.long],
          help: "Created output directory if needed")
    var createOutputDirectory: Bool = false

    @Flag(name: [.long],
          help: "Use relative paths in the generated playlist files")
    var useRelativePaths: Bool = false

    @Flag(name: [.long],
          help: "Use iTunes Music directory as base for relative paths")
    var useMusicDirectoryAsBase: Bool = false

    @Flag(name: [.long],
          help: "Overwrite files in the outputdirectory")
    var overwrite: Bool = false

    mutating func run() throws {
        var options: ExportOptions = []
        if self.createOutputDirectory {
            options.insert(.createDirectoryIfNeeded)
        }
        if self.useRelativePaths {
            options.insert(.useRelativePaths)
        }
        if self.useMusicDirectoryAsBase {
            options.insert(.useMusicDirectoryAsBase)
        }
        if self.overwrite {
            options.insert(.overwrite)
        }

        let library = try readLibrary(at: self.libraryPath)
        let outputDirectory = URL(fileURLWithPath: self.outputDirectory)
        try exportPlaylists(
            from: library,
            to: outputDirectory,
            options: options
        )
    }
}

Export.main()
