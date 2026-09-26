import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/question.dart';
import '../services/results_service.dart';
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

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<Map<int, Map<String, int>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ResultsService().fetchSummary();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ResultsService().fetchSummary();
    });
    await _future;
  }

  int _totalResponses(Map<int, Map<String, int>> summary) {
    if (summary.isEmpty) return 0;

    // Usa a primeira pergunta como referência de total, já que
    // toda resposta enviada responde todas as perguntas.
    final first = summary.values.first;
    return first.values.fold(0, (sum, count) => sum + count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VotusColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              left: -100,
              top: 380,
              child: _DecorativeBlob(
                size: 220,
                color: VotusColors.cream,
              ),
            ),

            const Positioned(
              right: -90,
              top: 700,
              child: _DecorativeBlob(
                size: 190,
                color: VotusColors.yellow,
              ),
            ),

            RefreshIndicator(
              color: VotusColors.green,
              onRefresh: _reload,
              child: FutureBuilder<Map<int, Map<String, int>>>(
                future: _future,
                builder: (context, snapshot) {
                  final loading =
                      snapshot.connectionState == ConnectionState.waiting;
                  final summary = snapshot.data ?? {};

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
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
                        child: _buildHeader(context, summary),
                      ),

                      if (loading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: VotusColors.green,
                            ),
                          ),
                        )
                      else if (snapshot.hasError)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildMessage(
                            icon: Icons.wifi_off_rounded,
                            text:
                                'Não foi possível carregar os resultados.\nPuxe a tela pra baixo pra tentar de novo.',
                          ),
                        )
                      else if (summary.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildMessage(
                            icon: Icons.insert_chart_outlined_rounded,
                            text:
                                'Ainda não há respostas.\nSeja a primeira pessoa a opinar!',
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 110,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _buildCharts(summary),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: VotusNavigation(
                  currentPage: VotusPage.results,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Map<int, Map<String, int>> summary,
  ) {
    final total = _totalResponses(summary);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
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
                  'TRANSPARÊNCIA TOTAL',
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
                    TextSpan(text: 'A voz de quem '),
                    TextSpan(
                      text: 'já opinou.',
                      style: TextStyle(color: VotusColors.green),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Cada resposta ajuda a mostrar, com números reais, '
                'o que a comunidade pensa sobre o Votus.',
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
                children: [
                  _InfoChip(
                    icon: Icons.groups_rounded,
                    text: total == 1
                        ? '1 pessoa já respondeu'
                        : '$total pessoas já responderam',
                  ),
                  const _InfoChip(
                    icon: Icons.bolt_rounded,
                    text: 'Atualizado agora',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage({required IconData icon, required String text}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: VotusColors.cream),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts(Map<int, Map<String, int>> summary) {
    return Column(
      children: [
        ...surveyQuestions
            .where((q) => summary.containsKey(q.id))
            .toList()
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final question = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _ResultCard(
              question: question,
              number: index + 1,
              counts: summary[question.id]!,
            ),
          );
        }),

        const SizedBox(height: 10),

        const Text(
          'Obrigado por acompanhar a construção do Votus.',
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
}

class _ResultCard extends StatelessWidget {
  final Question question;
  final int number;
  final Map<String, int> counts;

  const _ResultCard({
    required this.question,
    required this.number,
    required this.counts,
  });

  int get _total => counts.values.fold(0, (sum, c) => sum + c);

  @override
  Widget build(BuildContext context) {
    final maxCount = counts.values.isEmpty
        ? 1
        : counts.values.reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: VotusColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VotusColors.cream, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    padding: const EdgeInsets.only(top: 2),
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

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: VotusColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: VotusColors.cream),
                  ),
                  child: Text(
                    '$_total',
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: VotusColors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: (maxCount + 1).toDouble(),
                  barGroups: List.generate(question.options.length, (index) {
                    final option = question.options[index];
                    final count = counts[option] ?? 0;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          width: 26,
                          borderRadius: BorderRadius.circular(8),
                          color: count == maxCount && count > 0
                              ? VotusColors.green
                              : VotusColors.green.withOpacity(0.45),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    // Antes mostrava o texto da opção — trocado por número
                    // (a legenda abaixo já explica o que cada número significa,
                    // e isso resolve o aperto em telas estreitas).
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= question.options.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: VotusColors.darkRed,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          if (value != value.roundToDouble()) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: Color(0xFF999999),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: VotusColors.cream,
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Legenda: número -> texto da opção, quebra linha sozinha.
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: List.generate(question.options.length, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: VotusColors.cream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: VotusColors.darkRed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      question.options[index],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: VotusColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: VotusColors.cream),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: VotusColors.green),
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

  const _DecorativeBlob({required this.size, required this.color});

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