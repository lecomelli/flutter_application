import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/contacts/presentation/screens/contacts_screen.dart';
import '../../features/contacts/presentation/screens/contact_detail_screen.dart';
import '../../features/contacts/presentation/screens/add_edit_contact_screen.dart';
import '../../features/interactions/presentation/screens/interactions_screen.dart';
import '../../features/interactions/presentation/screens/add_interaction_screen.dart';
import '../../features/reminders/presentation/screens/reminders_screen.dart';
import '../widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/contacts',
    routes: [
      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Contacts tab
          GoRoute(
            path: '/contacts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ContactsScreen(),
            ),
            routes: [
              GoRoute(
                path: '/add',
                builder: (context, state) => const AddEditContactScreen(),
              ),
              GoRoute(
                path: '/:id',
                builder: (context, state) => ContactDetailScreen(
                  contactId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: '/edit',
                    builder: (context, state) => AddEditContactScreen(
                      contactId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Interactions tab
          GoRoute(
            path: '/interactions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InteractionsScreen(),
            ),
            routes: [
              GoRoute(
                path: '/add',
                builder: (context, state) => AddInteractionScreen(
                  contactId: state.uri.queryParameters['contactId'],
                ),
              ),
            ],
          ),
          
          // Reminders tab
          GoRoute(
            path: '/reminders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RemindersScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

// Navigation helper
extension AppRouterExtension on GoRouter {
  void goToContactDetail(String contactId) {
    go('/contacts/$contactId');
  }
  
  void goToAddContact() {
    go('/contacts/add');
  }
  
  void goToEditContact(String contactId) {
    go('/contacts/$contactId/edit');
  }
  
  void goToAddInteraction({String? contactId}) {
    final query = contactId != null ? '?contactId=$contactId' : '';
    go('/interactions/add$query');
  }
}