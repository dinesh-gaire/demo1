import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:offnet/data/objectbox.dart';
import 'package:offnet/presentation/home/contacts_page.dart';
import 'package:offnet/presentation/discovery_page.dart';
import 'package:offnet/presentation/home/profile_page.dart';

class HomePage extends StatefulWidget {
  final ObjectBox objectBox;

  const HomePage({Key? key, required this.objectBox}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _page = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ContactsPage(objectBox: widget.objectBox),
      const DiscoveryPage(),
      ProfilePage(objectBox: widget.objectBox),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_page],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        color: Theme.of(context).primaryColor,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        items: [
          Icon(
            Icons.message,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.08,
          ),
          Icon(
            Icons.wifi_tethering,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.08,
          ),
          Icon(
            Icons.person,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.08,
          ),
        ],
      ),
    );
  }
}
