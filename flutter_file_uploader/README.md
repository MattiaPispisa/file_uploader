# Flutter File Uploader

## Features

**This package use [en_file_uploader](https://pub.dev/packages/en_file_uploader) and provides widgets for displaying and managing file uploads.**

`FileUploader` is a widget that encapsulates the logic for adding and removing files to be uploaded. Each file can have its own `IFileUploadHandler` for customized uploads.

`FileCard` is a file upload widget agnostic of `en_file_uploader`, while `FileUploadControllerProvider` is a provider that encapsulates the business logic for uploading a file. `ProvidedFileCard` combines `FileCard` with `FileUploadControllerProvider`.

## Usage

```dart
FileUploader(
    builder: (context, ref) {
        // for each file a ref is created using the provided `IFileUploadHandler`.
        // Here, a widget for managing file uploads should be inserted.
        // ProvidedFileCard automatically provides complete file management and allows for graphical customization.
        // To manage the upload while creating your own widget, use only FileUploadControllerProvider. For just the UI, use FileCard.
        return ProvidedFileCard(
            ref: ref,
            content: Text("filename"),
        );
    },
    onPressedAddFiles: () async {
        // on tap add a list of files
    },
    onFileAdded: (file) async {
        // for each file added create a custom `IFileUploadHandler`
    },
    onFileUploaded: (file) {
        print("file uploaded ${file.id}");
    },
    onFileRemoved: (file) {
        print("file removed ${file.id}");
    },
    placeholder: Text("add a file"),
),
```

## Widgets

### FileUploader

`FileUploader` is a widget that encapsulates the logic for adding and removing files to be uploaded. Each file can have its own `IFileUploadHandler` for customized uploads.

### Providers

Widgets that use the [provider](https://pub.dev/packages/provider) library to insert and consume `FileUploadControllerModel`.

- `FileUploadControllerProvider`: `ChangeNotifierProvider` with `FileUploadControllerModel`
- `FileUploadControllerSelector`: `Selector` with `FileUploadControllerModel`
- `FileUploadControllerConsumer`: `Consumer` with `FileUploadControllerModel`

### FileCard

A card that displays the progress of a file upload.

### ProvidedFileCard

`FileCard` + `FileUploadControllerProvider` + `FileUploadControllerConsumer`

## Screenshot

![image](./screenshot/screenshot.jpg)
![video](./screenshot/video.gif)
