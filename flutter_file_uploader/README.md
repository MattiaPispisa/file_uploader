# Flutter File Uploader

[![Pub Version][pub_badge]][pub_link]
[![pub points][pub_points]][pub_link]
[![pub likes][pub_likes]][pub_link]
[![codecov][codecov_badge]][codecov_link]
[![ci_badge][ci_badge]][ci_link]
[![License: MIT][license_badge]][license_link]
[![pub publisher][pub_publisher]][pub_publisher_link]

## Features

**This package use [en_file_uploader](https://pub.dev/packages/en_file_uploader) and provides
widgets for displaying and managing file uploads.**

`FileUploader` is a widget that encapsulates the logic for adding and removing files to be uploaded.
Each file can have its own `IFileUploadHandler` for customized uploads (More info about
handlers [here](https://pub.dev/packages/en_file_uploader)).

`FileCard` is a file upload widget agnostic of `en_file_uploader`,
while `FileUploadControllerProvider` is a provider that encapsulates the business logic for
uploading a file: status (loading,done,...), progress.

`ProvidedFileCard` combines `FileCard` with `FileUploadControllerProvider`.

## Usage

If you want to focus solely on UI details, you can use `FileUploader` and `ProvidedFileCard`.

`FileUploader` handles the logic for adding and removing files to be uploaded.
`ProvidedFileCard` displays the `FileCard` widget and manages the actions related to uploading,
retrying, and removing individual files.

```dart
FileUploader(
    transformers: [
        // Optionally provide a list of FileTransformer to apply transformations
        // (e.g., image compression, resizing) to files before uploading.
        MyTransformer(),
    ],
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
);
```

---

Alternatively, in the [FileUploader.builder] callback you can create your custom widget using the
ref parameter to manage uploading, retrying, and removing files. You can use `FileCard` as the base
widget for displaying file upload details.

```dart
FileUploader(
    transformers: [
        // Optionally provide a list of FileTransformer to apply transformations
        // (e.g., image compression, resizing) to files before uploading.
        MyTransformer(),
    ],
    builder: (context, ref) {
    // for each file a ref is created using the provided `IFileUploadHandler`.
    // Here, a widget for managing file uploads should be inserted.

    return MyCustomFileCard(
        ref: ref,
    );
    },
    onPressedAddFiles: () async {
    // on tap add a list of files
    },
    onFileAdded: (file) async {
    // for each file added create a custom `IFileUploadHandler`
    // More info about handlers on [en_file_uploader](https://pub.dev/packages/en_file_uploader)
    },
    onFileUploaded: (file) {
    print("file uploaded ${file.id}");
    },
    onFileRemoved: (file) {
    print("file removed ${file.id}");
    },
    placeholder: Text("add a file"),
);
```

## Examples

In the [example](./example/) project, you can see some uses of `en_file_uploader`
and `flutter_file_uploader`.

---

In the [handlers](./example/lib/handlers/) folder, there are some `IFileUploadHandler` for
simulating file uploads.

In the [examples](./example/lib/examples/) folder, you can find practical uses:

- **default**: The simplest case that uses `FileUploader` and `ProvidedFileCard`;
- **default_restorable_chunked**: Same as **default** but using a restorable chunked handler
  (`InMemoryRestorableChunkedFileUploadHandler`). If the upload is interrupted, it resumes
  automatically from the last successfully uploaded chunk;
- **self_ref_management**: Shows how to build a fully custom file card that manages its own upload
  state using `FileUploaderRef`, without relying on `ProvidedFileCard`;
- **transformers**: Demonstrates how to apply a sequential pipeline of `FileTransformer`s to each
  file before it is uploaded;
- **complete**: A full-featured demo combining file-system picker, drag-and-drop, image resizing
  transformer, and a custom card showing both transformation and upload progress in real time.

## Running the example

### 1. Bootstrap the workspace

This project uses [Melos](https://melos.invertase.dev) to manage the monorepo.
If you don't have it installed yet:

```bash
dart pub global activate melos
```

Then bootstrap all packages from the **repository root**:

```bash
dart run melos bs
```

> `melos bs` runs `pub get` across all packages and links local dependencies together.

### 2. Run the app

**VS Code (recommended)**

The repository ships with a pre-configured launch configuration.
Open the project in VS Code, go to **Run and Debug** (`⇧⌘D`), select **`flutter_file_uploader_example`** and press **▶ Start Debugging**.

**Command line**

```bash
cd flutter_file_uploader/example
flutter run
```

---

## Widgets

### FileUploader

`FileUploader` is a widget that encapsulates the logic for adding and removing files to be uploaded.
Each file can have its own `IFileUploadHandler` for customized uploads.

Thanks to the integration with the latest versions of `en_file_uploader`, you can also pass a list of `FileTransformer` to the `FileUploader`. The provided transformers will be applied to each selected file before the upload begins, and the UI (`FileCard`) will automatically show a progress indicator for the transformation phase. You can check out [image_pipeline](https://pub.dev/packages/image_pipeline) for ready-to-use image transformers.

### Providers

Widgets that use the [provider](https://pub.dev/packages/provider) library to insert and
consume `FileUploadControllerModel`.

- `FileUploadControllerProvider`: `ChangeNotifierProvider` with `FileUploadControllerModel`
- `FileUploadControllerSelector`: `Selector` with `FileUploadControllerModel`
- `FileUploadControllerConsumer`: `Consumer` with `FileUploadControllerModel`

### FileCard

A card that displays the progress of a file upload.

### ProvidedFileCard

`FileCard` + `FileUploadControllerProvider` + `FileUploadControllerConsumer`

## Screenshot

|                                                                                                                                                              |                                                                                                                                                             |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <img width="300" alt="image" src="https://raw.githubusercontent.com/MattiaPispisa/file_uploader/main/flutter_file_uploader/assets/show_case/complete.gif" /> | <img width="300" alt="video" src="https://raw.githubusercontent.com/MattiaPispisa/file_uploader/main/flutter_file_uploader/assets/show_case/default.gif" /> |

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[pub_likes]: https://img.shields.io/pub/likes/flutter_file_uploader
[pub_link]: https://pub.dev/packages/flutter_file_uploader
[pub_badge]: https://img.shields.io/pub/v/flutter_file_uploader
[codecov_badge]: https://img.shields.io/codecov/c/github/MattiaPispisa/file_uploader/main?flag=flutter_file_uploader&logo=codecov
[codecov_link]: https://app.codecov.io/gh/MattiaPispisa/file_uploader/tree/main/flutter_file_uploader
[ci_badge]: https://img.shields.io/github/actions/workflow/status/MattiaPispisa/file_uploader/main.yaml
[ci_link]: https://github.com/MattiaPispisa/file_uploader/actions/workflows/main.yaml
[pub_points]: https://img.shields.io/pub/points/flutter_file_uploader
[pub_publisher]: https://img.shields.io/pub/publisher/flutter_file_uploader
[pub_publisher_link]: https://pub.dev/packages?q=publisher%3Amattiapispisa.it
