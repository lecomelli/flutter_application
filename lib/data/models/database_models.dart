import 'package:drift/drift.dart';

// Contact table
class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get tags => text().map(TagsConverter()).withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Interaction table
class Interactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId => integer().references(Contacts, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()(); // call, whatsapp, email, in_person, etc
  TextColumn get channel => text()(); // whatsapp, telegram, phone, email, etc
  TextColumn get description => text().nullable()();
  DateTimeColumn get interactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Reminder table
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId => integer().references(Contacts, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get reminderDate => dateTime()();
  IntColumn get frequencyDays => integer().nullable()(); // null = one-time reminder
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Converter for tags (List<String> to JSON)
class TagsConverter extends TypeConverter<List<String>, String> {
  const TagsConverter();
  
  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    // Simple JSON-like parsing for tags
    final cleaned = fromDb.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
    if (cleaned.isEmpty) return [];
    return cleaned.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  @override
  String toSql(List<String> value) {
    if (value.isEmpty) return '[]';
    return '[${value.map((e) => '"$e"').join(',')}]';
  }
}

// Enums for interaction types and channels
enum InteractionType {
  call('call', 'Ligação'),
  message('message', 'Mensagem'),
  meeting('meeting', 'Encontro'),
  email('email', 'E-mail'),
  note('note', 'Anotação');
  
  const InteractionType(this.value, this.displayName);
  final String value;
  final String displayName;
}

enum InteractionChannel {
  whatsapp('whatsapp', 'WhatsApp'),
  telegram('telegram', 'Telegram'),
  phone('phone', 'Telefone'),
  email('email', 'E-mail'),
  inPerson('in_person', 'Presencial'),
  linkedin('linkedin', 'LinkedIn'),
  instagram('instagram', 'Instagram'),
  other('other', 'Outro');
  
  const InteractionChannel(this.value, this.displayName);
  final String value;
  final String displayName;
  
  IconData get icon {
    switch (this) {
      case InteractionChannel.whatsapp:
        return Icons.chat;
      case InteractionChannel.telegram:
        return Icons.telegram;
      case InteractionChannel.phone:
        return Icons.phone;
      case InteractionChannel.email:
        return Icons.email;
      case InteractionChannel.inPerson:
        return Icons.person;
      case InteractionChannel.linkedin:
        return Icons.work;
      case InteractionChannel.instagram:
        return Icons.camera_alt;
      case InteractionChannel.other:
        return Icons.more_horiz;
    }
  }
}