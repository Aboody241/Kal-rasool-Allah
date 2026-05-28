import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Beautiful Modal Bottom Sheet to change or add custom Zikr
  void _showZikrSelectionSheet(BuildContext context) {
    final isDark = ref.read(ThemeRiverPod);
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Resize bottom sheet when keyboard shows
      backgroundColor: isDark ? AppColors.card : AppColors.offWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final sebhaState = ref.watch(sebhaProvider);
            final sebhaNotifier = ref.read(sebhaProvider.notifier);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.mediumGray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'اختر أو أضف ذِكرًا جديدًا',
                    style: ArabicTextStyle(
                      arabicFont: ArabicFont.cairo,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.card,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sebhaState.azkarList.length,
                      itemBuilder: (context, index) {
                        final item = sebhaState.azkarList[index];
                        final isSelected = index == sebhaState.currentZikrIndex;

                        final hasDeleteButton = sebhaState.azkarList.length > 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.card : AppColors.lightGray,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : (isDark ? AppColors.secondary : AppColors.mediumGray),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              // 1. Completely isolated Delete Button (Left side)
                              if (hasDeleteButton)
                                Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.redAccent,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      sebhaNotifier.deleteZikr(index);
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'تم حذف الذكر بنجاح',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                              // 2. Completely isolated Selection Area (Middle & Right side) with ink ripple effect
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      sebhaNotifier.selectZikr(index);
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          if (isSelected) ...[
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.primaryGreen,
                                              size: 20,
                                            ),
                                            const Gap(8),
                                          ],
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: ArabicTextStyle(
                                                arabicFont: ArabicFont.cairo,
                                                fontSize: 15,
                                                color: isDark ? AppColors.white : AppColors.card,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                              textAlign: TextAlign.right,
                                              textDirection: TextDirection.rtl,
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
                      },
                    ),
                  ),
                  const Gap(12),
                  const Divider(color: AppColors.secondary),
                  const Gap(8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          final text = textController.text.trim();
                          if (text.isNotEmpty) {
                            sebhaNotifier.addCustomZikr(text);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'تمت إضافة الذكر بنجاح وتحديده',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.primaryGreen,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.add_box_rounded,
                          color: AppColors.primaryGreen,
                          size: 40,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: textController,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: ArabicFont.cairo,
                            color: isDark ? AppColors.white : AppColors.card,
                          ),
                          decoration: InputDecoration(
                            hintText: 'اكتب ذكرًا خاصًا بك هنا...',
                            hintStyle: const TextStyle(
                              fontFamily: ArabicFont.cairo,
                              color: AppColors.mediumGray,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(ThemeRiverPod);

    final sebhaState = ref.watch(sebhaProvider);
    final sebhaNotifier = ref.read(sebhaProvider.notifier);

    final zikr = sebhaState.azkarList[sebhaState.currentZikrIndex];

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
              const Gap(20),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    sebhaNotifier.increment();
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      children: [
                        // Progress Bar & Rounds Row (Rounds displayed cleanly as a plain number next to the progress bar)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Text(
                                'الدورات: ${sebhaState.rounds}',
                                style: ArabicTextStyle(
                                  arabicFont: ArabicFont.cairo,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.gold : AppColors.primaryGreen,
                                ),
                              ),
                              const Gap(16),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                  
                                    value: sebhaState.count / 33.0,
                                    backgroundColor: isDark
                                        ? AppColors.gold.withOpacity(0.2)
                                        : AppColors.mediumGray,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark ? AppColors.gold : AppColors.gold,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(60),

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
                                color: isDark? AppColors.white : AppColors.card,
                              ),
                            ),
                          ),
                        ),

                        const Gap(50),

                        // Main count (AnimatedSwitcher for vertical sliding beads effect wrapped in RepaintBoundary)
                        ClipRect(
                          child: SizedBox(
                            height: 120,
                            child: RepaintBoundary(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  final isIncoming =
                                      child.key == ValueKey(sebhaState.count);

                                  final slideOffset = Tween<Offset>(
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
                                    color: isDark? AppColors.offWhite : AppColors.card
                                  ),
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
                                  _showZikrSelectionSheet(context);
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
