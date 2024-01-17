import 'package:flutter/material.dart';
import 'package:sos_app/pages/homePage/pages/profile/components/profile_options.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {            
          });
        },
        child: const ProfileOptions(),
      ),
    );
  }
}
