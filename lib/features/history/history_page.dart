import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/container_box.dart';
import 'package:kal_rasol_allah/core/widgets/pages_title.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  // ✅ الأيام المكتملة
  final Set<int> completedDays = {1};
  final int totalDays = 30;
  DateTime _currentDate = DateTime.now();

  // ✅ تخزين الـ markedDates بدل إعادة حسابها كل build
  late EventList<Event> _markedDates = _buildMarkedDates();

  EventList<Event> _buildMarkedDates() {
    final Map<DateTime, List<Event>> events = {};
    for (final day in completedDays) {
      final date = DateTime(_currentDate.year, _currentDate.month, day);
      events[date] = [Event(date: date)];
    }
    return EventList<Event>(events: events);
  }

  void _updateMarkedDates() {
    _markedDates = _buildMarkedDates();
  }

  @override
  Widget build(BuildContext context) {
    final int completedCount = completedDays.length;
    final double progress = completedCount / totalDays;
    final isDark = ref.watch(ThemeRiverPod);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const Gap(10),
        const      PagesTitle(
                title: 'سجل التقدم',
                subtitle: 'إستمر في المواظبة علي السُنن اليومية',
              ),

              // ✅ Progress Card
              ContainerBox(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'هذا الشهر',
                          style: AppTextStyles.subTitle.copyWith(
                            color: isDark
                                ? AppColors.lightGray
                                : AppColors.card,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.subTitle.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    LinearProgressIndicator(
                      value: progress,
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(50),
                      minHeight: 13,
                      backgroundColor: isDark
                          ? AppColors.mediumGray
                          : AppColors.offWhite,
                    ),
                    const Gap(15),
                    Text(
                      '$completedCount من $totalDays يوم',
                      style: AppTextStyles.small.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),

              const Gap(20),

              // ✅ Calendar Card
              ContainerBox(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                child: SizedBox(
                  height: 330,
                  child: CalendarCarousel<Event>(
                    firstDayOfWeek: 6,
                    // ✅ الشهر الحالي
                    targetDateTime: _currentDate,
                    selectedDateTime: _currentDate,

                    // ✅ الأيام المكتملة
                    markedDatesMap: _markedDates,

                    // ✅ تخصيص كل يوم
                    customDayBuilder:
                        (
                          bool isSelectable,
                          int index,
                          bool isSelectedDay,
                          bool isToday,
                          bool isPrevMonthDay,
                          TextStyle textStyle,
                          bool isNextMonthDay,
                          bool isThisMonthDay,
                          DateTime day,
                        ) {
                          final bool isCompleted =
                              completedDays.contains(day.day) &&
                              day.month == _currentDate.month;

                          if (!isThisMonthDay) return null;

                          return Container(
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.primaryGreen
                                  : isDark
                                  ? AppColors.secondary
                                  : AppColors.mediumGray,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.mediumGray
                                            : AppColors.card,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          );
                        },

                    // ✅ تغيير الشهر بالسوايب
                    onCalendarChanged: (DateTime date) {
                      setState(() {
                        _currentDate = date;
                        _updateMarkedDates();
                      });
                    },

                    // ✅ الضغط على يوم
                    onDayPressed: (DateTime date, List<Event> events) {
                      setState(() {
                        _currentDate = date;
                        _updateMarkedDates();
                      });
                    },

                    // ✅ تنسيق الـ Header
                    headerTextStyle: AppTextStyles.subTitle,
                    headerMargin: const EdgeInsets.only(bottom: 10),

                    // ✅ تنسيق أيام الأسبوع
                    weekdayTextStyle: const TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),

                    // ✅ إخفاء الـ borders الافتراضية
                    thisMonthDayBorderColor: Colors.transparent,
                    selectedDayBorderColor: Colors.transparent,
                    selectedDayButtonColor: Colors.transparent,
                    todayBorderColor: Colors.transparent,
                    todayButtonColor: Colors.transparent,
                    dayButtonColor: Colors.transparent,

                    // ✅ إخفاء أيام الشهر السابق والتالي
                    showOnlyCurrentMonthDate: false,

                    // ✅ RTL
                    isScrollable: false,
                    scrollDirection: Axis.horizontal,
                    locale: 'ar',
                  ),
                ),
              ),
              const Gap(20),

              Text(
                '"إن احب الاعمال إلي الله ادومها وإن قل"',
                style: AppTextStyles.small,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
