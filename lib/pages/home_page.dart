import 'package:civic_project/pages/congress_page.dart';
import 'package:civic_project/pages/my_members_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = [const CongressPage(), const MyMembersPage()];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children:  [
            AboutListTile(
              applicationName: 'What the Fed?',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2024 lostplusfound',
                            aboutBoxChildren: [
                TextButton(
                  onPressed: () async {
                    if (await canLaunchUrlString('https://github.com/lostplusfound/what-the-fed')) {
                      await launchUrlString('https://github.com/lostplusfound/what-the-fed');
                    } else {
                      if(context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open the link.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      }
                    }
                  },

                  child: const Text('Github Repository'),
                ),
              ],

            )
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('What The Fed?'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: 'Congress'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'My Members')
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
