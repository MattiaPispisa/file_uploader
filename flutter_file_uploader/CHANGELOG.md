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
