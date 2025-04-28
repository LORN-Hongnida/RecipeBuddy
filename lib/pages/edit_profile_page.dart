import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? userName;
  String? userUsername;
  String? userBio;
  String? userImageUrl;
  bool _isLoading = false;
  bool _isDataLoaded = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();

  }

  void _loadUserData() {
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
            _nameController.text = userName ?? '';
            _usernameController.text = userUsername ?? '';
            _bioController.text = userBio ?? '';
            _isDataLoaded = true;
            print('Loaded profileImageUrl: $userImageUrl');
          });
        } else {
          setState(() {
            _isDataLoaded = true;
          });
        }
      }, onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $error')),
        );
        setState(() {
          _isDataLoaded = true;
        });
      });
    }
  }


  // Future<void> _pickAndUploadImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile != null) {
  //     final user = FirebaseAuth.instance.currentUser;
  //
  //     if (user != null) {
  //       try {
  //         final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
  //
  //         if (kIsWeb) {
  //           // 🖥️ For Web: upload as Uint8List
  //           Uint8List? bytes = await pickedFile.readAsBytes();
  //           await storageRef.putData(bytes);
  //         } else {
  //           // 📱 For Mobile: upload as File
  //           File imageFile = File(pickedFile.path);
  //           await storageRef.putFile(imageFile);
  //         }
  //
  //         // Get the download URL
  //         String downloadUrl = await storageRef.getDownloadURL();
  //
  //         // Update the database with new image URL
  //         await FirebaseDatabase.instance.ref('users/${user.uid}').update({
  //           'profileImageUrl': downloadUrl,
  //         });
  //
  //         setState(() {
  //           userImageUrl = downloadUrl;
  //         });
  //
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Profile picture updated')),
  //         );
  //       } catch (e) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Error uploading image: $e')),
  //         );
  //       }
  //     }
  //   }
  // }
  Future<void> _enterImageUrl() async {
    TextEditingController _urlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Image URL'),
          content: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: 'Paste image URL here',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String enteredUrl = _urlController.text.trim();
                if (enteredUrl.isNotEmpty && Uri.tryParse(enteredUrl)?.hasAbsolutePath == true) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    try {
                      await FirebaseDatabase.instance.ref('users/${user.uid}').update({
                        'profileImageUrl': enteredUrl,
                      });
                      setState(() {
                        userImageUrl = enteredUrl;
                      });
                      Navigator.of(context).pop(); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile picture updated')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving image URL: $e')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid URL')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      try {
        await userRef.update({
          'name': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
          'bio': _bioController.text.trim(),
          'profileImageUrl': userImageUrl ?? '',
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $error')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 108, 67),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 108, 67)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isDataLoaded
            ? SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _enterImageUrl,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        // backgroundColor: Color.fromARGB(255, 255, 108, 67).shade50,
                        backgroundImage:
                        userImageUrl != null && userImageUrl!.isNotEmpty
                            ? NetworkImage(userImageUrl!)
                            : const AssetImage('assets/images/user.jpg')
                        as ImageProvider,
                      ),
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
                ),
                const SizedBox(height: 24),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color.fromARGB(255, 255, 108, 67).withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 255, 108, 67)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color.fromARGB(255, 255, 108, 67).withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 255, 108, 67)),
                    ),
                    prefixText: '@',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username';
                    }
                    if (value.contains(' ')) {
                      return 'Username cannot contain spaces';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bio
                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color.fromARGB(255, 255, 108, 67).withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 255, 108, 67)),
                    ),
                  ),
                  maxLines: 3,
                  maxLength: 150,
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 255, 108, 67),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            : const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 255, 108, 67))),
      ),
    );
  }
}
