import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/question.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import 'thank_you_screen.dart';
import '../widgets/votus_navigation.dart';

class VotusColors {
  static const red = Color(0xFF8D0801);
  static const darkRed = Color(0xFF791914);

  static const green = Color(0xFF1B623A);

  static const orange = Color(0xFFFF7700);
  static const yellow = Color(0xFFFCC100);

  static const cream = Color(0xFFEDDBBA);

  static const background = Color(0xFFFAF8F3);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}

class SurveyFormScreen extends StatefulWidget {
  const SurveyFormScreen({super.key});

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  final Map<int, String> _answers = {};

  bool _submitting = false;

  bool get _isComplete =>
      _answers.length == surveyQuestions.length;

  int get _answeredCount => _answers.length;

  double get _progress {
    if (surveyQuestions.isEmpty) return 0;
    return _answeredCount / surveyQuestions.length;
  }

  Future<void> _submit() async {
    if (!_isComplete || _submitting) return;

    setState(() {
      _submitting = true;
    });

    try {
      final deviceId = const Uuid().v4();
      final answeredAt = DateTime.now().toIso8601String();

      final answersJson = jsonEncode(
        surveyQuestions.map((q) {
          return {
            'question_id': q.id,
            'answer': _answers[q.id],
          };
        }).toList(),
      );

      // Salva primeiro localmente.
      await DatabaseHelper.instance.insertResponse(
        deviceId: deviceId,
        answersJson: answersJson,
        answeredAt: answeredAt,
      );

      // Tenta sincronizar imediatamente se houver conexão.
      final connectivity =
          await Connectivity().checkConnectivity();

      if (!connectivity.contains(ConnectivityResult.none)) {
        SyncService().syncPending();
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ThankYouScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Não foi possível salvar sua resposta. Tente novamente.',
          ),
          backgroundColor: VotusColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VotusColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Elementos decorativos laterais.
            const Positioned(
              left: -100,
              top: 430,
              child: _DecorativeBlob(
                size: 220,
                color: VotusColors.cream,
              ),
            ),

            const Positioned(
              right: -90,
              top: 760,
              child: _DecorativeBlob(
                size: 190,
                color: VotusColors.yellow,
              ),
            ),

            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SvgPicture.asset(
                    'assets/images/decor-bar.svg',
                    width: double.infinity,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
                ),

                SliverToBoxAdapter(
                  child: _buildHeader(context),
                ),

                SliverToBoxAdapter(
                  child: _buildProgress(context),
                ),

                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 110,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _buildSurvey(context),
                  ),
                ),
              ],
            ),

            // Barra de navegação flutuante.
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: VotusNavigation(
                  currentPage: VotusPage.questions,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 850,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            28,
            20,
            8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/votus-logo.png',
                  width: 400,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: VotusColors.cream,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'VALIDAÇÃO DO PROJETO',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: VotusColors.darkRed,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 34,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: VotusColors.red,
                  ),
                  children: [
                    TextSpan(text: 'Sua opinião '),
                    TextSpan(
                      text: 'ajuda a construir.',
                      style: TextStyle(
                        color: VotusColors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Queremos saber como foi sua experiência com o Votus. '
                'Suas respostas ajudam a tornar o projeto mais claro, '
                'útil e fácil de utilizar.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  height: 1.55,
                  color: Color(0xFF444444),
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _InfoChip(
                    icon: Icons.schedule_outlined,
                    text: 'Menos de 2 minutos',
                  ),
                  _InfoChip(
                    icon: Icons.check_circle_outline,
                    text: 'Não existem respostas certas',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 850,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            26,
            20,
            22,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SUA EXPERIÊNCIA',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: VotusColors.green,
                    ),
                  ),

                  Text(
                    '$_answeredCount de ${surveyQuestions.length}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF777777),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 7,
                  backgroundColor: VotusColors.cream,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    VotusColors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurvey(BuildContext context) {
    return Column(
      children: [
        ...surveyQuestions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _QuestionCard(
              question: question,
              number: index + 1,
              selectedValue: _answers[question.id],
              onChanged: (value) {
                setState(() {
                  _answers[question.id] = value;
                });
              },
            ),
          );
        }),

        const SizedBox(height: 10),

        _buildSubmitButton(),

        const SizedBox(height: 22),

        const Text(
          'Obrigado por ajudar a construir o Votus.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF777777),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final enabled = _isComplete && !_submitting;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: enabled ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: VotusColors.green,
          disabledBackgroundColor: VotusColors.cream,
          disabledForegroundColor: const Color(0xFF9A9A9A),
          foregroundColor: VotusColors.white,
          elevation: enabled ? 3 : 0,
          shadowColor: VotusColors.green.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _submitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(
                    VotusColors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'ENVIAR AVALIAÇÃO',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 21,
                  ),
                ],
              ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final int number;
  final String? selectedValue;
  final ValueChanged<String> onChanged;

  const _QuestionCard({
    required this.question,
    required this.number,
    required this.selectedValue,
    required this.onChanged,
  });

  String _shortOption(String option) {
    final separatorIndex = option.indexOf(' - ');

    if (separatorIndex != -1) {
      return option.substring(0, separatorIndex);
    }

    return option;
  }

  String _longOption(String option) {
    final separatorIndex = option.indexOf(' - ');

    if (separatorIndex != -1) {
      return option.substring(separatorIndex + 3);
    }

    return option;
  }

  @override
  Widget build(BuildContext context) {
    final firstOption =
        question.options.isNotEmpty
            ? _longOption(question.options.first)
            : '';

    final lastOption =
        question.options.isNotEmpty
            ? _longOption(question.options.last)
            : '';

    final isAnswered = selectedValue != null;

    return Container(
      decoration: BoxDecoration(
        color: VotusColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAnswered
              ? VotusColors.green.withOpacity(0.45)
              : VotusColors.cream,
          width: isAnswered ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: number.isEven
                        ? VotusColors.cream
                        : VotusColors.red,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    number.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: number.isEven
                          ? VotusColors.darkRed
                          : VotusColors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 2),
                    child: Text(
                      question.text,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    firstOption,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      height: 1.3,
                      color: Color(0xFF777777),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    lastOption,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      height: 1.3,
                      color: Color(0xFF777777),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall =
                    constraints.maxWidth < 360;

                return Row(
                  children: question.options.map((option) {
                    final selected =
                        selectedValue == option;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right:
                              option ==
                                      question.options.last
                                  ? 0
                                  : isSmall
                                      ? 5
                                      : 8,
                        ),
                        child: _ScaleButton(
                          label: _shortOption(option),
                          description:
                              _longOption(option),
                          selected: selected,
                          onTap: () {
                            onChanged(option);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaleButton extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ScaleButton({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: description,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 56,
            decoration: BoxDecoration(
              color: selected
                  ? VotusColors.green
                  : VotusColors.background,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected
                    ? VotusColors.green
                    : VotusColors.cream,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: VotusColors.green
                            .withOpacity(0.20),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration:
                    const Duration(milliseconds: 180),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? VotusColors.white
                      : VotusColors.green,
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: VotusColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: VotusColors.cream,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: VotusColors.green,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeBlob({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.22),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}