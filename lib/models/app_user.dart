import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';

class AppUser {
  final String uid;
  final String username;
  final String? avatarUrl;
  final String? avatarSymbol;

  AppUser({
    required this.uid,
    required this.username,
    this.avatarUrl,
    this.avatarSymbol,
  });

  static AppUser fromDocument(DocumentSnapshot doc) {
    var data = doc.data()!;
    return AppUser(
      uid: doc.id,
      username: data[MyFirestore.fieldUsername],
      avatarUrl: data[MyFirestore.fieldAvatarUrl],
      avatarSymbol: data[MyFirestore.fieldAvatarSymbol],
    );
  }
}

class AvatarType {
  final String code;

  const AvatarType._(this.code);

  static const social = AvatarType._("social");
  static const chef_hat = AvatarType._("chef_hat");
  static const salt_and_pepper = AvatarType._("salt_and_pepper");
  static const food_tray = AvatarType._("food_tray");
}
