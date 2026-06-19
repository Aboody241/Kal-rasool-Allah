import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';
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
  bool _morningEnabled = false;
  bool _eveningEnabled = false;
  bool _dhikrEnabled = false;

  final _notifService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _notificationsEnabled = _notifService.getBoolSetting(NotificationService.kMasterEnabled);
    _morningEnabled = _notifService.getBoolSetting(NotificationService.kMorningEnabled);
    _eveningEnabled = _notifService.getBoolSetting(NotificationService.kEveningEnabled);
    _dhikrEnabled = _notifService.getBoolSetting(NotificationService.kDhikrEnabled);
  }

  String get _reminderSubtitle {
    if (!_notificationsEnabled) {
      return 'جميع التنبيهات معطلة 🔕';
    }
    final List<String> active = [];
    if (_morningEnabled) active.add('الصباح');
    if (_eveningEnabled) active.add('المساء');
    if (_dhikrEnabled) active.add('الأذكار');
    
    if (active.isEmpty) {
      return 'مفعّل (لم يتم اختيار أي ورد)';
    }
    return 'نشط: ${active.join(" و")} 🌿';
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

                            // ✅ تفعيل وتخصيص التذكير اليومي
                            GestureDetector(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                await Navigator.pushNamed(context, Approuter.dailyReminderScreen);
                                // Reload settings when we return
                                setState(() {
                                  _loadSettings();
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: _SettingsTile(
                                title: 'التذكير اليومي بالسُنّة',
                                subtitle: _reminderSubtitle,
                                trailing: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 18,
                                ),
                              ),
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
