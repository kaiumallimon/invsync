import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/log_model.dart';
import '../services/logs_service.dart'; // Import the Log model

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final LogService logService = LogService();
  List<Log> logs = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(() {
      _onScroll(scrollController);
    });
    fetchLogs(); // Fetch the first page of logs when the screen loads
  }

  @override
  void dispose() {
    scrollController.dispose(); // Don't forget to dispose of the controller
    super.dispose();
  }

  Future<void> fetchLogs() async {
    if (isLoading || currentPage > totalPages)
      return; // Prevent fetching if already loading or all pages are fetched

    setState(() {
      isLoading = true;
    });

    try {
      final result = await logService.fetchLogs(currentPage,
          10); // Fetch logs for the current page with limit of 10 per page
      final logList = List<Log>.from(
        result['logs'].map((log) => Log.fromJson(log)),
      );

      setState(() {
        logs.addAll(
            logList); // Append the newly fetched logs to the existing list
        totalPages = result['totalPages']; // Update totalPages
        currentPage++; // Increment page for next fetch
      });
    } catch (error) {
      print("Error fetching logs: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to detect when to load more data
  void _onScroll(ScrollController controller) {
    if (isLoading || currentPage > totalPages) return;
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      fetchLogs(); // Trigger fetchLogs when reaching the bottom
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the theme
    final theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Logs',
                  style: TextStyle(fontSize: 20, color: theme.primary)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: logs.length + 1, // Add 1 for 'Load More'
              itemBuilder: (context, index) {
                if (index == logs.length) {
                  // Show loading indicator when fetching more logs
                  return isLoading
                      ? Center(child: CircularProgressIndicator())
                      : TextButton(
                          onPressed: fetchLogs,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Load more', style: TextStyle(fontSize: 15)),
                            ],
                          ),
                        );
                }

                final log = logs[index];
                return GestureDetector(
                  onLongPress: () {
                    // Show a dialog with log details
                    _showLogDetailsDialog(context, log);
                  },
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.history,
                      color: theme.primary,
                    ),
                    title: Text(log.operation,
                        style: TextStyle(color: theme.primary)),
                    subtitle: Text(_formatTimestamp(log.timestamp),
                        style: TextStyle(color: theme.secondary)),
                    children: [
                      ListTile(
                        title: Text('ID: ${log.data['_id']}'),
                      ),
                      ListTile(
                        title: Text('Name: ${log.data['name']}'),
                      ),
                      ListTile(
                        title: Text(
                            'Contact Person: ${log.data['contactPerson']}'),
                      ),
                      ListTile(
                        title:
                            Text('Contact Email: ${log.data['contactEmail']}'),
                      ),
                      ListTile(
                        title:
                            Text('Contact Phone: ${log.data['contactPhone']}'),
                      ),
                      ListTile(
                        title: Text('Address: ${log.data['address']}'),
                      ),
                      ListTile(
                        title: Text('Website: ${log.data['website']}'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Show log details in a dialog on long press
  void _showLogDetailsDialog(BuildContext context, Log log) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Operation: ${log.operation}'),
              Text('Timestamp: ${_formatTimestamp(log.timestamp)}'),
              const SizedBox(height: 10),
              const Text('Data:'),
              Text('ID: ${log.data['_id']}'),
              Text('Name: ${log.data['name']}'),
              Text('Contact Person: ${log.data['contactPerson']}'),
              Text('Contact Email: ${log.data['contactEmail']}'),
              Text('Contact Phone: ${log.data['contactPhone']}'),
              Text('Address: ${log.data['address']}'),
              Text('Website: ${log.data['website']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(String timestamp) {
    // Parse the timestamp string into a DateTime object
    DateTime dateTime = DateTime.parse(timestamp);

    // Adjust to UTC+6
    DateTime adjustedDateTime = dateTime.add(Duration(hours: 6));

    // Format the adjusted DateTime object into a readable string
    return DateFormat('y-M-d, ').add_jm().format(adjustedDateTime);
  }
}
