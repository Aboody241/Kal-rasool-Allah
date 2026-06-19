import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';
import 'package:kal_rasol_allah/core/services/notification_service.dart';
import 'package:kal_rasol_allah/features/home/controllers/streak_provider.dart';

class DailyReminderScreen extends ConsumerStatefulWidget {
  const DailyReminderScreen({super.key});

  @override
  ConsumerState<DailyReminderScreen> createState() => _DailyReminderScreenState();
}

class _DailyReminderScreenState extends ConsumerState<DailyReminderScreen> {
  final _notifService = NotificationService();
  bool _isLoading = false;

  // Global settings
  late bool _masterEnabled;
  late bool _soundEnabled;
  late bool _vibrationEnabled;

  // Morning settings
  late bool _morningEnabled;
  late int _morningStartHour;
  late int _morningStartMinute;
  late int _morningEndHour;
  late int _morningEndMinute;

  // Evening settings
  late bool _eveningEnabled;
  late int _eveningStartHour;
  late int _eveningStartMinute;
  late int _eveningEndHour;
  late int _eveningEndMinute;

  // Dhikr settings
  late bool _dhikrEnabled;
  late int _dhikrCount;
  late int _dhikrQuietStartHour;
  late int _dhikrQuietStartMinute;
  late int _dhikrQuietEndHour;
  late int _dhikrQuietEndMinute;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _masterEnabled = _notifService.getBoolSetting(NotificationService.kMasterEnabled);
    _soundEnabled = _notifService.getBoolSetting(NotificationService.kSoundEnabled);
    _vibrationEnabled = _notifService.getBoolSetting(NotificationService.kVibrationEnabled);

    _morningEnabled = _notifService.getBoolSetting(NotificationService.kMorningEnabled);
    _morningStartHour = _notifService.getIntSetting(NotificationService.kMorningStartHour, defaultValue: 6);
    _morningStartMinute = _notifService.getIntSetting(NotificationService.kMorningStartMinute, defaultValue: 0);
    _morningEndHour = _notifService.getIntSetting(NotificationService.kMorningEndHour, defaultValue: 10);
    _morningEndMinute = _notifService.getIntSetting(NotificationService.kMorningEndMinute, defaultValue: 0);

    _eveningEnabled = _notifService.getBoolSetting(NotificationService.kEveningEnabled);
    _eveningStartHour = _notifService.getIntSetting(NotificationService.kEveningStartHour, defaultValue: 17);
    _eveningStartMinute = _notifService.getIntSetting(NotificationService.kEveningStartMinute, defaultValue: 0);
    _eveningEndHour = _notifService.getIntSetting(NotificationService.kEveningEndHour, defaultValue: 22);
    _eveningEndMinute = _notifService.getIntSetting(NotificationService.kEveningEndMinute, defaultValue: 0);

