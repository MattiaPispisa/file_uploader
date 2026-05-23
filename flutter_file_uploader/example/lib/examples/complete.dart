import 'dart:io';

import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader_example/common/banner.dart';
import 'package:flutter_file_uploader_example/common/view_layout.dart';
import 'package:flutter_file_uploader_example/handlers/handlers.dart';
import 'package:flutter_file_uploader_example/l10n/l10n.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

/// [FileUploader] with transformers, custom card, image pickers and drag and drop zone.
class CompleteUploadExample extends StatefulWidget {
  const CompleteUploadExample({super.key});

  @override
  State<CompleteUploadExample> createState() => _CompleteUploadExampleState();
}

class _CompleteUploadExampleState extends State<CompleteUploadExample> {
  bool _dragActive = false;
  Offset? _cursorOffset;

  late FileUploaderModel model;

  initState() {
    super.initState();
    model = FileUploaderModel(
      logger: utils.fileUploaderLogger,
      transformers: [
        utils.FileImageTransformer(),
      ],
      onPressedAddFiles: _pickFiles,
      onFileAdded: _onFileAdded,
      onFileUploaded: (file) {
        utils.logger.info("file uploaded ${file.id}");
      },
      onFileRemoved: (file) {
        utils.logger.info("file removed ${file.id}");
      },
    );
  }

  Future<List<XFile>> _pickFiles() async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.any,
      withData: true,
    );
    if (result == null) {
      return [];
    }

    return result.xFiles;
  }

  Future<IFileUploadHandler> _onFileAdded(XFile file) async {
    return FakeFileHandler(file: file);
  }

  @override
  Widget build(BuildContext context) {
    return ViewLayout(
      title: context.t().completeTitle.toUpperCase(),
      childrenBuilder: (settings) {
        return [
          ExampleBanner(
            title: context.t().completeTitle,
            description: context.t().completeBannerDescription,
          ),
          Center(
            child: DropRegion(
              formats: Formats.standardFormats,
              onDropEnter: (_) => setState(() => _dragActive = true),
              onDropLeave: (_) => setState(() => _dragActive = false),
              onDropOver: (event) {
                setState(() {
                  _cursorOffset = event.position.local;
                });
                return DropOperation.copy;
              },
              onPerformDrop: (event) async {
                model.addFiles([utils.createFile()]);

                setState(() {
                  _dragActive = false;
                  _cursorOffset = null;
                });
              },
              child: FileUploader(
                model: model,
                limit: settings.limit,
                hideOnLimit: settings.hideOnLimit,
                color: settings.color,
                loadingColor: settings.color,
                isDragging: _dragActive,
                dragPosition: _cursorOffset,
                builder: (context, ref) {
                  return ProvidedFileCard(
                    ref: ref,
                    content: _Content(
                      file: ref.originalFile,
                    ),
                    uploadProgressColor: settings.color,
                    transformationProgressColor: settings.color,
                  );
                },
                placeholder: Text(context.t().addFilePlaceholder),
              ),
            ),
          ),
        ];
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.file,
    super.key,
  });

  final XFile file;

  bool get _isImage {
    final ext = file.name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  String get _extension {
    if (!file.name.contains('.')) return '?';
    final ext = file.name.split('.').last.toUpperCase();
    return ext.length > 4 ? ext.substring(0, 4) : ext;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: _isImage
              ? _buildImagePreview()
              : Center(
                  child: Text(
                    _extension,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (kIsWeb) {
      return Image.network(
        file.path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
      );
    }
    return Image.file(
      File(file.path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() {
    return const Center(
      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
  }
}
