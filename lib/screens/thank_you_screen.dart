import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'survey_form_screen.dart';

class VotusColors {
  static const red = Color(0xFF8D0801);
  static const white = Color(0xFFFFFFFF);
  static const orange = Color(0xFFFF7700);
  static const green = Color(0xFF1B623A);
  static const cream = Color(0xFFEDDBBA);
  static const darkRed = Color(0xFF791914);
  static const yellow = Color(0xFFFCC100);
}

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VotusColors.cream,
      body: Stack(
        children: [
          // ==============================================================
          // BACKGROUND SVG
          // ==============================================================
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/background.svg',
              fit: BoxFit.cover,
            ),
          ),

          // ==============================================================
          // LEVE CAMADA SOBRE O BACKGROUND
          // ==============================================================
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.12),
            ),
          ),

          // ==============================================================
          // CONTEÚDO
          // ==============================================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 620,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ==================================================
                      // LOGO
                      // ==================================================
                      Image.asset(
                        'assets/images/votus-logo.png',
                        width: 400,
                        height: 80,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // CARD
                      // ==================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          28,
                          34,
                          28,
                          28,
                        ),
                        decoration: BoxDecoration(
                          color: VotusColors.white.withOpacity(0.90),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: VotusColors.cream,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 35,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // ============================================
                            // TÍTULO
                            // ============================================
                            const Text(
                              'Obrigado por\nfazer parte.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 36,
                                height: 1.05,
                                fontWeight: FontWeight.w800,
                                color: VotusColors.red,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ============================================
                            // SUBTÍTULO
                            // ============================================
                            const Text(
                              'Sua opinião ajuda a construir o Votus.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 17,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                                color: VotusColors.green,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // ============================================
                            // BOTÃO
                            // ============================================
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SurveyFormScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VotusColors.red,
                                  foregroundColor: VotusColors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Fazer uma nova resposta',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 21,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}