import 'package:flutter/material.dart';
import '../widget/custom_bottom_nav.dart'; // Ensure this is created and used
import 'home_page.dart';
import 'scan_page.dart';
import 'category_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;

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
        break; // current page
    }
  }

  final List<Map<String, String>> recipes = [
    {'title': 'Crispy Shrimp', 'desc': 'A feast for the senses', 'time': '20min', 'likes': '4', 'image': 'assets/images/crispy_shrimp.jpg'},
    {'title': 'Chicken Wings', 'desc': 'Delicious and juicy wings', 'time': '30min', 'likes': '5', 'image': 'assets/images/chicken_wings.jpg'},
    {'title': 'Colors Macarons', 'desc': 'Sweet bites full of elegance', 'time': '40min', 'likes': '4', 'image': 'assets/images/color_macarons.jpg'},
    {'title': 'Pina Colada', 'desc': 'A tropical explosion in every sip', 'time': '30min', 'likes': '4', 'image': 'assets/images/pina_colada.jpg'},
  ];

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
              leading: const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/user.jpg'),
              ),
              title: Text('Dianne Russell',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('@dianne_r', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 2),
                  Text('My passion is cooking and sharing new recipes\nwith the world.', style: TextStyle(fontSize: 13)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _StatTile(label: 'recipes', value: '60'),
                _StatTile(label: 'Following', value: '120'),
                _StatTile(label: 'Followers', value: '250'),
              ],
            ),
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
                          _buildGrid(recipes),
                          _buildGrid(recipes.reversed.toList()),
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

}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
