import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final notificationsRef = FirebaseDatabase.instance.ref('notifications/${user.uid}');
      notificationsRef.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;
        List<Map<String, dynamic>> loadedNotifications = [];
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            loadedNotifications.add({
              'id': key,
              'title': value['title']?.toString() ?? '',
              'message': value['message']?.toString() ?? '',
              'timestamp': value['timestamp']?.toString() ?? '',
              'isRead': value['isRead'] == true,
            });
          });
          loadedNotifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        } else {
          // Add sample notifications if none exist
          _addSampleNotifications(notificationsRef);
        }
        setState(() {
          notifications = loadedNotifications;
          isLoading = false;
        });
      }, onError: (error) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $error')),
        );
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addSampleNotifications(DatabaseReference notificationsRef) {
    notificationsRef.push().set({
      'title': 'Welcome to the App!',
      'message': 'Thanks for joining. Start exploring recipes now!',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'isRead': false,
    });
    notificationsRef.push().set({
      'title': 'New Recipe Added',
      'message': 'Check out the new recipe in the Desserts category!',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toUtc().toIso8601String(),
      'isRead': false,
    });
  }

  void _markAllAsRead() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final notificationsRef = FirebaseDatabase.instance.ref('notifications/${user.uid}');
      notifications.forEach((notification) {
        if (!notification['isRead']) {
          notificationsRef.child(notification['id']).update({'isRead': true});
        }
      });
    }
  }

  void _deleteNotification(String notificationId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseDatabase.instance.ref('notifications/${user.uid}/$notificationId').remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notifications.any((n) => !n['isRead']))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all as read',
                style: TextStyle(color: Colors.orange),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : user == null
            ? const Center(
          child: Text(
            'Please log in to view notifications',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            : notifications.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 60,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                'No notifications yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              color: notification['isRead'] ? Colors.white : Colors.orange.shade50,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: notification['isRead'] ? Colors.grey : Colors.orange,
                ),
                title: Text(
                  notification['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(notification['message']),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a')
                          .format(DateTime.parse(notification['timestamp'])),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteNotification(notification['id']),
                ),
                onTap: () {
                  if (!notification['isRead']) {
                    FirebaseDatabase.instance
                        .ref('notifications/${user.uid}/${notification['id']}')
                        .update({'isRead': true});
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}