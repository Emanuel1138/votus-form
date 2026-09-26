import 'package:flutter/material.dart';

import '../screens/results_screen.dart';
import '../screens/survey_form_screen.dart';

class VotusColors {
  static const red = Color(0xFF8D0801);
  static const white = Color(0xFFFFFFFF);
  static const orange = Color(0xFFFF7700);
  static const green = Color(0xFF1B623A);
  static const cream = Color(0xFFEDDBBA);
  static const darkRed = Color(0xFF791914);
  static const yellow = Color(0xFFFCC100);
}

enum VotusPage {
  questions,
  results,
}

class VotusNavigation extends StatelessWidget {
  final VotusPage currentPage;

  const VotusNavigation({
    super.key,
    required this.currentPage,
  });

  void _goTo(
    BuildContext context,
    VotusPage page,
  ) {
    if (page == currentPage) return;

    final Widget destination;

    switch (page) {
      case VotusPage.questions:
        destination = const SurveyFormScreen();
        break;

      case VotusPage.results:
        destination = const ResultsScreen();
        break;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => destination,
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: VotusColors.cream,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavigationItem(
              icon: Icons.assignment_outlined,
              activeIcon: Icons.assignment_rounded,
              label: 'Perguntas',
              active: currentPage == VotusPage.questions,
              onTap: () => _goTo(
                context,
                VotusPage.questions,
              ),
            ),

            _NavigationItem(
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart_rounded,
              label: 'Resultados',
              active: currentPage == VotusPage.results,
              onTap: () => _goTo(
                context,
                VotusPage.results,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFA51A12),
                    VotusColors.red,
                  ],
                )
              : null,
          color: active ? null : Colors.transparent,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: VotusColors.red.withOpacity(0.24),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                active ? activeIcon : icon,
                key: ValueKey(active),
                size: 18,
                color: active
                    ? VotusColors.white
                    : VotusColors.darkRed,
              ),
            ),

            const SizedBox(width: 7),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: active
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: active
                    ? VotusColors.white
                    : const Color(0xFF555555),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}