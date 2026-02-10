import 'package:flutter/material.dart';

enum UserRole {
  admin,
  manager,
  supervisor,
  worker,
  viewer
}

enum UserStatus {
  active,
  inactive,
  suspended
}

class User {
  int? id;
  String email;
  String displayName;
  UserRole role;
  UserStatus status;
  
  User({
    this.id,
    required this.email,
    required this.displayName,
    this.role = UserRole.worker,
    this.status = UserStatus.active,
  });
  
  bool get isAdmin => role == UserRole.admin;
  bool get isWorker => role == UserRole.worker;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'role': role.name,
    'status': status.name,
  };
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    displayName: json['displayName'],
    role: UserRole.values.firstWhere((e) => e.name == json['role'], orElse: () => UserRole.worker),
    status: UserStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => UserStatus.active),
  );
}