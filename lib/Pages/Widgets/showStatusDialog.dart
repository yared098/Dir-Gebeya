import 'package:flutter/material.dart';

void showStatusDialog(BuildContext context, {required bool isAccepted}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: AnimationController(
              vsync: Navigator.of(context),
              duration: const Duration(milliseconds: 400),
            )..forward(),
            curve: Curves.elasticOut,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAccepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 64,
                  color: isAccepted ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  isAccepted ? 'Order Accepted' : 'Order Rejected',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  isAccepted
                      ? 'The order has been successfully approved.'
                      : 'The order has been rejected.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAccepted ? Colors.green : Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
