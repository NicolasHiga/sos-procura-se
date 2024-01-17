import 'package:flutter/material.dart';

class SlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastLinearToSlowEaseIn,
                  reverseCurve: Curves.fastOutSlowIn,
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        );
}