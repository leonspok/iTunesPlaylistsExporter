# iTunesPlaylistsExporter
CLI tool that exports M3U8 playlists from iTunes library

```
OVERVIEW: A utility that exports all playlists in iTunes library as m3u8 files

USAGE: export --library-path <library-path> --output-directory <output-directory> [--create-output-directory] [--use-relative-paths] [--use-music-directory-as-base] [--overwrite]

OPTIONS:
  -l, --library-path <library-path>
                          Path to Library.xml. Use File > Library > Export
                          Library... to generate this file
  -o, --output-directory <output-directory>
                          Path to the output directory
  --create-output-directory
                          Created output directory if needed
  --use-relative-paths    Use relative paths in the generated playlist files
  --use-music-directory-as-base
                          Use iTunes Music directory as base for relative paths
  --overwrite             Overwrite files in the outputdirectory
  -h, --help              Show help information.
```
