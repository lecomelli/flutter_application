import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/contacts_controller.dart';
import '../widgets/contact_card.dart';
import '../widgets/contact_search_bar.dart';
import '../widgets/upcoming_birthdays_card.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsState = ref.watch(contactsControllerProvider);
    final upcomingBirthdays = ref.watch(upcomingBirthdaysProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(contactsControllerProvider.notifier).loadContacts(),
        child: CustomScrollView(
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ContactSearchBar(
                  onChanged: (query) {
                    ref.read(contactsControllerProvider.notifier)
                        .updateSearchQuery(query);
                  },
                ),
              ),
            ),
            
            // Upcoming birthdays
            upcomingBirthdays.when(
              data: (birthdays) {
                if (birthdays.isEmpty) return const SliverToBoxAdapter();
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: UpcomingBirthdaysCard(contacts: birthdays),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(),
              error: (_, __) => const SliverToBoxAdapter(),
            ),
            
            // Error handling
            if (contactsState.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              contactsState.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(contactsControllerProvider.notifier).clearError();
                            },
                            child: const Text('Dispensar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
            // Loading indicator
            if (contactsState.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            
            // Contacts list
            if (!contactsState.isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: contactsState.filteredContacts.isEmpty
                    ? SliverToBoxAdapter(
                        child: _buildEmptyState(context, contactsState.searchQuery),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final contact = contactsState.filteredContacts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ContactCard(
                                contact: contact,
                                onTap: () => context.go('/contacts/${contact.id}'),
                              ),
                            );
                          },
                          childCount: contactsState.filteredContacts.length,
                        ),
                      ),
              ),
            
            // Bottom padding for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/contacts/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Contato'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String searchQuery) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'Nenhum contato cadastrado'
                : 'Nenhum contato encontrado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Adicione seu primeiro contato para começar'
                : 'Tente buscar por outro termo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/contacts/add'),
              icon: const Icon(Icons.person_add),
              label: const Text('Adicionar Contato'),
            ),
          ],
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar contatos'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Digite o nome, email ou telefone...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (query) {
            ref.read(contactsControllerProvider.notifier)
                .updateSearchQuery(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(contactsControllerProvider.notifier)
                  .updateSearchQuery('');
              Navigator.of(context).pop();
            },
            child: const Text('Limpar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}