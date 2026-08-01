import 'package:flutter/material.dart';

class ColorSchemePreviewPage extends StatelessWidget {
  const ColorSchemePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Define color pairs: Background color -> On-Color (Text/Icon color)
    final List<_ColorPair> colorPairs = [
      // Primary Group
      _ColorPair('Primary', colorScheme.primary, colorScheme.onPrimary),
      _ColorPair(
        'Primary Container',
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),

      // Secondary Group
      _ColorPair('Secondary', colorScheme.secondary, colorScheme.onSecondary),
      _ColorPair(
        'Secondary Container',
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),

      // Tertiary Group
      _ColorPair('Tertiary', colorScheme.tertiary, colorScheme.onTertiary),
      _ColorPair(
        'Tertiary Container',
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),

      // Surface & Background Group
      _ColorPair('Surface', colorScheme.surface, colorScheme.onSurface),
      _ColorPair(
        'Surface Container',
        colorScheme.surfaceContainer,
        colorScheme.onSurface,
      ),
      _ColorPair(
        'Surface Container High',
        colorScheme.surfaceContainerHigh,
        colorScheme.onSurface,
      ),

      // Error Group
      _ColorPair('Error', colorScheme.error, colorScheme.onError),
      _ColorPair(
        'Error Container',
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),

      // Utility Neutral Group
      _ColorPair('Outline', colorScheme.outline, colorScheme.surface),
      _ColorPair(
        'Outline Variant',
        colorScheme.outlineVariant,
        colorScheme.onSurface,
      ),
      _ColorPair(
        'Inverse Surface',
        colorScheme.inverseSurface,
        colorScheme.onInverseSurface,
      ),
      _ColorPair(
        'Inverse Primary',
        colorScheme.inversePrimary,
        colorScheme.surface,
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220, // Responsive grid sizing
            mainAxisExtent: 110,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: colorPairs.length,
          itemBuilder: (context, index) {
            final pair = colorPairs[index];
            return _ColorTile(pair: pair);
          },
        ),
      ),
    );
  }
}

// Data class to pair a background color with its corresponding "on" text color
class _ColorPair {
  final String name;
  final Color background;
  final Color onBackground;

  _ColorPair(this.name, this.background, this.onBackground);
}

// Widget to render each color block with its hex value
class _ColorTile extends StatelessWidget {
  final _ColorPair pair;

  const _ColorTile({required this.pair});

  // Convert Color object to #AARRGGBB hex string
  String _toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pair.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            pair.name,
            style: TextStyle(
              color: pair.onBackground,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              _toHex(pair.background),
              style: TextStyle(
                color: pair.onBackground.withValues(alpha: 0.8),
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
