import 'package:flutter/material.dart';

class AppAnimations {
  // Базовая анимация появления
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Анимация скольжения сверху
  static Widget slideInFromTop({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
    double offset = 50.0,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(
        begin: Offset(0, -offset),
        end: Offset.zero,
      ),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Анимация скольжения снизу
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutCubic,
    double offset = 50.0,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(
        begin: Offset(0, offset),
        end: Offset.zero,
      ),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Анимация масштабирования
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutBack,
    double beginScale = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginScale, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Комбинированная анимация (появление + скольжение)
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutCubic,
    Offset offset = const Offset(0, 30),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(offset.dx, offset.dy * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Анимация для карточек (появление с задержкой)
  static Widget staggeredCard({
    required Widget child,
    required int index,
    Duration baseDuration = const Duration(milliseconds: 300),
    Duration delayPerItem = const Duration(milliseconds: 100),
  }) {
    final delay = Duration(milliseconds: index * delayPerItem.inMilliseconds);
    final totalDuration = baseDuration + delay;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: totalDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  // Пульсирующая анимация
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    double minScale = 0.95,
    bool infinite = true,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: minScale),
      duration: duration,
      curve: Curves.easeInOutSine,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
      onEnd: infinite ? () {
        pulse(
          child: child,
          duration: duration,
          minScale: minScale,
          infinite: true,
        );
      } : null,
    );
  }

  // Анимация наклона (для интересных эффектов)
  static Widget tiltIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double angle = 0.1,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -angle, end: 0.0),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

// Специальный виджет для анимированных переходов между страницами
class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final RouteType routeType;

  CustomPageRoute({
    required this.page,
    this.routeType = RouteType.slide,
  }) : super(
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) => page,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      switch (routeType) {
        case RouteType.slide:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        case RouteType.fade:
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        case RouteType.scale:
          return ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            )),
            child: child,
          );
        case RouteType.rotate:
          return RotationTransition(
            turns: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
      }
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

enum RouteType {
  slide,
  fade,
  scale,
  rotate,
}