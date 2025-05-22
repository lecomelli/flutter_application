import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/database/database_service.dart';
import '../models/contact_model.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepository(DatabaseService.instance);
});

class ContactsRepository {
  final DatabaseService _database;

  ContactsRepository(this._database);

  // Get all contacts
  Future<List<ContactModel>> getAllContacts() async {
    final contacts = await _database.getAllContacts();
    return contacts.map(_contactToModel).toList();
  }

  // Get contact by id
  Future<ContactModel?> getContactById(int id) async {
    final contact = await _database.getContactById(id);
    return contact != null ? _contactToModel(contact) : null;
  }

  // Create contact
  Future<ContactModel> createContact(ContactModel contact) async {
    final companion = _modelToCompanion(contact);
    final id = await _database.insertContact(companion);
    
    final createdContact = await _database.getContactById(id);
    return _contactToModel(createdContact!);
  }

  // Update contact
  Future<ContactModel> updateContact(ContactModel contact) async {
    if (contact.id == null) {
      throw ArgumentError('Contact ID cannot be null for update');
    }
    
    final companion = _modelToCompanion(contact.copyWith(
      updatedAt: DateTime.now(),
    ));
    
    await _database.updateContact(companion);
    
    final updatedContact = await _database.getContactById(contact.id!);
    return _contactToModel(updatedContact!);
  }

  // Delete contact
  Future<void> deleteContact(int id) async {
    await _database.deleteContact(id);
  }

  // Search contacts
  Future<List<ContactModel>> searchContacts(String query) async {
    final contacts = await _database.searchContacts(query);
    return contacts.map(_contactToModel).toList();
  }

  // Get contacts with last interaction info
  Future<List<ContactWithLastInteractionModel>> getContactsWithLastInteraction() async {
    final contactsWithInteraction = await _database.getContactsWithLastInteraction();
    return contactsWithInteraction.map((item) => ContactWithLastInteractionModel(
      contact: _contactToModel(item.contact),
      lastInteractionDate: item.lastInteractionDate,
      daysSinceLastInteraction: item.daysSinceLastInteraction,
    )).toList();
  }

  // Get contacts by tag
  Future<List<ContactModel>> getContactsByTag(String tag) async {
    final allContacts = await getAllContacts();
    return allContacts.where((contact) => contact.tags.contains(tag)).toList();
  }

  // Get all unique tags
  Future<List<String>> getAllTags() async {
    final contacts = await getAllContacts();
    final Set<String> tags = {};
    
    for (final contact in contacts) {
      tags.addAll(contact.tags);
    }
    
    return tags.toList()..sort();
  }

  // Get contacts with upcoming birthdays
  Future<List<ContactModel>> getUpcomingBirthdays({int daysAhead = 30}) async {
    final contacts = await getAllContacts();
    final now = DateTime.now();
    final cutoffDate = now.add(Duration(days: daysAhead));
    
    return contacts.where((contact) {
      if (contact.birthDate == null) return false;
      
      final birthday = contact.nextBirthday;
      if (birthday == null) return false;
      
      return birthday.isAfter(now) && birthday.isBefore(cutoffDate);
    }).toList()
      ..sort((a, b) {
        final aDays = a.daysUntilBirthday ?? 999;
        final bDays = b.daysUntilBirthday ?? 999;
        return aDays.compareTo(bDays);
      });
  }

  // Helper methods
  ContactModel _contactToModel(Contact contact) {
    return ContactModel(
      id: contact.id,
      name: contact.name,
      email: contact.email,
      phone: contact.phone,
      birthDate: contact.birthDate,
      photoPath: contact.photoPath,
      notes: contact.notes,
      tags: contact.tags,
      createdAt: contact.createdAt,
      updatedAt: contact.updatedAt,
    );
  }

  ContactsCompanion _modelToCompanion(ContactModel model) {
    return ContactsCompanion(
      id: model.id != null ? Value(model.id!) : const Value.absent(),
      name: Value(model.name),
      email: Value(model.email),
      phone: Value(model.phone),
      birthDate: Value(model.birthDate),
      photoPath: Value(model.photoPath),
      notes: Value(model.notes),
      tags: Value(model.tags),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }
}

// Helper class for contacts with interaction data
class ContactWithLastInteractionModel {
  final ContactModel contact;
  final DateTime? lastInteractionDate;
  final int daysSinceLastInteraction;

  ContactWithLastInteractionModel({
    required this.contact,
    this.lastInteractionDate,
    required this.daysSinceLastInteraction,
  });

  bool get needsAttention => daysSinceLastInteraction > 30;
  bool get recentlyContacted => daysSinceLastInteraction <= 7;
}