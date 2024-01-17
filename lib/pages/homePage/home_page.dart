// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sos_app/core/extension/animated_route.dart';
import 'package:sos_app/core/services/location/current_location.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/pages/Chat/milo_page.dart';
import 'package:sos_app/pages/homePage/pages/lost/lost_page.dart';
import 'package:sos_app/pages/homePage/pages/lost/lost_post.dart';
import 'package:sos_app/pages/homePage/pages/missing/missing_page.dart';
import 'package:sos_app/pages/homePage/pages/missing/missing_post.dart';
import 'package:sos_app/pages/homePage/pages/profile/profile_page.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  final int setRoutePage;
  final bool isPeople;

  const HomePage(
      {super.key, required this.setRoutePage, required this.isPeople});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  late PageController pageEC;

  @override
  void initState() {
    super.initState();
    currentPage = widget.setRoutePage;
    pageEC = PageController(initialPage: currentPage);
    CurrentLocation.getLocation(context); // Verifica a localização do User
    _startGetLocation();
  }

  // Checa constantemente a localização do usuário
  void _startGetLocation() {
    Future.delayed(const Duration(minutes: 10), () {
      CurrentLocation.getLocation(context);
      _startGetLocation(); // Inicia o próximo temporizador
    });}

  @override
  void dispose() {
    pageEC.dispose();
    super.dispose();
  }

  setCurrentPage(page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: pageEC,
          onPageChanged: setCurrentPage,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            MissingPage(isPeople: widget.isPeople),
            LostPage(isPeople: widget.isPeople),
            const MiloPage(),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(
              top:
                  BorderSide(color: ColorsApp.instance.previewText, width: 0.5),
            ),
            color: Colors.white),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          currentIndex: currentPage,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt), label: 'Desaparecidos'),
            BottomNavigationBarItem(
                icon: Icon(Icons.fmd_bad), label: 'Perdidos'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Milo'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
          onTap: (page) {
            pageEC.animateToPage(page,
                duration: const Duration(milliseconds: 400),
                curve: Curves.ease);
          },
          iconSize: 25,
        ),
      ),
      floatingActionButton: (currentPage == 0 || currentPage == 1)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    currentPage == 0
                        ? AnimatedRoute(const MissingPost())
                        : AnimatedRoute(const LostPost()));
              },
              backgroundColor: ColorsApp.instance.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
