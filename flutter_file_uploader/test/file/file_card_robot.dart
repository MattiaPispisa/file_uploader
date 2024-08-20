import 'package:flutter/material.dart';
import 'package:flutter_file_uploader/flutter_file_uploader.dart';
import 'package:flutter_test/flutter_test.dart';

/// 1. construct [FileCardRobot]
/// 2. pump widget: [FileCardRobot.pumpFileCard]
/// 3. tests
class FileCardRobot {
  const FileCardRobot({
    required WidgetTester tester,
  }) : _tester = tester;

  final WidgetTester _tester;

  Future<void> pumpFileCard({
    required FileUploadStatus status,
    Widget content = const SizedBox(),
    double progress = 0,
  }) {
    return _tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: _StateFulFileCard(
          key: const ValueKey('_stateful_file_card'),
          status: status,
          progress: progress,
          content: content,
        ),
      ),
    );
  }

  Future<void> settle() {
    return _tester.pumpAndSettle();
  }

  void expectRemoveButton() {
    expect(find.byKey(const ValueKey('remove_button')), findsOneWidget);
  }

  void expectNoRemoveButton() {
    expect(find.byKey(const ValueKey('remove_button')), findsNothing);
  }

  void expectRetryButton() {
    expect(find.byKey(const ValueKey('retry_button')), findsOneWidget);
  }

  void expectNoRetryButton() {
    expect(find.byKey(const ValueKey('retry_button')), findsNothing);
  }

  void expectUploadButton() {
    expect(find.byKey(const ValueKey('upload_button')), findsOneWidget);
  }

  void expectNoUploadButton() {
    expect(find.byKey(const ValueKey('upload_button')), findsNothing);
  }

  void expectProgress(double progress) {
    final progressWidgetFinder =
        find.byKey(const ValueKey('_file_card_progress'));
    final progressIndicatorFinder = find.descendant(
      of: progressWidgetFinder,
      matching: find.byType(LinearProgressIndicator),
    );

    final progressIndicator = _tester.widget(progressIndicatorFinder);
    expect(
      progressIndicator,
      isA<LinearProgressIndicator>().having((i) => i.value, 'value', progress),
    );
  }

  Future<void> expectProgressUpdate({
    required double from,
    required double to,
  }) async {
    expectProgress(from);
    _tester
        .state<_StateFulFileCardState>(
          find.byKey(const ValueKey('_stateful_file_card')),
        )
        .updateProgress(to);
    await _tester.pumpAndSettle();
    expectProgress(to);
  }
}

class _StateFulFileCard extends StatefulWidget {
  const _StateFulFileCard({
    required this.status,
    this.content = const SizedBox(),
    this.progress = 0,
    super.key,
  });

  final Widget content;
  final FileUploadStatus status;
  final double progress;

  @override
  State<_StateFulFileCard> createState() => _StateFulFileCardState();
}

class _StateFulFileCardState extends State<_StateFulFileCard> {
  late double _lastProgress;

  @override
  void initState() {
    _lastProgress = widget.progress;
    super.initState();
  }

  void updateProgress(double progress) {
    _lastProgress = progress;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FileCard(
      content: widget.content,
      status: widget.status,
      progress: _lastProgress,
    );
  }
}
