## [2.2.0] - 2026-05-23

### Added

- Added external model support to `FileUploader`: Introduced the model parameter (accepting a `FileUploaderModel`). This enables external state management to programmatically trigger file additions from outside. 
- Added a constructor `assert` to enforce mutual exclusion. You can now use either the model OR the individual widget properties (such as `onFileAdded`, `limit`, `transformers`, etc.), but not both simultaneously. This prevents state conflicts and ensures a single source of truth.

## [2.1.0] - 2026-05-23

### Added

- `FileUploaderRef` expose the handler original file
- added drag effect to `FileUploader` UI by adding `isDragging` and `dragPosition` parameters

### Changed

- chore: examples are more exhaustive and complete

## [2.0.0] - 2026-05-19

### Added

- Added support to file transformation on `FileUploader`. For more info about `FileTransformer` see [en_file_uploader documentation](https://pub.dev/packages/en_file_uploader)

### Changed

- **Breaking**, updated to reflect the breaking changes introduced in `en_file_uploader`. For the breaking changes, see the [changelog of `en_file_uploader`](https://pub.dev/packages/en_file_uploader/changelog).
- chore: improved examples to show how to use file upload handlers also with transformation.
- chore: significantly improved test suite coverage and overall reliability.

## [1.3.0] - 2024-09-15

### Added

- on `example` project added a global state to change the parameters of `FileUploader`
- added `FileUploader.color`
- added `FileUploaderConsumer`, `FileUploaderSelector` to interact with `FileUploaderModel`

## [1.2.0] - 2024-09-13

### Added

- can hide file uploader button (`FileUploader.hideOnLimit`)
- disable effect on default FileUploader border

### Fix

- fix onTap on limit reached [1](https://github.com/MattiaPispisa/file_uploader/issues/1)

## [1.1.1] - 2024-08-31

### Fixed

- Update `README.md` screenshot references

## [1.1.0] - 2024-08-20

### Added

- test coverage
- `FileUploadControllerProvider.startOnInit`
- deprecated legacy properties of `FileUploaderRef`, added `upload` and `retry` to control a file
  upload
- more documentation
- more examples

### Fix

- Fix remove file uploaded

## [1.0.1] - 2024-06-23

### Changed

- `repository` in `pubspec.yaml`

## [1.0.0] - 2024-06-19

### Changed

- Breaking, update `en_file_uploader` to version `^2.0.0`, replace `File` with `XFile`

## [0.1.0] - 2024-06-18

### First release
