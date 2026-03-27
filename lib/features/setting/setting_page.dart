import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/container_box.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  // ✅ فتح الـ TimePicker
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  // ✅ تنسيق الوقت
  String get _formattedTime {
    final hour = _reminderTime.hourOfPeriod.toString().padLeft(2, '0');
    final minute = _reminderTime.minute.toString().padLeft(2, '0');
    final period = _reminderTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const Gap(10),

              // ✅ Header
              Text('الإعدادات', style: AppTextStyles.title),
              const Gap(8),
              Text(
                'خصص تجربتك في التطبيق',
                style: AppTextStyles.subTitle.copyWith(
                  color: AppColors.darkGray,
                ),
              ),
              const Gap(30),

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
                              subtitle: 'احصل على تذكر بالحديث اليومي',
                              trailing: Switch(
                                value: _notificationsEnabled,
                                onChanged: (val) =>
                                    setState(() => _notificationsEnabled = val),
                                activeThumbColor: AppColors.primaryGreen,
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
                                        color: AppColors.offWhite,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Gap(6),
                                    const Icon(
                                      Icons.timer_outlined,
                                      color: AppColors.primaryGreen,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                GestureDetector(
                                  onTap: _notificationsEnabled
                                      ? _pickTime
                                      : null,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          color: _notificationsEnabled
                                              ? AppColors.mediumGray
                                              : AppColors.darkGray,
                                          size: 20,
                                        ),
                                        Text(
                                          _formattedTime,
                                          style: AppTextStyles.small.copyWith(
                                            color: _notificationsEnabled
                                                ? AppColors.offWhite
                                                : AppColors.darkGray,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

                            // ✅ الوضع الداكن
                            _SettingsTile(
                              title: 'الوضع الداكن',
                              subtitle: 'مفعل دائماً',
                              trailing: Switch(
                                value: _darkModeEnabled,
                                onChanged: (val) =>
                                    setState(() => _darkModeEnabled = val),
                                activeColor: AppColors.primaryGreen,
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
                              Gap(1),
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

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.offWhite,
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
