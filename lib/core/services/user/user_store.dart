import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/auth/auth_firebase_service.dart';
import 'package:sos_app/core/services/user/user_state.dart';
import 'package:sos_app/models/sos_user.dart';

class UserStore extends ChangeNotifier {
  SOSUser? currentUser;

  Future<void> fetchUserData(String userId, BuildContext ctx) async {
    final userState = Provider.of<UserState>(ctx, listen: false);

    if (!userState.shouldFetchUserData){
      await Future.delayed(const Duration(seconds: 4));
    }
    SOSUser user = await AuthFirebaseService().getUserData(userId);
    currentUser = user;
  }
}

final userStore = UserStore();
