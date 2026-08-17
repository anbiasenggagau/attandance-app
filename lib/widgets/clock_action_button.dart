import 'package:flutter/material.dart';

class ClockActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ClockActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // // These colors are based on the image you provided.
    final primaryButtonColor = Theme.of(context).colorScheme.primary;
    final outerRingColor = Theme.of(context).colorScheme.primaryContainer;
    final contentColor = Theme.of(context).colorScheme.surface;

    // Use a Stack to layer the outer ring behind the main button.
    return Stack(
      alignment: Alignment.center,
      children: [
        // The outer light-pink ring
        Container(
          width: 250, // Match the overall desired size
          height: 250,
          decoration: BoxDecoration(
            // color: outerRingColor,
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [outerRingColor, contentColor],
              stops: [0.75, 1],
            ),
          ),
        ),
        // The main interactive button
        Container(
          width: 200, // Make the button slightly smaller than the ring
          height: 200,
          decoration: BoxDecoration(
            color: primaryButtonColor,
            shape: BoxShape.circle,
            // Add a subtle shadow to give it elevation
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          // We use Material and InkWell inside the Container for touch feedback.
          child: Material(
            color: Colors.transparent, // Inherit color from Container
            child: InkWell(
              onTap: onPressed, // The action when tapped
              customBorder: const CircleBorder(), // Defines the splash area
              splashColor: contentColor.withValues(
                alpha: 0.3,
              ), // White-ish splash
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The gesture icon
                  Icon(icon, size: 80, color: contentColor),
                  const SizedBox(height: 10), // Space between icon and text
                  // The action text
                  Text(
                    label,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
