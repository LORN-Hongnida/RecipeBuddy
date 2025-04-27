import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widget/custom_bottom_nav.dart';
import 'home_page.dart';
import 'scan_page.dart';
import 'category_page.dart';
import 'recipe_detail_page.dart';

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
  bool isNewUser = false;
  List<Map<String, dynamic>> favoriteRecipes = [];
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _listenToUserData();
    _listenToFavorites();
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
            userName = data['name']?.toString();
            userUsername = data['username']?.toString();
            userBio = data['bio']?.toString();
            userImageUrl = data['profileImageUrl']?.toString();
            isNewUser = (data['recipes'] == null || data['recipes'].isEmpty) &&
                favoriteRecipes.isEmpty;
          });
        } else {
          setState(() {
            isNewUser = true;
          });
        }
      });
    }
  }

  void _listenToFavorites() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoritesRef = FirebaseDatabase.instance.ref('users/${user.uid}/favorites');
      favoritesRef.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot;
        List<Map<String, dynamic>> favorites = [];
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, value) {
            favorites.add({
              'favoriteId': key,
              'categoryName': value['categoryName']?.toString() ?? '',
              'recipeId': value['recipeId']?.toString() ?? '',
              'title': value['title']?.toString() ?? '',
              'image': value['image']?.toString() ?? '',
              'time': value['time']?.toString() ?? '',
              'likes': value['likes']?.toString() ?? '0',
              'desc': value['desc']?.toString() ?? '',
            });
          });
        }
        // Remove duplicates by favoriteId
        final seenIds = <String>{};
        favorites = favorites.where((recipe) {
          if (seenIds.contains(recipe['favoriteId'])) {
            return false;
          }
          seenIds.add(recipe['favoriteId']);
          return true;
        }).toList();

        setState(() {
          favoriteRecipes = favorites;
          isNewUser = favoriteRecipes.isEmpty && (userName == null || userName!.isEmpty);
        });
        debugPrint('Favorites: ${favoriteRecipes.map((r) => r['favoriteId']).toList()}');
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ScanPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CategoryPage()));
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
                backgroundImage: userImageUrl != null && userImageUrl!.isNotEmpty
                    ? NetworkImage(userImageUrl!)
                    : const AssetImage('assets/images/user.jpg') as ImageProvider,
              ),
              title: Text(
                userName ?? 'New User',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${userUsername ?? 'new_user'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userBio ?? 'No bio available.',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
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
                          isNewUser ? _buildNoContentSection() : _buildGrid([]),
                          favoriteRecipes.isEmpty ? _buildNoContentSection() : _buildGrid(favoriteRecipes),
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

  Widget _buildProfileButton(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.orange[100],
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items) {
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
        return GestureDetector(
          onTap: () {
            debugPrint('Navigating to: category=${item['categoryName']}, recipeId=${item['recipeId']}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailPage(
                  categoryName: item['categoryName'],
                  recipeId: item['recipeId'],
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: item['image'].isNotEmpty
                      ? item['image'].startsWith('http')
                      ? Image.network(
                    item['image'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                  )
                      : Image.asset(
                    item['image'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                  )
                      : const SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Icon(Icons.image, size: 50),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['desc'],
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.favorite, size: 14, color: Colors.pinkAccent),
                                const SizedBox(width: 4),
                                Text(item['likes'], style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: Colors.deepOrange),
                                const SizedBox(width: 4),
                                Text(item['time'], style: const TextStyle(fontSize: 12)),
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
          ),
        );
      },
    );
  }

  Widget _buildNoContentSection() {
    return Center(
      child: Text(
        'No content available yet.',
        style: TextStyle(color: Colors.grey[600], fontSize: 16),
      ),
    );
  }
}