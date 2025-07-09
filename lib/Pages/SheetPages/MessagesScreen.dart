import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class Message {
  final String title;
  final String body;
  final DateTime timestamp;

  Message({
    required this.title,
    required this.body,
    required this.timestamp,
  });
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  // Sample message data
  List<Message> getMessages() {
    return [
      Message(
        title: 'New Order Alert',
        body: 'You have a new order request from John Doe...',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      Message(
        title: 'System Maintenance',
        body: 'The platform will undergo maintenance at midnight.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      Message(
        title: 'Weekly Summary',
        body: 'Your weekly performance is available. Check your dashboard.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final messages = getMessages();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final formattedTime = DateFormat('dd MMM, yyyy • hh:mm a').format(msg.timestamp);
          final timeAgo = timeago.format(msg.timestamp);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    msg.body,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
