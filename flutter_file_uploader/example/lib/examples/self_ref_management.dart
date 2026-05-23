import 'package:file_uploader_utils/file_uploader_utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_file_uploader_example/common/banner.dart';
import 'package:flutter_file_uploader_example/common/view_layout.dart';
import 'package:flutter_file_uploader_example/handlers/handlers.dart';
import 'package:flutter_file_uploader_example/l10n/l10n.dart';

/// [FileUploader] with custom card for self ref management.
class SelfRefManagementFilesUpload extends StatelessWidget {
  const SelfRefManagementFilesUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewLayout(
      title: context.t().selfRefTitle.toUpperCase(),
      childrenBuilder: (settings) {
        return [
          ExampleBanner(
            title: context.t().selfRefBannerTitle,
            description: context.t().selfRefBannerDescription,
          ),
          Center(
            child: FileUploader(
              logger: utils.fileUploaderLogger,
              limit: settings.limit,
              hideOnLimit: settings.hideOnLimit,
              color: settings.color,
              builder: (context, ref) {
                return CustomFileCardSelfManagement(
                  ref: ref,
                );
              },
              onPressedAddFiles: () async {
                await Future.delayed(const Duration(seconds: 1));
                return [utils.createFile()];
              },
              onFileAdded: (file) async {
                await Future.delayed(const Duration(milliseconds: 500));
                return FakeFileHandler(
                  file: file,
                );
              },
              onFileUploaded: (file) {
                utils.logger.info("file uploaded ${file.id}");
              },
              onFileRemoved: (file) {
                utils.logger.info("file removed ${file.id}");
              },
              placeholder: Text(context.t().addFilePlaceholder),
            ),
          ),
        ];
      },
    );
  }
}

class CustomFileCardSelfManagement extends StatefulWidget {
  const CustomFileCardSelfManagement({
    super.key,
    required this.ref,
  });

  final FileUploaderRef ref;

  @override
  State<CustomFileCardSelfManagement> createState() =>
      _CustomFileCardSelfManagementState();
}

class _CustomFileCardSelfManagementState
    extends State<CustomFileCardSelfManagement> {
  bool uploading = false;
  bool error = false;

  void _upload() async {
    setState(() {
      uploading = true;
    });
    try {
      await widget.ref.upload();
    } catch (e) {
      setState(() {
        error = true;
      });
    } finally {
      setState(() {
        uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ref.uploaded) {
      return Text(context.t().fileUploadedText);
    }

    if (uploading) {
      return const CircularProgressIndicator();
    }

    if (error) {
      return Text(context.t().errorUploadingText);
    }

    return ElevatedButton(
      onPressed: _upload,
      child: Text(context.t().uploadButtonText),
    );
  }
}
