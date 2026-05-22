import 'package:en_file_uploader/en_file_uploader.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader_example/common/banner.dart';
import 'package:flutter_file_uploader_example/common/view_layout.dart';
import 'package:flutter_file_uploader_example/handlers/handlers.dart';
import 'package:flutter_file_uploader_example/l10n/l10n.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class CompleteUploadExample extends StatefulWidget {
  const CompleteUploadExample({super.key});

  @override
  State<CompleteUploadExample> createState() => _CompleteUploadExampleState();
}

class _CompleteUploadExampleState extends State<CompleteUploadExample> {
  bool _dragActive = false;
  Offset? _cursorOffset;

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
      title: context.t().imagePickerTitle.toUpperCase(),
      childrenBuilder: (settings) {
        return [
          ExampleBanner(
            title: context.t().imagePickerBannerTitle,
            description: context.t().imagePickerBannerDescription,
          ),
          Center(
            child: DropRegion(
              formats: Formats.standardFormats,
              onDropEnter: (_) => setState(() => _dragActive = true),
              onDropLeave: (_) => setState(() => _dragActive = false),

              // NUOVO: Aggiorna la posizione del cursore durante il trascinamento
              onDropOver: (event) {
                setState(() {
                  _cursorOffset = event.position.local;
                });
                return DropOperation.copy;
              },
              onPerformDrop: (event) async {
                setState(() {
                  _dragActive = false;
                  _cursorOffset = null;
                });
              },
              child: FileUploader(
                logger: utils.fileUploaderLogger,
                limit: settings.limit,
                hideOnLimit: settings.hideOnLimit,
                color: settings.color,
                loadingColor: settings.color,
                isDragging: _dragActive,
                dragPosition: _cursorOffset,
                transformers: [
                  utils.FileImageTransformer(),
                ],
                builder: (context, ref) {
                  return ProvidedFileCard(
                    ref: ref,
                    content: Text(context.t().filenamePlaceholder),
                    uploadProgressColor: settings.color,
                    transformationProgressColor: settings.color,
                  );
                },
                onPressedAddFiles: _pickFiles,
                onFileAdded: _onFileAdded,
                onFileUploaded: (file) {
                  utils.logger.info("file uploaded ${file.id}");
                },
                onFileRemoved: (file) {
                  utils.logger.info("file removed ${file.id}");
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