    _dhikrEnabled = _notifService.getBoolSetting(NotificationService.kDhikrEnabled);
    _dhikrCount = _notifService.getIntSetting(NotificationService.kDhikrCount, defaultValue: 3);
    _dhikrQuietStartHour = _notifService.getIntSetting(NotificationService.kDhikrQuietStartHour, defaultValue: 23);
    _dhikrQuietStartMinute = _notifService.getIntSetting(NotificationService.kDhikrQuietStartMinute, defaultValue: 0);
    _dhikrQuietEndHour = _notifService.getIntSetting(NotificationService.kDhikrQuietEndHour, defaultValue: 8);
    _dhikrQuietEndMinute = _notifService.getIntSetting(NotificationService.kDhikrQuietEndMinute, defaultValue: 0);
  }

  Future<void> _saveSettings() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      await _notifService.setBoolSetting(NotificationService.kMasterEnabled, _masterEnabled);
      await _notifService.setBoolSetting(NotificationService.kSoundEnabled, _soundEnabled);
      await _notifService.setBoolSetting(NotificationService.kVibrationEnabled, _vibrationEnabled);

      await _notifService.setBoolSetting(NotificationService.kMorningEnabled, _morningEnabled);
      await _notifService.setIntSetting(NotificationService.kMorningStartHour, _morningStartHour);
      await _notifService.setIntSetting(NotificationService.kMorningStartMinute, _morningStartMinute);
      await _notifService.setIntSetting(NotificationService.kMorningEndHour, _morningEndHour);
      await _notifService.setIntSetting(NotificationService.kMorningEndMinute, _morningEndMinute);

      await _notifService.setBoolSetting(NotificationService.kEveningEnabled, _eveningEnabled);
      await _notifService.setIntSetting(NotificationService.kEveningStartHour, _eveningStartHour);
      await _notifService.setIntSetting(NotificationService.kEveningStartMinute, _eveningStartMinute);
      await _notifService.setIntSetting(NotificationService.kEveningEndHour, _eveningEndHour);
      await _notifService.setIntSetting(NotificationService.kEveningEndMinute, _eveningEndMinute);

      await _notifService.setBoolSetting(NotificationService.kDhikrEnabled, _dhikrEnabled);
      await _notifService.setIntSetting(NotificationService.kDhikrCount, _dhikrCount);
      await _notifService.setIntSetting(NotificationService.kDhikrQuietStartHour, _dhikrQuietStartHour);
      await _notifService.setIntSetting(NotificationService.kDhikrQuietStartMinute, _dhikrQuietStartMinute);
      await _notifService.setIntSetting(NotificationService.kDhikrQuietEndHour, _dhikrQuietEndHour);
      await _notifService.setIntSetting(NotificationService.kDhikrQuietEndMinute, _dhikrQuietEndMinute);

      await _notifService.requestPermission();
      await _notifService.rescheduleAll();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تم حفظ إعدادات التذكير بنجاح 🌿',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.maybePop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ الإعدادات: $e', style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickTime({
    required bool isStart,
    required String section, // 'morning', 'evening', 'dhikr'
  }) async {
    HapticFeedback.lightImpact();

    int initialHour = 0;
    int initialMinute = 0;

    if (section == 'morning') {
      initialHour = isStart ? _morningStartHour : _morningEndHour;
      initialMinute = isStart ? _morningStartMinute : _morningEndMinute;
    } else if (section == 'evening') {
      initialHour = isStart ? _eveningStartHour : _eveningEndHour;
      initialMinute = isStart ? _eveningStartMinute : _eveningEndMinute;
    } else {
      initialHour = isStart ? _dhikrQuietStartHour : _dhikrQuietEndHour;
      initialMinute = isStart ? _dhikrQuietStartMinute : _dhikrQuietEndMinute;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: AppColors.card,
              onSurface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.card,
              hourMinuteTextColor: Colors.white,
              hourMinuteColor: AppColors.secondary,
              dayPeriodTextColor: Colors.white,
              dayPeriodColor: AppColors.secondary,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (section == 'morning') {
          if (isStart) {
            _morningStartHour = picked.hour;
            _morningStartMinute = picked.minute;
          } else {
            _morningEndHour = picked.hour;
            _morningEndMinute = picked.minute;
          }
        } else if (section == 'evening') {
          if (isStart) {
            _eveningStartHour = picked.hour;
            _eveningStartMinute = picked.minute;
          } else {
            _eveningEndHour = picked.hour;
            _eveningEndMinute = picked.minute;
          }
        } else {
          if (isStart) {
            _dhikrQuietStartHour = picked.hour;
            _dhikrQuietStartMinute = picked.minute;
          } else {
            _dhikrQuietEndHour = picked.hour;
            _dhikrQuietEndMinute = picked.minute;
          }
        }
      });
    }
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'مساءً' : 'صباحاً';
    final formatHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${formatHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(ThemeRiverPod);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient & Glowing Blur Orbs (Cached via RepaintBoundary for 60fps scrolling)
          Positioned.fill(
            child: RepaintBoundary(
              child: _DailyReminderBackground(isDark: isDark),
            ),
          ),

          // Content Layout
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
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
                        'التذكير اليومي الذكي',
                        style: AppTextStyles.title.copyWith(
                          color: isDark ? AppColors.white : AppColors.card,
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer to balance back button
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const Gap(10),

                        // ==========================================
                        // Islamic Streak & Badges Dashboard Card
                        // ==========================================
                        const _StreakDashboardCard(),
                        const Gap(20),

                        // ==========================================
                        // Master Toggle Control Card
                        // ==========================================
                        _buildMasterToggleCard(isDark),
                        const Gap(16),

                        if (_masterEnabled) ...[
                          // ==========================================
                          // Global Notification Options (Sound, Vibe)
                          // ==========================================
                          _buildGlobalOptionsCard(isDark),
                          const Gap(16),

                          // ==========================================
                          // Morning Athkar Card
                          // ==========================================
                          _buildSectionCard(
                            title: 'أذكار الصباح',
                            description: 'تذكير يومي في وقت عشوائي هادئ لتبدأ يومك ببركة الذكر.',
                            isEnabled: _morningEnabled,
                            onToggle: (val) => setState(() => _morningEnabled = val),
                            isDark: isDark,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTimeBox('تبدأ من', _formatTime(_morningStartHour, _morningStartMinute), () => _pickTime(isStart: true, section: 'morning'), isDark),
                                const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryGreen, size: 20),
                                _buildTimeBox('تنتهي في', _formatTime(_morningEndHour, _morningEndMinute), () => _pickTime(isStart: false, section: 'morning'), isDark),
                              ],
                            ),
                          ),
                          const Gap(16),

                          // ==========================================
                          // Evening Athkar Card
                          // ==========================================
                          _buildSectionCard(
                            title: 'أذكار المساء',
                            description: 'تذكير يومي عشوائي لتنهي يومك بطمأنينة وراحة بال.',
                            isEnabled: _eveningEnabled,
                            onToggle: (val) => setState(() => _eveningEnabled = val),
                            isDark: isDark,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTimeBox('تبدأ من', _formatTime(_eveningStartHour, _eveningStartMinute), () => _pickTime(isStart: true, section: 'evening'), isDark),
                                const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryGreen, size: 20),
                                _buildTimeBox('تنتهي في', _formatTime(_eveningEndHour, _eveningEndMinute), () => _pickTime(isStart: false, section: 'evening'), isDark),
                              ],
                            ),
                          ),
                          const Gap(16),

                          // ==========================================
                          // Random Dhikr Card
                          // ==========================================
                          _buildSectionCard(
                            title: '📿 التذكير بالذكر والتسبيح',
                            description: 'إشعارات رقيقة متفرقة ومتباعدة تحث على الاستغفار والذكر خلال اليوم.',
                            isEnabled: _dhikrEnabled,
                            onToggle: (val) => setState(() => _dhikrEnabled = val),
                            isDark: isDark,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('التكرار اليومي', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: isDark ? AppColors.lightGray : AppColors.card)),
                                    DropdownButton<int>(
                                      value: _dhikrCount,
                                      dropdownColor: AppColors.card,
                                      underline: const SizedBox(),
                                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: isDark ? AppColors.gold : AppColors.primaryGreen),
                                      items: [2, 3, 4, 5].map((c) => DropdownMenuItem(value: c, child: Text('$c مرات يومياً'))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _dhikrCount = val);
                                      },
                                    ),
                                  ],
                                ),
                                const Divider(color: AppColors.secondary, height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTimeBox('ساعات الهدوء من', _formatTime(_dhikrQuietStartHour, _dhikrQuietStartMinute), () => _pickTime(isStart: true, section: 'dhikr'), isDark),
                                    const Icon(Icons.nights_stay_outlined, color: AppColors.primaryGreen, size: 20),
                                    _buildTimeBox('إلى غاية', _formatTime(_dhikrQuietEndHour, _dhikrQuietEndMinute), () => _pickTime(isStart: false, section: 'dhikr'), isDark),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Gap(30),
                        ],

                        // ==========================================
                        // Test Notification Button
                        // ==========================================
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              await _notifService.showImmediateTestNotification();
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.gold, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.science_outlined, color: AppColors.gold),
                            label: const Text(
                              'إرسال إشعار تجريبي فوري 🧪',
                              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.gold),
                            ),
                          ),
                        ),
                        const Gap(16),

                        // ==========================================
                        // Save Settings Action Button
                        // ==========================================
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                            : SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  backGround: AppColors.primaryGreen,
                                  widget: const Center(
                                    child: Text(
                                      'حفظ وتطبيق التغييرات',
                                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  ontap: _saveSettings,
                                ),
                              ),
                        const Gap(40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Master Switch Widget
  // ==========================================
  Widget _buildMasterToggleCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.secondary : Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'تفعيل إشعارات التطبيق العامة',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.card),
              ),
              const Gap(4),
              Text(
                'التحكم العام بتشغيل أو إيقاف كافة التذكيرات',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: isDark ? AppColors.mediumGray : AppColors.mutedGray),
              ),
            ],
          ),
          Switch(
            value: _masterEnabled,
            onChanged: (val) => setState(() => _masterEnabled = val),
            activeColor: AppColors.white,
            activeTrackColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Global sound & vibration settings
  // ==========================================
  Widget _buildGlobalOptionsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.secondary : Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('صوت التنبيهات', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: isDark ? AppColors.lightGray : AppColors.card)),
              Switch(
                value: _soundEnabled,
                onChanged: (val) => setState(() => _soundEnabled = val),
                activeColor: AppColors.white,
                activeTrackColor: AppColors.primaryGreen,
              ),
            ],
          ),
          const Divider(color: AppColors.secondary, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الاهتزاز والتفاعل اللمسي', style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: isDark ? AppColors.lightGray : AppColors.card)),
              Switch(
                value: _vibrationEnabled,
                onChanged: (val) => setState(() => _vibrationEnabled = val),
                activeColor: AppColors.white,
                activeTrackColor: AppColors.primaryGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Standard Sections Layout Card
  // ==========================================
  Widget _buildSectionCard({
    required String title,
    required String description,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.secondary : Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.card)),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: AppColors.white,
                activeTrackColor: AppColors.primaryGreen,
              ),
            ],
          ),
          const Gap(4),
          Text(
            description,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: isDark ? AppColors.mediumGray : AppColors.mutedGray, height: 1.5),
          ),
          if (isEnabled) ...[
            const Divider(color: AppColors.secondary, height: 28),
            child,
          ],
        ],
      ),
    );
  }

  Widget _buildTimeBox(String label, String value, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.secondary.withValues(alpha: 0.4) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.secondary : Colors.grey.shade300, width: 1),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: isDark ? AppColors.mediumGray : AppColors.mutedGray)),
            const Gap(4),
            Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.gold : AppColors.primaryGreen)),
          ],
        ),
      ),
    );
  }
}

