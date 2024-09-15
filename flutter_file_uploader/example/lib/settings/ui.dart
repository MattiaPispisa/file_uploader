import 'package:example/settings/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsConsumer extends StatelessWidget {
  const SettingsConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Limit(),
        _Space(direction: Axis.vertical),
        _HideOnLimit(),
        _Space(direction: Axis.vertical),
        _Color(),
      ],
    );
  }
}

class _Limit extends StatelessWidget {
  const _Limit({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ExampleSettings, int?>(
      selector: (_, state) => state.limit,
      builder: (context, limit, child) {
        return Row(
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<ExampleSettings>().decrementLimit();
              },
              child: Icon(Icons.remove),
            ),
            _Space(),
            Text(limit?.toString() ?? 'no limit'),
            _Space(),
            ElevatedButton(
              onPressed: () {
                context.read<ExampleSettings>().incrementLimit();
              },
              child: Icon(Icons.add),
            ),
            Expanded(child: _Space()),
            ElevatedButton(
              onPressed: () {
                context.read<ExampleSettings>().limit = null;
              },
              child: Icon(Icons.delete),
            ),
          ],
        );
      },
    );
  }
}

class _HideOnLimit extends StatelessWidget {
  const _HideOnLimit({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ExampleSettings, bool?>(
      selector: (_, state) => state.hideOnLimit,
      builder: (context, hideOnLimit, child) {
        return Row(
          children: [
            Text("hide on limit"),
            _Space(),
            Switch.adaptive(
              value: hideOnLimit ?? false,
              onChanged: (_) {
                context.read<ExampleSettings>().toggleHideOnLimit();
              },
            ),
          ],
        );
      },
    );
  }
}

class _Color extends StatelessWidget {
  const _Color({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Selector<ExampleSettings, Color?>(
          selector: (_, state) => state.color,
          builder: (context, color, child) {
            return Container(
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              height: 40,
              width: 40,
            );
          },
        ),
        _Space(),
        ElevatedButton(
          onPressed: () {
            context.read<ExampleSettings>().randomColor();
          },
          child: Text("random"),
        ),
        Expanded(child: _Space()),
        ElevatedButton(
          onPressed: () {
            context.read<ExampleSettings>().color = null;
          },
          child: Icon(Icons.delete),
        ),
      ],
    );
  }
}

class _Space extends StatelessWidget {
  const _Space({
    super.key,
    this.direction = Axis.horizontal,
  });

  final Axis direction;

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.vertical) {
      return SizedBox(height: 8);
    }
    return SizedBox(width: 8);
  }
}
