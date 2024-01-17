import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/auth/auth_service.dart';
import 'package:sos_app/core/services/user/user_state.dart';
import 'package:sos_app/models/sos_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebaseService implements AuthService {
  late bool isNewUser;
  static SOSUser? _currentUser;
  static final _userStream = Stream<SOSUser?>.multi((controller) async {
    final authChanges = FirebaseAuth.instance.authStateChanges();
    await for (final user in authChanges) {
      _currentUser = user == null ? null : _toSOSUser(user);
      controller.add(_currentUser);
    }
  });

  @override
  SOSUser? get currentUser {
    return _currentUser;
  }

  @override
  Stream<SOSUser?> get userChanges {
    return _userStream;
  }

  @override
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
  ) async {
    try {
      UserState userState = Provider.of<UserState>(ctx, listen: false);
      userState.setShouldFetchUserData(false);

      final auth = FirebaseAuth.instance;
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return;

      // Upload da foto do usuário
      final imageName = '${credential.user!.uid}.jpg';
      final imageURL = await _uploadUserImage(image, imageName);

      await credential.user?.updatePhotoURL(imageURL);
      await credential.user?.updateDisplayName(name);
      //salvar dados do usuário no Firestore
      await _saveSOSUser(_toSOSUser(
        credential.user!,
        name,
        lat,
        long,
        cpf,
        cep,
        uf,
        city,
        phone,
        credential.user!.email,
        imageURL,
      ));

      userState.setShouldFetchUserData(true);
    } catch (e) {
      log('Erro ao tentar realizar o signup: $e');
      throw Exception(e);
    }
  }

  @override
  Future<bool> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout(bool isDeleted) async {
    if (!isDeleted) {
      await _deleteToken();
    }
    await FirebaseAuth.instance.signOut();
  }

  Future<String?> _uploadUserImage(File? image, String imageName) async {
    if (image == null) return null;
    
    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('user_images').child(imageName);
    await imageRef.putFile(image).whenComplete(() {});
    return await imageRef.getDownloadURL();
  }

  Future<void> _saveSOSUser(SOSUser user) async {
    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.id);

    return await docRef.set({
      'name': user.name,
      'lat': user.lat,
      'long': user.long,
      'cep': user.cep,
      'cpf': user.cpf,
      'uf': user.uf,
      'city': user.city,
      'phone': user.phone,
      'email': user.email,
      'imageURL': user.imageURL,
      'token': '',
    });
  }

  @override
  Future<SOSUser> getUserData(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      final userCpf = userData['cpf'];
      return SOSUser(
          id: userId,
          name: userData['name'],
          lat: userData['lat'],
          long: userData['long'],
          cpf: '***${userCpf.substring(3, 12)}**',
          cep: userData['cep'],
          uf: userData['uf'],
          city: userData['city'],
          phone: userData['phone'],
          email: userData['email'],
          imageURL: userData['imageURL']);
    } else {
      throw Exception('User not found');
    }
  }

  static SOSUser _toSOSUser(User user,
      [String? name,
      double? lat,
      double? long,
      String? cpf,
      String? cep,
      String? uf,
      String? city,
      String? phone,
      String? email,
      String? imageURL]) {
    return SOSUser(
      id: user.uid,
      name: name ?? user.displayName ?? '',
      lat: lat ?? 0.0,
      long: long ?? 0.0,
      cpf: cpf ?? '',
      cep: cep ?? '',
      uf: uf ?? '',
      city: city ?? '',
      phone: phone ?? '',
      email: email ?? user.email ?? '',
      imageURL: imageURL ?? user.photoURL ?? 'assets/images/avatar.png',
    );
  }

  @override
  Future<void> update(
      String userId,
      String name,
      String email,
      String password,
      double lat,
      double long,
      String cep,
      String uf,
      String city,
      String phone,
      File? image) async {
    // Verifique os campos modificados e atualize apenas se necessário
    final Map<String, dynamic> updatedData = {};

    final user = FirebaseAuth.instance.currentUser;
    final credentials = EmailAuthProvider.credential(
      email: _currentUser!.email,
      password: password,
    );
    await user!.reauthenticateWithCredential(credentials);

    if (name.isEmpty) {
      updatedData['name'] = _currentUser!.name;
    } else {
      updatedData['name'] = name;
      user.updateDisplayName(name);
    }

    updatedData['phone'] = phone;
    updatedData['city'] = city;
    updatedData['cep'] = cep;
    updatedData['uf'] = uf;
    updatedData['lat'] = lat;
    updatedData['long'] = long;

    // Upload da foto do usuário se houver mudança
    if (image != null) {
      final imageName = '$userId.jpg';
      final imageURL = await _uploadUserImage(image, imageName);
      updatedData['imageURL'] = imageURL;
      user.updatePhotoURL(imageURL);
    } else {
      updatedData['imageURL'] = _currentUser!.imageURL;
    }

    if (email.isEmpty) {
      updatedData['email'] = _currentUser!.email;
    } else {
      try {
        updatedData['email'] = email;
        updateEmailAndPassword(_currentUser!.email, password, newEmail: email);
      } catch (e) {
        throw Exception('Não foi possível atualizar o authenticator.');
      }
    }

    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(userId);

    return docRef.update(updatedData);
  }

  @override
  Future<void> updatePassword(
      String userId, String currentPassword, String newPassword) async {
    try {
      final store = FirebaseFirestore.instance;
      final docRef = store.collection('users').doc(userId);

      await updateEmailAndPassword(_currentUser!.email, currentPassword,
          newPassword: newPassword);

      return docRef.update({'password': newPassword});
    } catch (e) {
      throw Exception('Não foi possível atualizar a senha no Banco de dados.');
    }
  }

  @override
  Future<void> updateEmailAndPassword(
      String currentEmail, String currentPassword,
      {String? newEmail, String? newPassword}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuário não encontrado.');
    }

    try {
      //Reautenticar o usuário antes de atualizar e-mail ou senha
      final credentials = EmailAuthProvider.credential(
        email: currentEmail,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credentials);

      if (newEmail != null) {
        await user.updateEmail(newEmail);
      }

      if (newPassword != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      log('Erro ao atualizar e-mail ou senha: $e');
      throw Exception('Não foi possível atualizar o e-mail ou a senha.');
    }
  }

  @override
  Future<String> checkPassword(String currentPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Usuário não encontrado.');
      }
      // Verifique a senha atual
      final email = user.email;
      final credential = EmailAuthProvider.credential(
          email: email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      return 'check';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        log('Senha atual incorreta.');
        return 'wrong';
      } else {
        log('Erro ao alterar a senha: ${e.code}');
        return 'error';
      }
    } catch (e) {
      log('Erro inesperado: $e');
      return 'error';
    }
  }

  @override
  Future<void> checkToken(String token) async {
    String userId = _currentUser!.id;
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    try {
      DocumentSnapshot userSnapshot = await usersCollection.doc(userId).get();
      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>?;
        String storageToken = data!['token'];
        // Compara se o token salvo é igual ao novo token
        if (storageToken != token) {
          try {
            await usersCollection.doc(userId).update({
              'token': token,
            });
            log('Token atualizado com sucesso.');
          } catch (e) {
            throw Exception('Erro ao atualizar o token: $e');
          }
        } else {
          return;
        }
      } else {
        throw Exception('Documento não encontrado.');
      }
    } catch (e) {
      throw Exception('Erro ao obter o token: $e');
    }
  }

  Future<void> _deleteToken() async {
    String userId = _currentUser!.id;
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    try {
      await usersCollection.doc(userId).update({
        'token': '',
      });
      log('Token apagado com sucesso.');
    } catch (e) {
      throw Exception('Erro ao apagar o token: $e');
    }
  }

  @override
  Future<void> deleteAccount(String userId) async {
    try {
      //Excluir os dados do Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Excluir a conta no Firebase Authentication
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
      log("Conta deletada");
    } catch (e) {
      log("Erro ao deletar conta");
      throw Exception("Erro ao deletar conta: $e");
    }
  }
}