class _DailyReminderBackground extends StatelessWidget {
  final bool isDark;
  const _DailyReminderBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Gradient
        Container(
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
        // Glowing Blur Orb
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGreen.withValues(alpha: isDark ? 0.22 : 0.15),
                  AppColors.primaryGreen.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StreakDashboardCard extends ConsumerWidget {
  const _StreakDashboardCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final isDark = ref.watch(ThemeRiverPod);
    final cur = streak.currentStreak;

    // Badge unlocked status
    final has3Days = cur >= 3;
    final has7Days = cur >= 7;
    final has30Days = cur >= 30;
    final has100Days = cur >= 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.secondary : Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current streak display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 28),
                  const Gap(6),
                  Text(
                    'سلسلة التزامك الحالية',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.card),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$cur يوم متتالي 🔥',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.secondary, height: 28),

          // Spiritual motivational text
          Text(
            cur == 0
                ? 'ابدأ اليوم بقراءة الأوراد أو أذكار الصباح والمساء لبدء سلسلة التزامك المباركة 🌿'
                : 'ما شاء الله! حافظ على وردك اليومي لتبقى صلتك بالله عامرة وتنال أعلى الدرجات 🤍',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: isDark ? AppColors.mediumGray : AppColors.mutedGray, height: 1.6),
          ),
          const Gap(24),

          // Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBadgeItem('البداية 🌱', '3 أيام', Icons.spa_rounded, Colors.green, has3Days, isDark),
              _buildBadgeItem('البرونزي 🥉', '7 أيام', Icons.workspace_premium_rounded, Colors.orange.shade700, has7Days, isDark),
              _buildBadgeItem('الفضي 🥈', '30 يوماً', Icons.stars_rounded, Colors.grey.shade400, has30Days, isDark),
              _buildBadgeItem('الذهبي 🥇', '100 يوم', Icons.military_tech_rounded, AppColors.gold, has100Days, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(String title, String target, IconData icon, Color color, bool isUnlocked, bool isDark) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUnlocked ? color.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.08),
            border: Border.all(
              color: isUnlocked ? color.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 28,
            color: isUnlocked ? color : Colors.grey.shade500,
          ),
        ),
        const Gap(8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
            color: isUnlocked ? (isDark ? Colors.white : AppColors.card) : Colors.grey.shade500,
          ),
        ),
        Text(
          target,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 9,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
