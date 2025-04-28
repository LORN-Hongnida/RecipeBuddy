import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widget/custom_bottom_nav.dart';
import 'home_page.dart';
import 'ingredient_input_page.dart';
import 'category_page.dart';
import 'recipe_detail_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'edit_profile_page.dart';
import 'share_profile_page.dart';
import '../widget/notification_widget.dart';
import '../widget/search_widget.dart';


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
            isNewUser = favoriteRecipes.isEmpty && (userName == null || userName!.isEmpty);
          });
        } else {
          setState(() {
            isNewUser = true;
          });
        }
      });
    } else {
      setState(() {
        isNewUser = true;
        userName = null;
        userUsername = null;
        userBio = null;
        userImageUrl = null;
        favoriteRecipes = [];
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
    } else {
      setState(() {
        favoriteRecipes = [];
        isNewUser = true;
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => IngredientInputPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CategoryPage()));
        break;
      case 3:
        break;
    }
  }

  void _handleLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _handleSignup() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage()));
  }

  void _handleEditProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
  }

  void _handleShareProfile() {
    if (userUsername != null && userUsername!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShareProfilePage(username: userUsername!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username not available. Please set a username first.')),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Log Out', style: TextStyle(color: Color.fromARGB(255, 255, 108, 67))),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context); // Close the dialog
              // Redirect to LoginPage after logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color.fromARGB(255, 255, 108, 67),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 108, 67),
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        leading: const SizedBox(), // Back icon already removed
        actions: [
          const NotificationWidget(),
          const SearchWidget(),
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout, color: Color.fromARGB(255, 255, 108, 67)),
              onPressed: _handleLogout,
            ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile header with avatar
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          // backgroundColor: Color.fromARGB(255, 255, 108, 67).shade50,
                          backgroundImage: userImageUrl != null && userImageUrl!.isNotEmpty
                              ? NetworkImage(userImageUrl!)
                              : const AssetImage('assets/images/user.jpg') as ImageProvider,
                        ),
                        if (isLoggedIn)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 108, 67),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // User info
                    Text(
                      userName ?? 'Guest',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 108, 67),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${userUsername ?? 'guest'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        userBio ?? 'Welcome! Log in or sign up to save your favorite recipes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        children: isLoggedIn
                            ? [
                          Expanded(
                            child: _buildProfileButton(
                              'Edit Profile',
                              icon: Icons.edit,
                              onPressed: _handleEditProfile,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildProfileButton(
                              'Share Profile',
                              icon: Icons.share,
                              onPressed: _handleShareProfile,
                            ),
                          ),
                        ]
                            : [
                          Expanded(
                            child: _buildProfileButton(
                              'Log In',
                              icon: Icons.login,
                              onPressed: _handleLogin,
                              isPrimary: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildProfileButton(
                              'Sign Up',
                              icon: Icons.person_add,
                              onPressed: _handleSignup,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),

            // Favorites section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 108, 67),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Favorites',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Favorites grid or no content message
            favoriteRecipes.isEmpty
                ? SliverFillRemaining(
              child: _buildNoContentSection(),
            )
                : SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildRecipeCard(favoriteRecipes[index]),
                  childCount: favoriteRecipes.length,
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

  Widget _buildProfileButton(
      String title, {
        required VoidCallback onPressed,
        IconData? icon,
        bool isPrimary = false,
      }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: isPrimary ? Colors.white : Color.fromARGB(255, 255, 108, 67),
        backgroundColor: isPrimary ? Color.fromARGB(255, 255, 108, 67) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: isPrimary ? Colors.transparent : Color.fromARGB(255, 255, 108, 67).withOpacity(0.5),
            width: 1,
          ),
        ),
        elevation: isPrimary ? 2 : 0,
        shadowColor: isPrimary ? Color.fromARGB(255, 255, 108, 67).withOpacity(0.3) : Colors.transparent,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> item) {
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
          border: Border.all(color: Colors.deepOrange.shade100),
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
                            const Icon(Icons.access_time, size: 14, color: Color.fromARGB(255, 255, 108, 67)),
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
  }

  Widget _buildNoContentSection() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FirebaseAuth.instance.currentUser == null ? Icons.login : Icons.favorite_border,
            size: 60,
            color: Color.fromARGB(255, 255, 108, 67).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            FirebaseAuth.instance.currentUser == null
                ? 'Log in to view your favorite recipes'
                : 'No favorite recipes yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            FirebaseAuth.instance.currentUser == null
                ? 'Create an account to save recipes you love'
                : 'Start exploring recipes and save your favorites',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (FirebaseAuth.instance.currentUser == null)
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 255, 108, 67),
                side: const BorderSide(color: Color.fromARGB(255, 255, 108, 67)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Get Started'),
            )
          else
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 255, 108, 67),
                side: const BorderSide(color: Color.fromARGB(255, 255, 108, 67)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Browse Recipes'),
            ),
        ],
      ),
    );
  }
}