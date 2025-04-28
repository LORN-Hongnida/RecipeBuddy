import 'package:flutter/material.dart';
import '../pages/search_page.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search, color: Color.fromARGB(255, 255, 108, 67)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
      },
    );
  }
}