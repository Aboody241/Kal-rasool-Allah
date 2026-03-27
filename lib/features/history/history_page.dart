import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/container_box.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // ✅ الأيام المكتملة
  final Set<int> completedDays = {1};
  final int totalDays = 30;
  DateTime _currentDate = DateTime.now();

  // ✅ بناء EventList من الأيام المكتملة
  EventList<Event> _buildMarkedDates() {
    final Map<DateTime, List<Event>> events = {};
    for (final day in completedDays) {
      final date = DateTime(_currentDate.year, _currentDate.month, day);
      events[date] = [Event(date: date)];
    }
    return EventList<Event>(events: events);
  }

  @override
  Widget build(BuildContext context) {
    final int completedCount = completedDays.length;
    final double progress = completedCount / totalDays;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const Gap(10),
              Text('سجل التقدم', style: AppTextStyles.title),
              const Gap(12),
              Text(
                'إستمر في المواظبة علي السُنن اليومية',
                style: AppTextStyles.subTitle.copyWith(
                  color: AppColors.darkGray,
                ),
              ),
              const Gap(30),

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
                        Text('هذا الشهر', style: AppTextStyles.subTitle),
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
                    // ✅ الشهر الحالي
                    targetDateTime: _currentDate,
                    selectedDateTime: _currentDate,

                    // ✅ الأيام المكتملة
                    markedDatesMap: _buildMarkedDates(),

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
                                  : AppColors.secondary,
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
                                        color: AppColors.mediumGray,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          );
                        },

                    // ✅ تغيير الشهر بالسوايب
                    onCalendarChanged: (DateTime date) {
                      setState(() => _currentDate = date);
                    },

                    // ✅ الضغط على يوم
                    onDayPressed: (DateTime date, List<Event> events) {
                      setState(() => _currentDate = date);
                    },

                    // ✅ تنسيق الـ Header
                    headerTextStyle: AppTextStyles.subTitle,
                    headerMargin: const EdgeInsets.only(bottom: 10),

                    // ✅ تنسيق أيام الأسبوع
                    weekdayTextStyle: TextStyle(
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
                    showOnlyCurrentMonthDate: true,

                    // ✅ RTL
                    isScrollable: true,
                    scrollDirection: Axis.horizontal,
                    locale: 'ar',
                  ),
                ),
              ),
              Gap(20),

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
