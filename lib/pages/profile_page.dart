import 'package:flutter/material.dart';
import '../widget/custom_bottom_nav.dart';
import 'home_page.dart';
import 'scan_page.dart';
import 'category_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // <-- USE Realtime Database

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? userUsername;
  String? userBio;
  String? userImageUrl;
  bool isNewUser = false; // Track if it's a new user

  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _listenToUserData(); // Live listen user profile changes
  }

  void _listenToUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      userRef.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            userName = data['name'];
            userUsername = data['username'];
            userBio = data['bio'];
            userImageUrl = data['profileImageUrl'];
            isNewUser = data['recipes'] == null || data['favorites'] == null; // If no recipes or favorites, treat as new user
          });
        }
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ScanPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CategoryPage()));
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Profile', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.orange),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: userImageUrl != null
                    ? NetworkImage(userImageUrl!)
                    : const AssetImage('assets/images/user.jpg') as ImageProvider,
              ),
              title: Text(
                userName ?? 'Loading...',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('@${userUsername ?? 'loading'}', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 2),
                  Text(
                    userBio ?? 'Loading bio...',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Icon(Icons.more_horiz, color: Colors.deepOrange),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _buildProfileButton('Edit Profile')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildProfileButton('Share Profile')),
                ],
              ),
            ),
            // Removed Following and Followers stats
            const SizedBox(height: 10),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.deepOrange,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.deepOrange,
                      tabs: [
                        Tab(text: 'Recipe'),
                        Tab(text: 'Favorites'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          isNewUser ? _buildNoContentSection() : _buildGrid([]), // New user content placeholder
                          isNewUser ? _buildNoContentSection() : _buildGrid([]), // New user content placeholder
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  static Widget _buildProfileButton(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.orange[100],
      ),
      child: Center(
        child: Text(title, style: const TextStyle(color: Colors.deepOrange)),
      ),
    );
  }

  static Widget _buildGrid(List<Map<String, String>> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(item['image']!, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(item['desc']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.favorite, size: 14, color: Colors.pinkAccent),
                              const SizedBox(width: 4),
                              Text(item['likes']!),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.deepOrange),
                              const SizedBox(width: 4),
                              Text(item['time']!),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildNoContentSection() {
    return Center(
      child: Text(
        'No content available yet.',
        style: TextStyle(color: Colors.grey[600], fontSize: 16),
      ),
    );
  }
}

