import 'dart:ui';
import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';
import 'package:kal_rasol_allah/core/services/notification_service.dart';

class DailyReminderScreen extends ConsumerStatefulWidget {
  const DailyReminderScreen({super.key});

  @override
  ConsumerState<DailyReminderScreen> createState() =>
      _DailyReminderScreenState();
}

class _DailyReminderScreenState extends ConsumerState<DailyReminderScreen>
    with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  final _notifService = NotificationService();
  bool _isLoading = false;

  // success animations
  bool _showSuccessAnimation = false;
  late AnimationController _successController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    // Default values or loaded from Hive
    _notificationsEnabled = _notifService.getSavedEnabled();
    _reminderTime = _notifService.getSavedTime();

    // Default enable it if first time
    if (!_notifService.getSavedEnabled() &&
        _notifService.getSavedTime().hour == 9 &&
        _notifService.getSavedTime().minute == 0) {
      _notificationsEnabled = true;
    }

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  Future<void> _toggleNotifications(bool val) async {
    HapticFeedback.lightImpact();
    setState(() => _notificationsEnabled = val);

    if (val) {
      await _notifService.requestPermission();
      await _notifService.scheduleDailyNotification(_reminderTime);
    } else {
      await _notifService.cancelNotifications();
    }
  }

  Future<void> _pickTime() async {
    HapticFeedback.mediumImpact();
    final isDark = ref.read(ThemeRiverPod);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.card : Colors.white,
              onSurface: isDark ? Colors.white : AppColors.card,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDark ? AppColors.background : Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: isDark ? AppColors.card : Colors.white,
              hourMinuteTextColor: isDark ? Colors.white : AppColors.card,
              hourMinuteColor: isDark
                  ? AppColors.secondary
                  : Colors.grey.shade100,
              dayPeriodTextColor: isDark ? Colors.white : AppColors.card,
              dayPeriodColor: isDark
                  ? AppColors.secondary
                  : Colors.grey.shade100,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      HapticFeedback.heavyImpact();
      setState(() => _reminderTime = picked);
      if (_notificationsEnabled) {
        await _notifService.scheduleDailyNotification(_reminderTime);
      }
    }
  }

  Future<void> _saveAndContinue() async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);

    try {
      if (_notificationsEnabled) {
        await _notifService.requestPermission();
        await _notifService.scheduleDailyNotification(_reminderTime);
      } else {
        await _notifService.cancelNotifications();
      }

      setState(() => _isLoading = false);

      if (mounted) {
        setState(() {
          _showSuccessAnimation = true;
        });
        HapticFeedback.heavyImpact();
        await _successController.forward();
        await Future.delayed(const Duration(milliseconds: 1800));

        if (mounted) {
          // If we can pop, that means we came from Settings screen
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            // Otherwise, we came from Onboarding screen — navigate to main navigation bar
            Navigator.pushReplacementNamed(context, Approuter.mainNavbar);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء حفظ الإعدادات: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String get _formattedHour {
    final hour = _reminderTime.hourOfPeriod == 0
        ? 12
        : _reminderTime.hourOfPeriod;
    return hour.toString().padLeft(2, '0');
  }

  String get _formattedMinute {
    return _reminderTime.minute.toString().padLeft(2, '0');
  }

  String get _periodText {
    return _reminderTime.period == DayPeriod.am ? 'صباحًا' : 'مساءً';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(ThemeRiverPod);

    return Scaffold(
      body: Stack(
        children: [
          // ---- Background Gradient ----
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0C1712), const Color(0xFF050806)]
                      : [const Color(0xFFF3F7F5), const Color(0xFFE5EDE9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ---- Glowing Blur Orbs ----
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withValues(
                  alpha: isDark ? 0.12 : 0.08,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: isDark ? 0.08 : 0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: const SizedBox(),
              ),
            ),
          ),

          // ---- Content ----
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom Close Button if navigated from Settings
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, top: 10),
                      child: Navigator.canPop(context)
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: isDark ? Colors.white : AppColors.card,
                                size: 28,
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                            )
                          : const SizedBox(height: 48),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Header Section
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.15,
                            ),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.25,
                              ),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            color: AppColors.primaryGreen,
                            size: 40,
                          ),
                        ),
                      ),
                      const Gap(24),

                      Text(
                        'لا تنسَ وردك اليومي 🤍',
                        style: ArabicTextStyle(
                          arabicFont: ArabicFont.cairo,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.card,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(12),
                      Text(
                        'اجعل يومك يبدأ بذكر الله وحافظ على سلسلة أيامك المتتالية من خلال سُنّة يومية تنير دربك وتديم صلتك بسيد الخلق ﷺ.',
                        style: ArabicTextStyle(
                          arabicFont: ArabicFont.cairo,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? AppColors.mediumGray
                              : AppColors.mutedGray,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(32),

                      // Notification Mockup Card
                      _buildNotificationMockup(isDark),
                      const Gap(32),

                      // Toggle Switch Glass Card
                      _buildToggleCard(isDark),
                      const Gap(20),

                      // Time Selector Card (Only active when notifications are enabled)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _notificationsEnabled ? 1.0 : 0.45,
                        child: IgnorePointer(
                          ignoring: !_notificationsEnabled,
                          child: _buildTimeSelectorCard(isDark),
                        ),
                      ),
                      const Gap(48),

                      // Primary Action Button
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGreen,
                              ),
                            )
                          : PrimaryButton(
                              backGround: AppColors.primaryGreen,
                              widget: Center(
                                child: Text(
                                  Navigator.canPop(context)
                                      ? 'حفظ التعديلات ✅'
                                      : 'حفظ وبدء اليوم',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ontap: _saveAndContinue,
                            ),
                      const Gap(30),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          if (_showSuccessAnimation) _buildSuccessOverlay(isDark),
        ],
      ),
    );
  }

  // Real-time Push Notification Bubble Mockup (Glassmorphic)
  Widget _buildNotificationMockup(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Notification Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen.withValues(alpha: 0.15),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.3,
                            ),
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          size: 13,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const Gap(8),

                      Text(
                        'قال رسول الله ﷺ',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isDark ? Colors.white : AppColors.card,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    'الآن',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: isDark
                          ? AppColors.mediumGray
                          : AppColors.mutedGray,
                    ),
                  ),
                ],
              ),
              const Gap(10),
              // Notification Body
              Text(
                'حان وقت وردك اليومي 🌙\nلا تنسَ سُنّتك اليومية لتنال الأجر والثواب.',
                style: ArabicTextStyle(
                  arabicFont: ArabicFont.cairo,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.lightGray : AppColors.card,
                  height: 1.6,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Toggle switch card
  Widget _buildToggleCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.secondary : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'تفعيل التذكير اليومي',
                style: ArabicTextStyle(
                  arabicFont: ArabicFont.cairo,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.card,
                ),
              ),
              const Gap(4),
              Text(
                'احصل على إشعار تحفيزي يوميًا بالسنة النبوية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: isDark ? AppColors.mediumGray : AppColors.mutedGray,
                ),
              ),
            ],
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.primaryGreen,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  // Time selector custom premium card
  Widget _buildTimeSelectorCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.secondary : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'وقت التذكير المفضل',
                style: ArabicTextStyle(
                  arabicFont: ArabicFont.cairo,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.card,
                ),
              ),
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.primaryGreen,
                size: 22,
              ),
            ],
          ),
          const Gap(20),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.08),
                    AppColors.lightGreen.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Period (AM/PM)
                  Text(
                    _periodText,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const Gap(12),
                  // Animated Digits Display
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      key: ValueKey(
                        '${_reminderTime.hour}_${_reminderTime.minute}',
                      ),
                      children: [
                        Text(
                          _formattedMinute,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white : AppColors.card,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        Text(
                          _formattedHour,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white : AppColors.card,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.primaryGreen,
              ),
              const Gap(6),
              Text(
                'اضغط على الساعة لتعديل الوقت وتحديده',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: isDark ? AppColors.mediumGray : AppColors.mutedGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Premium full-screen spiritual success animation overlay
  Widget _buildSuccessOverlay(bool isDark) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _successController,
        builder: (context, child) {
          return Container(
            color: (isDark ? Colors.black : Colors.white).withValues(
              alpha: 0.65,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F1B15).withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Glowing Medallion / Icon container
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryGreen,
                                    AppColors.gold,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 56,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(30),
                            // Spiritual Title
                            Text(
                              'يومك مبارك بذكر الله 🌿',
                              style: ArabicTextStyle(
                                arabicFont: ArabicFont.cairo,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.card,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(12),
                            // Subtitle
                            Text(
                              'تم تفعيل وردك النبوي بنجاح. عسى أن يكون شاهداً لك يوم القيامة وشفيعاً.',
                              style: ArabicTextStyle(
                                arabicFont: ArabicFont.cairo,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.mediumGray
                                    : AppColors.mutedGray,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(24),
                            // Small decorative glowing star/crescent
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.gold,
                                  size: 14,
                                ),
                                const Gap(6),
                                Text(
                                  'قال رسول الله ﷺ',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.lightGray
                                        : AppColors.mutedGray,
                                  ),
                                ),
                                const Gap(6),
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.gold,
                                  size: 14,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
