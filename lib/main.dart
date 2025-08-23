// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hackathonpro/auth/login_page.dart';
// import 'package:hackathonpro/pages/post/post_page.dart';
// import 'package:hackathonpro/pages/profile/profile_page.dart';
// import 'package:hackathonpro/pages/search/search_page.dart';
// import 'package:hackathonpro/pages/work/work_page.dart';
// import 'package:hackathonpro/provider/post_provider.dart';
// import 'package:hackathonpro/provider/user_provider.dart';
// import 'package:provider/provider.dart';
// import 'pages/home/home_page.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//         ChangeNotifierProvider(create: (_) => PostProvider()),
//       ],
//       child: MaterialApp(
//         title: 'CollabHub',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         home: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasData) {
//               return MainNavigator();
//             }
//             return LoginPage();
//           },
//         ),
//       ),
//     );
//   }
// }

// // main_navigator.dart - Bottom navigation wrapper
// class MainNavigator extends StatefulWidget {
//   const MainNavigator({super.key});
//   @override
//   _MainNavigatorState createState() => _MainNavigatorState();
// }

// class _MainNavigatorState extends State<MainNavigator> {
//   int _currentIndex = 0;

//   final List<Widget> _pages = [
//     HomePage(),
//     BrowseProjectsPage(),
//     PostProjectPage(), // You'll build this next
//     MyWorkPage(), // You'll build this next
//     ProfilePage(), // You'll build this next
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.blue[600],
//         unselectedItemColor: Colors.grey[600],
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
//           BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Post'),
//           BottomNavigationBarItem(icon: Icon(Icons.work), label: 'My Work'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'provider/user_provider.dart';
import 'provider/post_provider.dart';

// Pages
import 'pages/home/home_page.dart';
import 'pages/post/post_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/search/search_page.dart';
import 'pages/work/work_page.dart';
import 'auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: MaterialApp.router(
        title: 'CollabHub',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }

  // 🔹 Router
  final GoRouter _router = GoRouter(
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null && state.fullPath != '/login') {
        return '/login'; // redirect to login
      }
      if (user != null && state.fullPath == '/login') {
        return '/'; // already logged in → home
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      ShellRoute(
        builder: (context, state, child) => MainNavigator(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => HomePage()),
          GoRoute(
            path: '/browse',
            builder: (context, state) => BrowseProjectsPage(),
          ),
          GoRoute(
            path: '/post',
            builder: (context, state) => PostProjectPage(),
          ),
          GoRoute(path: '/work', builder: (context, state) => MyWorkPage()),
          GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
        ],
      ),
    ],
  );
}

// 🔹 Bottom navigation wrapper
class MainNavigator extends StatefulWidget {
  final Widget child;
  const MainNavigator({super.key, required this.child});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<String> _routes = ['/', '/browse', '/post', '/work', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_routes[index]); // 🔹 navigate with GoRouter
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        items: const [
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
