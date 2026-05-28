import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/services/notification_service.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/container_box.dart';
import 'package:kal_rasol_allah/core/widgets/pages_title.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  final _notifService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Load saved settings from Hive
    _notificationsEnabled = _notifService.getSavedEnabled();
    _reminderTime = _notifService.getSavedTime();
  }

  // ✅ فتح الـ TimePicker
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );
    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);
      // Schedule with the new time
      await _notifService.scheduleDailyNotification(_reminderTime);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم ضبط التذكير على $_formattedTime',
              style: const TextStyle(
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
    }
  }

  // ✅ تنسيق الوقت
  String get _formattedTime {
    final hour = _reminderTime.hourOfPeriod.toString().padLeft(2, '0');
    final minute = _reminderTime.minute.toString().padLeft(2, '0');
    final period = _reminderTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _toggleNotifications(bool val) async {
    setState(() => _notificationsEnabled = val);
    if (val) {
      // Request permission on Android 13+
      await _notifService.requestPermission();
      await _notifService.scheduleDailyNotification(_reminderTime);
    } else {
      await _notifService.cancelNotifications();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            val ? 'تم تفعيل التذكير اليومي ✅' : 'تم إيقاف التذكير',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: val ? AppColors.primaryGreen : Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(ThemeRiverPod);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const Gap(10),
        const      PagesTitle(title: 'الإعدادات', subtitle: 'خصص تجربتك في التطبيق'),

              // ✅ Header
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ✅ قسم الإشعارات
                      ContainerBox(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ عنوان القسم
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'الإشعارات',
                                  style: AppTextStyles.subTitle.copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primaryGreen,
                                    decorationThickness: 2,
                                    color: isDark
                                        ? AppColors.lightGray
                                        : AppColors.card,
                                  ),
                                ),
                                const Gap(8),
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.primaryGreen,
                                  size: 22,
                                ),
                              ],
                            ),

                            const Gap(16),
                            const Divider(color: AppColors.secondary),
                            const Gap(12),

                            // ✅ تفعيل التذكير اليومي
                            _SettingsTile(
                              title: 'تفعيل التذكير اليومي',
                              subtitle: 'احصل على تذكر بالسُنّة اليومية',
                              trailing: Switch(
                                value: _notificationsEnabled,
                                onChanged: _toggleNotifications,
                                activeThumbColor: AppColors.darkGreen,
                              ),
                            ),

                            const Gap(16),
                            const Divider(color: AppColors.secondary),
                            const Gap(12),

                            // ✅ وقت التذكير
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'وقت التذكير',
                                      style: AppTextStyles.small.copyWith(
                                        color: isDark
                                            ? AppColors.offWhite
                                            : AppColors.card,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Gap(6),
                                    const Icon(
                                      Icons.timer_outlined,
                                      color: AppColors.darkGreen,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const Gap(12),
                                GestureDetector(
                                  onTap: _notificationsEnabled
                                      ? _pickTime
                                      : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _notificationsEnabled
                                          ? AppColors.primaryGreen
                                          : AppColors.mutedGray,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          color: AppColors.offWhite,
                                          size: 20,
                                        ),
                                        Text(
                                          _formattedTime,
                                          style: AppTextStyles.small.copyWith(
                                            color: AppColors.offWhite,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                if (_notificationsEnabled) ...[
                                  const Gap(10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.info_outline_rounded,
                                        size: 14,
                                        color: AppColors.primaryGreen,
                                      ),
                                      const Gap(4),
                                      Text(
                                        'سيصلك إشعار يومياً في هذا الوقت',
                                        style: AppTextStyles.small.copyWith(
                                          color: AppColors.primaryGreen,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Gap(16),

                      // ✅ قسم المظهر
                      ContainerBox(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ عنوان القسم
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'المظهر',
                                  style: AppTextStyles.subTitle.copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primaryGreen,
                                    decorationThickness: 2,
                                    color: isDark
                                        ? AppColors.lightGray
                                        : AppColors.card,
                                  ),
                                ),
                                const Gap(8),
                                const Icon(
                                  Icons.dark_mode_outlined,
                                  color: AppColors.primaryGreen,
                                  size: 22,
                                ),
                              ],
                            ),

                            const Gap(16),
                            const Divider(color: AppColors.secondary),
                            const Gap(12),

                            _SettingsTile(
                              title: 'الوضع الداكن',
                              subtitle: '(الوضع الأفتراضي)',
                              trailing: Switch(
                                value: isDark,
                                onChanged: (value) =>
                                    ref.read(ThemeRiverPod.notifier).state =
                                        value,

                                activeThumbColor: AppColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Gap(16),

                      // ✅ قسم عن التطبيق
                      ContainerBox(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 16,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Gap(1),
                              Text(
                                'الإصدار 1.0.0',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.mediumGray,
                                ),
                              ),
                              const Gap(6),
                              Text(
                                'تطبيق قال رسول الله ﷺ',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.darkGray,
                                  fontSize: 12,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'للمواظبة على السنن النبوية',
                                style: AppTextStyles.small.copyWith(
                                  color: AppColors.darkGray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Gap(30),

                      // ✅ الآية في الأسفل
                      Text(
                        '"لا تنسونا في صالح دعائكم"',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.darkGray,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Gap(20),
                    ],
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

// ============================================================
// ✅ Settings Tile Widget — عنوان + subtitle + trailing
// ============================================================

class _SettingsTile extends ConsumerWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          trailing,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: AppTextStyles.small.copyWith(
                  color: isDark ? AppColors.offWhite : AppColors.card,
                  fontSize: 15,
                ),
              ),
              const Gap(4),
              Text(
                subtitle,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.darkGray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
