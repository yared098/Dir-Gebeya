import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:dirgebeya/Provider/messages_provider.dart';  // Your MessagesProvider
import 'package:dirgebeya/Model/Messages.dart'; // Import your Message model

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;



class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}
class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<MessagesProvider>(context, listen: false).fetchMessages(page: 1, limit: 10);
  }

  Future<void> _refreshMessages() async {
    await Provider.of<MessagesProvider>(context, listen: false).fetchMessages(page: 1, limit: 10, forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messages",
          style: TextStyle(color: theme.textTheme.headlineLarge?.color),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<MessagesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.messages.isEmpty) {
            // Show loading only if empty (initial load)
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.messages.isEmpty) {
            // Show error only if empty (initial load)
            return Center(
                child: Text('Error: ${provider.error}',
                    style: TextStyle(color: theme.colorScheme.error)));
          }

          if (provider.messages.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshMessages,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('No messages available.')),
                ],
              ),
            );
          }

          // Wrap ListView with RefreshIndicator
          return RefreshIndicator(
            onRefresh: _refreshMessages,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.messages.length,
              itemBuilder: (context, index) {
                final msg = provider.messages[index];
                final formattedTime = DateFormat('dd MMM, yyyy • hh:mm a').format(msg.createdAt);
                final timeAgo = timeago.format(msg.createdAt);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageDetailScreen(message: msg),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  msg.moduleName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                msg.seen == 1 ? 'Seen' : 'Unseen',
                                style: TextStyle(
                                  color: msg.seen == 1 ? Colors.green : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            msg.text,
                            style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedTime,
                                style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 14, color: theme.iconTheme.color?.withOpacity(0.6)),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeAgo,
                                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class MessageDetailScreen extends StatefulWidget {
  final Message message;

  const MessageDetailScreen({super.key, required this.message});

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
@override
void initState() {
  super.initState();
  _markMessageReceived();
}

Future<void> _markMessageReceived() async {
  final provider = Provider.of<MessagesProvider>(context, listen: false);
  final success = await provider.markMessageAsReceived(
    id: widget.message.id,
    userId: widget.message.userId,
  );

  if (success) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message marked as received')),
      );
    }
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark message as received: ${provider.error ?? "Unknown error"}')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final formattedTime = DateFormat('dd MMM, yyyy • hh:mm a').format(message.createdAt);
    final timeAgo = timeago.format(message.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Detail"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (message.image.isNotEmpty)
              Image.network(message.image, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),

            Text(
              message.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D4ED8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message.name,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 12),
              // Seen/unseen text
    Text(
      message.seen == 1 ? 'Seen' : 'Unseen',
      style: TextStyle(
        color: message.seen == 1 ? Colors.green : Colors.redAccent,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            Text(
              message.text,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 12),

            Text("Module: ${message.moduleName}"),
            Text("Module ID: ${message.moduleId}"),
            Text("Seen: ${message.seen}"),
            Text("Received: ${message.received}"),
            if (message.estimation != null) Text("Estimation: ${message.estimation}"),
            Text("User ID: ${message.userId}"),
            if (message.status != null) Text("Status: ${message.status}"),
          ],
        ),
      ),
    );
  }
}