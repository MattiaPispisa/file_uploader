# File uploader

<p align="center">
  <a href="https://github.com/invertase/melos">
    <img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square" alt="Maintained with Melos" />
  </a>
</p>

## Getting Started

This repository is a [Melos](https://melos.invertase.dev) monorepo.

### 1. Install Melos (if needed)

```bash
dart pub global activate melos
```

### 2. Bootstrap all packages

Run the following command from the **repository root**:

```bash
dart run melos bs
```

> `melos bs` runs `pub get` across all packages and links local dependencies together.

---

## Core

- [en_file_uploader](https://github.com/MattiaPispisa/file_uploader/tree/main/en_file_uploader): core library that handle file upload.

## [Plugins](https://github.com/MattiaPispisa/file_uploader/tree/main/plugins)

- [http_file_uploader](https://github.com/MattiaPispisa/file_uploader/tree/main/plugins/http_file_uploader): plugin that handle file upload via `http` package.
- [dio_file_uploader](https://github.com/MattiaPispisa/file_uploader/tree/main/plugins/dio_file_uploader): plugin that handle file upload via `dio` package.

## UI

- [flutter_file_uploader](https://github.com/MattiaPispisa/file_uploader/tree/main/flutter_file_uploader): Flutter widgets that simplify the creation and use of the `en_file_uploader` library

## [Tools](https://github.com/MattiaPispisa/file_uploader/tree/main/tools)

- [file_uploader_socket_interfaces](https://github.com/MattiaPispisa/file_uploader/tree/main/tools/file_uploader_socket_interfaces): common interfaces for plugins that handle file upload via socket
- [file_uploader_utils](https://github.com/MattiaPispisa/file_uploader/tree/main/tools/file_uploader_utils): common test/example utils for file uploader packages
