import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sos_app/core/services/auth/auth_firebase_service.dart';
import 'package:sos_app/models/sos_user.dart';

abstract class AuthService {
  SOSUser? get currentUser;

  Stream<SOSUser?> get userChanges;

  Future<void> signup(
    String name,
    double lat,
    double long,
    String cpf,
    String cep,
    String uf,
    String city,
    String phone,
    String email,
    String password,
    File? image,
    BuildContext ctx,
  );

  Future<bool> login(String email, String password);

  Future<void> logout(bool isDeleted);

  Future<SOSUser> getUserData(String userId);

  Future<void> update(String userId, String name, String email, String password, double lat, double long, String cep, String uf, String city, String phone, File? image);

  Future<void> updateEmailAndPassword(String currentEmail, String currentPassword, {String? newEmail, String? newPassword});

  Future<void> updatePassword(String userId, String currentPassword, String newPassword);

  Future<String> checkPassword(String currentPassword);

  Future<void> checkToken(String token);

  Future<void> deleteAccount(String userId);

  factory AuthService() {
    // return AuthMockService();
    return AuthFirebaseService();
  }
}
