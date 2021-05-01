import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectquiche/data/app_user.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';

class Group {
  final String id;

  final AppUser creator;
  final DateTime? creationDate;

  final String name;
  final String? coverUrl;

  final List<AppUser> members;
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

    final memberIds = List<String>.from(data[MyFirestore.fieldMembers]);
    final membersInfo = data[MyFirestore.fieldMembersInfo];

    final members = memberIds
        .map((uid) => AppUser.fromJson(membersInfo[uid], userId: uid))
        .toList();

    return Group(
      id: doc.id,
      creator: AppUser.fromJson(data[MyFirestore.fieldCreator]),
      creationDate: data[MyFirestore.fieldCreationDate].toDate(),
      name: data[MyFirestore.fieldName],
      coverUrl: data[MyFirestore.fieldCoverUrl],
      members: members,
      acceptsNewMembers: data[MyFirestore.fieldAcceptsNewMembers],
    );
  }
}
