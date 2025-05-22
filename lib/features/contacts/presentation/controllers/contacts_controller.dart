import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/contact_model.dart';
import '../../data/repositories/contacts_repository.dart';

// State classes
class ContactsState {
  final List<ContactModel> contacts;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const ContactsState({
    this.contacts = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  ContactsState copyWith({
    List<ContactModel>? contacts,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<ContactModel> get filteredContacts {
    if (searchQuery.isEmpty) return contacts;
    
    return contacts.where((contact) {
      final query = searchQuery.toLowerCase();
      return contact.name.toLowerCase().contains(query) ||
             (contact.email?.toLowerCase().contains(query) ?? false) ||
             (contact.phone?.contains(query) ?? false) ||
             contact.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }
}

// Contacts controller
class ContactsController extends StateNotifier<ContactsState> {
  final ContactsRepository _repository;

  ContactsController(this._repository) : super(const ContactsState()) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final contacts = await _repository.getAllContacts();
      contacts.sort((a, b) => a.name.compareTo(b.name));
      
      state = state.copyWith(
        contacts: contacts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createContact(ContactModel contact) async {
    try {
      final newContact = await _repository.createContact(contact);
      final updatedContacts = [...state.contacts, newContact];
      updatedContacts.sort((a, b) => a.name.compareTo(b.name));
      
      state = state.copyWith(contacts: updatedContacts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateContact(ContactModel contact) async {
    try {
      final updatedContact = await _repository.updateContact(contact);
      final updatedContacts = state.contacts
          .map((c) => c.id == updatedContact.id ? updatedContact : c)
          .toList();
      updatedContacts.sort((a, b) => a.name.compareTo(b.name));
      
      state = state.copyWith(contacts: updatedContacts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      await _repository.deleteContact(id);
      final updatedContacts = state.contacts
          .where((c) => c.id != id)
          .toList();
      
      state = state.copyWith(contacts: updatedContacts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final contactsControllerProvider = StateNotifierProvider<ContactsController, ContactsState>((ref) {
  final repository = ref.read(contactsRepositoryProvider);
  return ContactsController(repository);
});

// Individual contact provider
final contactByIdProvider = FutureProvider.family<ContactModel?, int>((ref, id) async {
  final repository = ref.read(contactsRepositoryProvider);
  return await repository.getContactById(id);
});

// Tags provider
final allTagsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.read(contactsRepositoryProvider);
  return await repository.getAllTags();
});

// Upcoming birthdays provider
final upcomingBirthdaysProvider = FutureProvider<List<ContactModel>>((ref) async {
  final repository = ref.read(contactsRepositoryProvider);
  return await repository.getUpcomingBirthdays();
});

// Contacts with last interaction provider
final contactsWithLastInteractionProvider = 
    FutureProvider<List<ContactWithLastInteractionModel>>((ref) async {
  final repository = ref.read(contactsRepositoryProvider);
  return await repository.getContactsWithLastInteraction();
});