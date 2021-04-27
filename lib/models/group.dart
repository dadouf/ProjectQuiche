import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectquiche/models/app_user.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';

class Group {
  final String? id;

  final AppUser? creator;
  final DateTime? creationDate;

  final String? name;
  final String? coverUrl;

  final List<String>? members;
  final bool? acceptsNewMembers;

  const Group({
    required this.id,
    required this.creator,
    required this.creationDate,
    required this.name,
    required this.coverUrl,
    required this.members,
    required this.acceptsNewMembers,
  });

  static Group fromDocument(DocumentSnapshot doc) {
    var data = doc.data()!;
    return Group(
      id: doc.id,
      creator: AppUser.fromJson(data[MyFirestore.fieldCreator]),
      creationDate: data[MyFirestore.fieldCreationDate].toDate(),
      name: data[MyFirestore.fieldName],
      coverUrl: data[MyFirestore.fieldCoverUrl],
      members: List<String>.from(data[MyFirestore.fieldMembers]),
      acceptsNewMembers: data[MyFirestore.fieldAcceptsNewMembers],
    );
  }
}
