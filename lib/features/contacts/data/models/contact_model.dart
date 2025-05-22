import 'package:equatable/equatable.dart';

class ContactModel extends Equatable {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? photoPath;
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContactModel({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.birthDate,
    this.photoPath,
    this.notes,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  ContactModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? photoPath,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Age calculation
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // Birthday helpers
  bool get hasBirthdayToday {
    if (birthDate == null) return false;
    final now = DateTime.now();
    return birthDate!.month == now.month && birthDate!.day == now.day;
  }

  DateTime? get nextBirthday {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var next = DateTime(now.year, birthDate!.month, birthDate!.day);
    if (next.isBefore(now)) {
      next = DateTime(now.year + 1, birthDate!.month, birthDate!.day);
    }
    return next;
  }

  int? get daysUntilBirthday {
    final next = nextBirthday;
    if (next == null) return null;
    return next.difference(DateTime.now()).inDays;
  }

  // Contact info helpers
  String get displayName => name;
  
  String get initials {
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '';
    }
    return (words.first.isNotEmpty ? words.first[0] : '') +
           (words.last.isNotEmpty ? words.last[0] : '');
  }

  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasEmail => email != null && email!.isNotEmpty;
  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;
  bool get hasNotes => notes != null && notes!.isNotEmpty;
  bool get hasTags => tags.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        birthDate,
        photoPath,
        notes,
        tags,
        createdAt,
        updatedAt,
      ];
}