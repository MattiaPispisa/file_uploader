## [3.1.0] - 2026-05-23

### Added

- `FileUploadController` expose the file

### Changed

- chore: more logs during transformations

## [3.0.0] - 2026-05-19

### Added

- Added support for file transformations before upload. It is now possible to provide a list of `FileTransformer`s that will process the file sequentially, in order. A new `onTransformationProgress` callback has been added to track the progress of file transformations.

### Changed

- `file` in `FileUploadHandler` has been deprecated in favor of `originalFile`, which more clearly indicates that it refers to the unmodified file before transformations.
- **Breaking**, `FileUploadHandler.upload` and `RestorableChunkedFileUploadHandler.present` now receive the transformed file as input.

## [2.1.2] - 2025-07-24

### Changed

- chore: Update README.md and added more documentation.

## [2.1.1] - 2025-07-15

### Changed

- chore: setup .github/workflows and update coverage links
- chore: update README.md
- chore: more tests

### Fixed

- fix `count` in `onProgress` callback

## [2.1.0] - 2025-07-11

### Added

- Added logs on errors.

### Changed

- Improved logs messages to be more descriptive.

## [2.0.3] - 2024-08-11

### Added

- Coverage

### Fixed

- callback `onProgress` in `retry` with `RestorableChunkedFileUploadHandler` didn't send count
  correctly

## [2.0.2] - 2024-06-22

### Changed

- `repository` in `pubspec.yaml`

## [2.0.1] - 2024-06-22

### Changed

- Update `README.md` references

## [2.0.0] - 2024-06-19

### Changed

- **Breaking**, move from `File` to `XFile` for web compatibility
- Update changelog references

## [1.1.1] - 2024-06-18

### Changed

- link to `flutter_file_uploader`

## [1.1.0] - 2024-06-17

### Added

- `uploaded`: FileUploadController indicates if the file has already been uploaded.

## [1.0.1] - 2024-06-04

### Changed

- github project visibility

## [1.0.0] - 2024-06-04

### First release
