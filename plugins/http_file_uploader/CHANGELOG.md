## [3.1.0] - 2025-07-15

### Added

- Added `streamedRequest` parameter to `HttpChunkedFileHandler` and `HttpRestorableChunkedFileHandler` to allow using `Request` instead of `StreamedRequest`

### Fixed

- Fixed `StreamedRequest` send

### Changed

- chore: setup .github/workflows and update coverage links
- chore: update README.md
- chore: more tests

## [3.0.0] - 2025-07-10

**Breaking**:

- `uploadChunk` now internally uses `StreamedRequest` instead of `MultipartRequest`. The default request `Content-Type` is now `application/octet-stream` instead of `multipart/form-data` (default headers are set before custom ones so they can be overridden).

### Changed

- Update `README.md`

## [2.1.3] - 2024-08-19
 
### Changed

- Update README.md

## [2.1.2] - 2024-08-19

### Added

- More tests, 100% coverage

### Changed

- Update README.md
- Fix linter in `example` project

## [2.1.1] - 2024-06-23

### Changed

- `repository` in `pubspec.yaml`

## [2.1.0] - 2024-06-22

### Added

- Added `fileKey` parameter
- Added `chunkParser`

### Changed

- Update `pubspec.yaml` description
- Apply `file_uploader_socket_interfaces`

## [2.0.1] - 2024-06-19

### Changed

- Updated `README.md`

## [2.0.0] - 2024-06-19

### Changed

- Breaking, move from `File` to `XFile` for web compatibility

## [1.0.1] - 2024-06-04

### Changed

- github project visibility

## [1.0.0] - 2024-06-04

### First release
