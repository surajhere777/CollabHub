import 'package:flutter/material.dart';
import 'package:hackathonpro/auth/login_page.dart';
import 'package:hackathonpro/auth/sign_in.dart';
import 'package:hackathonpro/pages/post/post_page.dart';
import 'package:hackathonpro/pages/profile/profile_page.dart';
import 'package:hackathonpro/pages/search/search_page.dart';
import 'package:hackathonpro/pages/work/work_page.dart';
import 'pages/home/home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CollabHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignUpPage(),
      // Define your routes here
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => MainNavigator(),
      //   '/browse': (context) => BrowseProjectsPage(),
      // },
    );
  }
}

// main_navigator.dart - Bottom navigation wrapper
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    BrowseProjectsPage(),
    PostProjectPage(), // You'll build this next
    MyWorkPage(), // You'll build this next
    ProfilePage(), // You'll build this next
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'My Work'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
