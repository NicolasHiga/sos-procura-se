import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/auth/auth_service.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:sos_app/pages/homePage/pages/profile/components/custom_call_button.dart';
import 'package:sos_app/pages/homePage/pages/profile/components/custom_icon_button.dart';
import 'package:sos_app/pages/homePage/pages/profile/pages/edit_page.dart';
import 'package:sos_app/pages/homePage/pages/profile/pages/my_posts.dart';
import 'package:sos_app/pages/homePage/pages/profile/pages/new_password_page.dart';

class ProfileOptions extends StatelessWidget {
  static const _defaultImage = 'assets/images/avatar.png';

  const ProfileOptions({super.key});

  ImageProvider _showUserImage(String imageURL) {
    ImageProvider? provider;
    final uri = Uri.parse(imageURL);

    if (uri.path.contains('assets/images/avatar.png')) {
      provider = const AssetImage(_defaultImage);
    } else if (uri.scheme.contains('http')) {
      provider = NetworkImage(uri.toString());
    } else {
      provider = FileImage(File(uri.toString()));
    }

    return provider;
  }

  @override
  Widget build(BuildContext context) {
    final sessionUser = Provider.of<UserStore>(context, listen: false);
    ImageProvider userImage = _showUserImage(sessionUser.currentUser!.imageURL);
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.all(15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ColorsApp.instance.secondary),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: userImage,
                        radius: 38,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sessionUser.currentUser!.name.toUpperCase(),
                        style:
                            TextStyles.instance.textBold.copyWith(fontSize: 18),
                      ),
                      Text(
                          '${sessionUser.currentUser!.city}, ${sessionUser.currentUser!.uf}',
                          style: TextStyles.instance.textRegular
                              .copyWith(fontSize: 13)),
                      Text(sessionUser.currentUser!.cep,
                          style: TextStyles.instance.textRegular
                              .copyWith(fontSize: 13)),
                    ],
                  )),
              const SizedBox(height: 12),
              const CustomIconButton(
                  icon: Icons.article,
                  text: 'Minha postagens',
                  page: MyPosts()),
              const SizedBox(height: 12),
              CustomIconButton(
                  icon: Icons.admin_panel_settings,
                  text: 'Dados pessoais',
                  page: EditPage(
                    userImage: userImage,
                  )),
              const SizedBox(height: 12),
              const CustomIconButton(
                  icon: Icons.lock,
                  text: 'Alterar senha',
                  page: UpdatePassword(
                  )),
              const SizedBox(height: 12),
              CustomCallButton(
                icon: Icons.local_police_outlined,
                text: 'Ligar para Polícia',
                phoneNumber: '190',
                ctx: context,
              ),
              const SizedBox(height: 12),
              CustomCallButton(
                icon: Icons.emergency_outlined,
                text: 'Ligar para SAMU',
                phoneNumber: '192',
                ctx: context,
              ),
              const SizedBox(height: 12),
              CustomCallButton(
                icon: Icons.fire_truck_outlined,
                text: 'Ligar para Bombeiro',
                phoneNumber: '193',
                ctx: context,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService().logout(false);
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text(
                    'Sair',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
