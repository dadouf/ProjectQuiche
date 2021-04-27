import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectquiche/services/firebase/firestore_keys.dart';
import 'package:projectquiche/ui/app_icons.dart';

class AppUser {
  final String uid;
  final String username;
  final String? avatarUrl;
  final AvatarType? avatarType;

  AppUser({
    required this.uid,
    required this.username,
    required this.avatarUrl,
    required this.avatarType,
  });

  static AppUser fromDocument(DocumentSnapshot doc) {
    var data = doc.data()!;
    return AppUser(
      uid: doc.id,
      username: data[MyFirestore.fieldUsername],
      avatarUrl: data[MyFirestore.fieldAvatarUrl],
      avatarType: AvatarType.from(data[MyFirestore.fieldAvatarSymbol]),
    );
  }

  static fromJson(Map<String, dynamic> data) => AppUser(
        uid: data[MyFirestore.fieldUserId],
        username: data[MyFirestore.fieldUsername],
        avatarType: AvatarType.from(data[MyFirestore.fieldAvatarSymbol]),
        avatarUrl: data[MyFirestore.fieldAvatarUrl],
      );

  Map<String, dynamic> toJson() => {
        MyFirestore.fieldUserId: uid,
        MyFirestore.fieldUsername: username,
        MyFirestore.fieldAvatarSymbol: avatarType?.code,
        MyFirestore.fieldAvatarUrl: avatarUrl,
      };
}

class AvatarType {
  final String code;
  final IconData? icon;

  const AvatarType._(this.code, this.icon);

  static const custom = AvatarType._("custom", null);
  static const chef_hat = AvatarType._("chef_hat", AppIcons.chef_hat);
  static const salt_and_pepper =
      AvatarType._("salt_and_pepper", AppIcons.salt_and_pepper);
  static const food_tray = AvatarType._("food_tray", AppIcons.food_tray);

  static const values = [custom, chef_hat, salt_and_pepper, food_tray];

  static AvatarType? from(String? avatarSymbol) {
    return values.firstWhere((element) => element.code == avatarSymbol);
  }
}
