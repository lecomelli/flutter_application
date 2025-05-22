import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  
  const MainShell({
    super.key,
    required this.child,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  
  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: 'Contatos',
    ),
    const NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble),
      label: 'Interações',
    ),
    const NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: 'Lembretes',
    ),
  ];
  
  final List<String> _routes = [
    '/contacts',
    '/interactions',
    '/reminders',
  ];

  void _onDestinationSelected(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      context.go(_routes[index]);
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }
  
  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    
    if (location.startsWith('/contacts')) {
      _currentIndex = 0;
    } else if (location.startsWith('/interactions')) {
      _currentIndex = 1;
    } else if (location.startsWith('/reminders')) {
      _currentIndex = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: _destinations,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}