// This function can be called from anywhere to show the menu
import 'package:dirgebeya/Pages/MenuDemoScreen.dart';
import 'package:flutter/material.dart';

void showAppMenuBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: AppMenuGrid(parentContext: context), // ✅ Pass context
          );
        },
      );
    },
  );
}

