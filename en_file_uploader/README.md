# File Uploader

This Dart package provides a **file upload functionality that is implementation-agnostic**.

## Features

This library provides the capability to:

- ☑ upload a complete file;
- ☑ upload a file in chunks;
- ☑ upload a file in chunks with the ability to pause and resume the upload from where it left off (restorable chunks file upload).

File uploader can be used with various libraries for making HTTP requests, such as http, dio, or others, offering a consistent and straightforward interface for uploading files without needing to change the code based on the underlying library used.

## [Plugins](https://github.com/MattiaPispisa/file_uploader/tree/main/plugins)

- [http_file_uploader](https://github.com/MattiaPispisa/file_uploader/tree/main/plugins/http_file_uploader) This plugin allows you to implement file uploads using the http library.

## Extensions

If a plugin is not yet available or the existing plugins do not meet your needs, you can create your own implementation of file upload.

## File Uploader APIs

### Upload implementations

It is possible to extend:

- `FileUploadHandler` to implement the upload of an entire file;
- `ChunkedFileUploadHandler` to implement chunked file upload;
- `RestorableChunkedFileUploadHandler` to implement a restorable chunked upload.

**The plugins already do this, so before creating your own implementation, check if a plugin already meets your needs.**

### Support restorable chunked file upload

To implement a restorable file server, the following functionalities need to be supported:

- An API to present the file; before uploading the chunks, the file is presented and needs an id. This id will be used as a reference for chunk uploads;
- An API that, given the presentation id, allows requesting the file's state. The file's state will return the offset of the next chunk to be sent. This is needed to support retrying from the last unsent chunk.

### Configuration

A global configuration is available to set default values for the entire system.

Currently, it is possible to set a default chunk size.

```dart
setDefaultChunkSize(1024)
```

### Logger

It is possible to implement the `FileUploaderLogger` class to manage the logs generated by the library.

```dart
// It's just an example, not a production-ready version.
// Every log is printed
class PrinterLogger implements FileUploaderLogger {
  @override
  void error(String message, error, stackTrace) {
    print(error);
  }

  @override
  void info(String message) {
    print(message);
  }

  @override
  void warning(String message) {
    print(message);
  }
}
```

## How to use

Create a `FileUploadController` by passing a concrete implementation of `FileUploadHandler`, `ChunkedFileUploadHandler`, or `RestorableChunkedFileUploadHandler` as the handler. The controller will have the capabilities to upload a file and retry the upload.

## Example

In the [example](https://github.com/MattiaPispisa/file_uploader/blob/main/file_uploader/example/lib/main.dart), there is an implementation of `RestorableChunkedFileUploadHandler` handler that sends chunks to a mock server (`InMemoryBackend`).

Other examples are provided in the tests to ensure the correct functionality of the library.

## Next features

- [] more logs
- [] dio plugin
- [] flutter widgets to handle the file upload ui