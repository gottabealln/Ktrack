import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/entry.dart';
import '../models/trigger.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/quotes.dart';
import '../widgets/floating_blobs.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_card.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;
  const HomeScreen({super.key, required this.storage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _showAddEntrySheet() {
    final selected = <String>{};
    int severity = 3;
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF141A33),
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textDim,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('New Entry', style: AppText.h2),
                  const SizedBox(height: 6),
                  Text('How are you feeling right now?',
                      style: AppText.small),
                  const SizedBox(height: 20),
                  Text('Symptoms', style: AppText.h3),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allSymptoms.map((s) {
                      final isSel = selected.contains(s);
                      return GestureDetector(
                        onTap: () => setSheet(() {
                          if (isSel) {
                            selected.remove(s);
                          } else {
                            selected.add(s);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSel ? AppGradients.primary : null,
                            color: isSel
                                ? null
                                : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel
                                  ? Colors.transparent
                                  : AppColors.border,
                            ),
                            boxShadow: isSel
                                ? [
                              BoxShadow(
                                color: AppColors.g1
                                    .withOpacity(0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                                : null,
                          ),
                          child: Text(s,
                              style: AppText.small.copyWith(
                                color: isSel
                                    ? Colors.white
                                    : AppColors.textDim,
                                fontWeight: isSel
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Severity', style: AppText.h3),
                      Text('$severity / 5',
                          style: AppText.body.copyWith(
                            color: AppColors.g3,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.g3,
                      inactiveTrackColor:
                      Colors.white.withOpacity(0.1),
                      thumbColor: Colors.white,
                      overlayColor: AppColors.g3.withOpacity(0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: severity.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (v) =>
                          setSheet(() => severity = v.round()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    style: AppText.body,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a note... (optional)',
                      hintStyle: AppText.small,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                        const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                        const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppColors.g3, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  GradientButton(
                    text: 'Save Entry',
                    icon: Icons.check_rounded,
                    gradient: AppGradients.calm,
                    onPressed: () async {
                      if (selected.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                            Text('Pick at least one symptom'),
                          ),
                        );
                        return;
                      }
                      await widget.storage.saveEntry(Entry(
                        id: const Uuid().v4(),
                        date: DateTime.now(),
                        symptoms: selected.toList(),
                        severity: severity,
                        note: noteCtrl.text.trim().isEmpty
                            ? null
                            : noteCtrl.text.trim(),
                      ));
                      if (mounted) Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Entry saved ✓'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTriggerSheet() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF141A33),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textDim,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppGradients.danger,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.danger.withOpacity(0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.flash_on_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Got Triggered', style: AppText.h2),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Take a deep breath. Then write what happened.',
                style: AppText.small,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                style: AppText.body,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'What triggered you?',
                  hintStyle: AppText.small,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.danger, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Log Trigger',
                icon: Icons.favorite_rounded,
                gradient: AppGradients.danger,
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  await widget.storage.saveTrigger(Trigger(
                    id: const Uuid().v4(),
                    date: DateTime.now(),
                    description: ctrl.text.trim(),
                  ));
                  if (mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Logged. You are safe. Breathe.'),
                      backgroundColor: AppColors.g1,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quote = getDailyQuote();

    return FloatingBlobs(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Animated gradient KTRACK title
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.88, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.elasticOut,
                    builder: (_, s, child) =>
                        Transform.scale(scale: s, child: child),
                    child: ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                        colors: [
                          AppColors.g3,
                          AppColors.g4,
                          AppColors.g2,
                          AppColors.g5,
                        ],
                      ).createShader(rect),
                      child: Text(
                        'KTRACK',
                        textAlign: TextAlign.center,
                        style: AppText.h1.copyWith(
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'hello, take it one breath at a time',
                    textAlign: TextAlign.center,
                    style: AppText.small,
                  ),
                  const SizedBox(height: 26),

                  // Daily quote glass card
                  GradientCard(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.g1.withOpacity(0.55),
                        AppColors.g3.withOpacity(0.55),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.auto_awesome,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('DAILY BOOST',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.4,
                                )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          quote,
                          style: AppText.body.copyWith(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Add Entry button
                  GradientButton(
                    text: 'Add an Entry',
                    icon: Icons.add_circle_outline_rounded,
                    gradient: AppGradients.primary,
                    onPressed: _showAddEntrySheet,
                  ),

                  const SizedBox(height: 14),

                  // Got Triggered — pulsing
                  _PulsingWrapper(
                    child: GradientButton(
                      text: 'Got Triggered',
                      icon: Icons.flash_on_rounded,
                      gradient: AppGradients.danger,
                      onPressed: _showTriggerSheet,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      '· you are not alone ·',
                      style: AppText.small.copyWith(
                        color: AppColors.textDim.withOpacity(0.7),
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gentle pulsing animation wrapper for the trigger button
class _PulsingWrapper extends StatefulWidget {
  final Widget child;
  const _PulsingWrapper({required this.child});

  @override
  State<_PulsingWrapper> createState() => _PulsingWrapperState();
}

class _PulsingWrapperState extends State<_PulsingWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final s = 1.0 + (_ctrl.value * 0.025);
        return Transform.scale(scale: s, child: child);
      },
      child: widget.child,
    );
  }
}