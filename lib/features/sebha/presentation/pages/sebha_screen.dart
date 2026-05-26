import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/features/sebha/controller/sebha_provider.dart';

import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';

class SebhaScreen extends ConsumerStatefulWidget {
  const SebhaScreen({super.key});

  @override
  ConsumerState<SebhaScreen> createState() => _SebhaScreenState();
}

class _SebhaScreenState extends ConsumerState<SebhaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _zikrController;
  late Animation<double> _zikrOpacity;
  late Animation<Offset> _zikrSlide;

  int _prevZikrIndex = 0;

  @override
  void initState() {
    super.initState();

    // Zikr change animation
    _zikrController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _zikrOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _zikrController, curve: Curves.easeOut));

    _zikrSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _zikrController, curve: Curves.easeOutCubic),
        );

    _zikrController.value = 1.0;
  }

  @override
  void dispose() {
    _zikrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(ThemeRiverPod);

    final sebhaState = ref.watch(sebhaProvider);
    final sebhaNotifier = ref.read(sebhaProvider.notifier);

    final zikr = sebhaNotifier.azkar[sebhaState.currentZikrIndex];

    // Trigger zikr animation when zikr changes
    if (sebhaState.currentZikrIndex != _prevZikrIndex) {
      _prevZikrIndex = sebhaState.currentZikrIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _zikrController.forward(from: 0);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark ? AppColors.white : AppColors.card,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'السبحة',
                    style: AppTextStyles.title.copyWith(
                      color: isDark ? AppColors.white : AppColors.card,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    sebhaNotifier.increment();
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      children: [
                        const Gap(100),

                        // Zikr text with slide + fade animation
                        SlideTransition(
                          position: _zikrSlide,
                          child: FadeTransition(
                            opacity: _zikrOpacity,
                            child: Text(
                              zikr,
                              textAlign: TextAlign.center,
                              style: ArabicTextStyle(
                                
                                arabicFont: ArabicFont.amiri,
                                fontSize: 26,
                                fontWeight: FontWeight.normal,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),

                        const Gap(70),

                        // Count — bead/rosary vertical scroll animation
                        ClipRect(
                          child: SizedBox(
                            height: 120,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                // Check if this is the NEW (incoming) widget
                                final isIncoming =
                                    child.key == ValueKey(sebhaState.count);

                                final slideOffset = Tween<Offset>(
                                  // Incoming: slide from bottom → center
                                  // Outgoing: slide from center → top
                                  begin: isIncoming
                                      ? const Offset(0, 0.5)
                                      : const Offset(0, -0.5),
                                  end: Offset.zero,
                                ).animate(animation);

                                return SlideTransition(
                                  position: slideOffset,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                '${sebhaState.count}',
                                key: ValueKey(sebhaState.count),
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 100,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                widget: Text(
                                  'تغيير الذِكر',
                                  style: AppTextStyles.buttont,
                                ),
                                ontap: () {
                                  sebhaNotifier.changeZikr();
                                },
                              ),
                            ),

                            const Gap(10),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.offWhite,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(200),
                                ),
                              ),
                              onPressed: () {
                                sebhaNotifier.reset();
                              },
                              child: const Icon(
                                Icons.replay,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        const Gap(20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
