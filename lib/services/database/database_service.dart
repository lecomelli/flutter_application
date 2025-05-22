import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../../data/models/database_models.dart';

part 'database_service.g.dart';

@DriftDatabase(tables: [Contacts, Interactions, Reminders])
class DatabaseService extends _$DatabaseService {
  DatabaseService._() : super(_openConnection());
  
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  
  @override
  int get schemaVersion => 1;
  
  static Future<void> initialize() async {
    // Initialize sqlite3 for mobile platforms
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    
    // Ensure instance is created
    _instance ??= DatabaseService._();
  }
  
  // Contact operations
  Future<List<Contact>> getAllContacts() async {
    return await select(contacts).get();
  }
  
  Future<Contact?> getContactById(int id) async {
    return await (select(contacts)..where((c) => c.id.equals(id))).getSingleOrNull();
  }
  
  Future<int> insertContact(ContactsCompanion contact) async {
    return await into(contacts).insert(contact);
  }
  
  Future<bool> updateContact(ContactsCompanion contact) async {
    return await update(contacts).replace(contact);
  }
  
  Future<int> deleteContact(int id) async {
    return await (delete(contacts)..where((c) => c.id.equals(id))).go();
  }
  
  Future<List<Contact>> searchContacts(String query) async {
    return await (select(contacts)
      ..where((c) => c.name.like('%$query%') | c.email.like('%$query%'))
      ..orderBy([(c) => OrderingTerm(expression: c.name)])).get();
  }
  
  // Interaction operations
  Future<List<Interaction>> getAllInteractions() async {
    return await (select(interactions)
      ..orderBy([(i) => OrderingTerm(expression: i.interactionDate, mode: OrderingMode.desc)])).get();
  }
  
  Future<List<Interaction>> getInteractionsByContactId(int contactId) async {
    return await (select(interactions)
      ..where((i) => i.contactId.equals(contactId))
      ..orderBy([(i) => OrderingTerm(expression: i.interactionDate, mode: OrderingMode.desc)])).get();
  }
  
  Future<int> insertInteraction(InteractionsCompanion interaction) async {
    return await into(interactions).insert(interaction);
  }
  
  Future<int> deleteInteraction(int id) async {
    return await (delete(interactions)..where((i) => i.id.equals(id))).go();
  }
  
  // Reminder operations
  Future<List<Reminder>> getAllReminders() async {
    return await (select(reminders)
      ..where((r) => r.isActive.equals(true))
      ..orderBy([(r) => OrderingTerm(expression: r.reminderDate)])).get();
  }
  
  Future<List<Reminder>> getOverdueReminders() async {
    final now = DateTime.now();
    return await (select(reminders)
      ..where((r) => r.isActive.equals(true) & 
                     r.isCompleted.equals(false) & 
                     r.reminderDate.isSmallerThanValue(now))
      ..orderBy([(r) => OrderingTerm(expression: r.reminderDate)])).get();
  }
  
  Future<int> insertReminder(RemindersCompanion reminder) async {
    return await into(reminders).insert(reminder);
  }
  
  Future<bool> updateReminder(RemindersCompanion reminder) async {
    return await update(reminders).replace(reminder);
  }
  
  Future<int> deleteReminder(int id) async {
    return await (delete(reminders)..where((r) => r.id.equals(id))).go();
  }
  
  // Complex queries
  Future<List<ContactWithLastInteraction>> getContactsWithLastInteraction() async {
    final query = '''
      SELECT c.*, i.interaction_date as last_interaction_date
      FROM contacts c
      LEFT JOIN (
        SELECT contact_id, MAX(interaction_date) as interaction_date
        FROM interactions
        GROUP BY contact_id
      ) i ON c.id = i.contact_id
      ORDER BY c.name
    ''';
    
    final result = await customSelect(query).get();
    return result.map((row) => ContactWithLastInteraction(
      contact: Contact(
        id: row.read<int>('id'),
        name: row.read<String>('name'),
        email: row.readNullable<String>('email'),
        phone: row.readNullable<String>('phone'),
        birthDate: row.readNullable<DateTime>('birth_date'),
        photoPath: row.readNullable<String>('photo_path'),
        notes: row.readNullable<String>('notes'),
        tags: row.read<List<String>>('tags'),
        createdAt: row.read<DateTime>('created_at'),
        updatedAt: row.read<DateTime>('updated_at'),
      ),
      lastInteractionDate: row.readNullable<DateTime>('last_interaction_date'),
    )).toList();
  }
}

// Helper class for complex queries
class ContactWithLastInteraction {
  final Contact contact;
  final DateTime? lastInteractionDate;
  
  ContactWithLastInteraction({
    required this.contact,
    this.lastInteractionDate,
  });
  
  int get daysSinceLastInteraction {
    if (lastInteractionDate == null) return -1;
    return DateTime.now().difference(lastInteractionDate!).inDays;
  }
}

// Database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'laco_db.sqlite'));
    
    // Enable encryption for production
    return NativeDatabase.createInBackground(file);
  });
}