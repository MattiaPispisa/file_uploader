import 'package:flutter/material.dart';

class ExampleBanner extends StatelessWidget {
  const ExampleBanner({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color backgroundColor =
        theme.colorScheme.outlineVariant.withValues(alpha: 0.5);
    final Color accentColor = theme.colorScheme.primary;
    final Color? textColor = theme.textTheme.bodyMedium?.color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          left: BorderSide(
            color: accentColor,
            width: 4.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: accentColor,
                size: 22.0,
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            description,
            style: TextStyle(
              color: textColor,
              fontSize: 15.0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
