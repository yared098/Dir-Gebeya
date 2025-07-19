import 'package:call_log/call_log.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';

class RecentCallsContent extends StatefulWidget {
  final String message;
  final String shareLink;

  RecentCallsContent({required this.message, required this.shareLink});

  @override
  _RecentCallsPageState createState() => _RecentCallsPageState();
}

class _RecentCallsPageState extends State<RecentCallsContent> {
  final Telephony telephony = Telephony.instance;

  List<CallLogEntry> _calls = [];
  Set<String> _selectedNumbers = {};

  @override
  void initState() {
    super.initState();
    _getCallLogs();
  }

  Future<void> _getCallLogs() async {
    var status = await Permission.phone.status;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      Iterable<CallLogEntry> entries = await CallLog.get();

      final seenNumbers = <String>{};
      final uniqueCalls = <CallLogEntry>[];

      for (var call in entries) {
        final number = call.number;
        if (number != null && !seenNumbers.contains(number)) {
          seenNumbers.add(number);
          uniqueCalls.add(call);
          if (uniqueCalls.length == 10) break; // limit to 10 unique numbers
        }
      }

      setState(() {
        _calls = uniqueCalls;
      });
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Permission permanently denied. Please enable from settings.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to access call logs.')),
      );
    }
  }

  String formatTimestamp(int? timestamp) {
    if (timestamp == null) return "Unknown time";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy – hh:mm a').format(date);
  }

  String formatCallType(CallType? type) {
    switch (type) {
      case CallType.incoming:
        return 'Incoming';
      case CallType.outgoing:
        return 'Outgoing';
      case CallType.missed:
        return 'Missed';
      case CallType.rejected:
        return 'Rejected';
      case CallType.blocked:
        return 'Blocked';
      default:
        return 'Unknown';
    }
  }

  void _toggleSelection(String number) {
    setState(() {
      if (_selectedNumbers.contains(number)) {
        _selectedNumbers.remove(number);
      } else {
        _selectedNumbers.add(number);
      }
    });
  }

  Future<void> _sendMessageToSelected(String message, String shareLink) async {
    if (_selectedNumbers.isEmpty) return;

    final String fullMessage = '$message\n\nCheck this out:\n$shareLink';

    // Join all numbers separated by comma
    final allNumbers = _selectedNumbers.join(',');

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: allNumbers,
      queryParameters: {'body': fullMessage},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      setState(() {
        _selectedNumbers.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch SMS app for multiple recipients'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              "Invite Passengers",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ),

          backgroundColor: AppColors.primary,
          centerTitle: true,
          elevation: 4,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          // ),
        ),
        body: _calls.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _calls.length,
                itemBuilder: (context, index) {
                  final call = _calls[index];
                  final number = call.number ?? 'Unknown';
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: _selectedNumbers.contains(number),
                        onChanged: (bool? selected) {
                          if (number != 'Unknown') {
                            _toggleSelection(number);
                          }
                        },
                      ),
                      title: Text(call.name ?? number),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Number: $number"),
                          
                        ],
                      ),
                      
                    ),
                  );
                },
              ),
        floatingActionButton: _selectedNumbers.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () =>
                    _sendMessageToSelected(widget.message, widget.shareLink),
                icon: Icon(Icons.message, color: Colors.amber),
                label: Text(
                  "Send Message",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.primary,
              )
            : null,
      ),
    );
  }
}
