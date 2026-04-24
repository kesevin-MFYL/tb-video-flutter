import 'package:editvideo/config/color/colors.dart';
import 'package:editvideo/utils/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 日期选择器
class DatePickerWidget extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onChanged;

  const DatePickerWidget({super.key, this.initialDate, this.onChanged});

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  late int currentMonth;
  late int currentDay;
  late int currentYear;

  int dayCount = 31;
  int monthCount = 12;
  late int minYear;
  late int yearCount;

  late PageController monthController;
  late PageController dayController;
  late PageController yearController;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    DateTime initial = widget.initialDate ?? now;
    if (initial.isAfter(now)) {
      initial = now;
    }

    currentMonth = initial.month;
    currentDay = initial.day;
    currentYear = initial.year;

    minYear = now.year - 30;
    yearCount = now.year - minYear + 1;
    if (yearCount < 1) yearCount = 1;

    computeDay(animate: false);

    monthController = PageController(viewportFraction: 40 / 184, initialPage: currentMonth - 1);
    dayController = PageController(viewportFraction: 40 / 184, initialPage: currentDay - 1);
    yearController = PageController(viewportFraction: 40 / 184, initialPage: currentYear - minYear);
  }

  void computeDay({bool animate = true}) {
    final now = DateTime.now();

    if (currentYear > now.year) currentYear = now.year;

    monthCount = (currentYear == now.year) ? now.month : 12;
    if (currentMonth > monthCount) {
      currentMonth = monthCount;
      if (animate && monthController.hasClients) {
        monthController.jumpToPage(currentMonth - 1);
      }
    }

    int maxDayInMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    dayCount = (currentYear == now.year && currentMonth == now.month) ? now.day : maxDayInMonth;

    if (currentDay > dayCount) {
      currentDay = dayCount;
      if (animate && dayController.hasClients) {
        dayController.jumpToPage(currentDay - 1);
      }
    }
  }

  onChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(
        DateTime.parse(
          '$currentYear-${currentMonth < 10 ? '0$currentMonth' : currentMonth}-${currentDay < 10 ? '0$currentDay' : currentDay}',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 184,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: CommonColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: PageView(
                      controller: monthController,
                      onPageChanged: (index) {
                        setState(() {
                          currentMonth = index + 1;
                          computeDay();
                          onChanged();
                        });
                      },
                      scrollDirection: Axis.vertical,
                      children: months
                          .sublist(0, monthCount)
                          .map(
                            (m) => Center(
                              child: CommonText.instance(
                                m,
                                months.indexOf(m) == currentMonth - 1 ? 18.sp : 16.sp,
                                color: months.indexOf(m) == currentMonth - 1
                                    ? CommonColors.white.withOpacity(0.9)
                                    : CommonColors.white.withOpacity(0.6),
                                fontWeight: months.indexOf(m) == currentMonth - 1
                                    ? CommonFontWeight.semiBold
                                    : CommonFontWeight.regular,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: dayController,
                      onPageChanged: (index) {
                        setState(() {
                          currentDay = index + 1;
                          computeDay();
                        });
                        onChanged();
                      },
                      scrollDirection: Axis.vertical,
                      children: [
                        ...List.generate(dayCount, (index) {
                          bool isSelected = index + 1 == currentDay;
                          return Center(
                            child: CommonText.instance(
                              "${index + 1}",
                              isSelected ? 18.sp : 16.sp,
                              color: isSelected
                                  ? CommonColors.white.withOpacity(0.9)
                                  : CommonColors.white.withOpacity(0.6),
                              fontWeight: isSelected ? CommonFontWeight.semiBold : CommonFontWeight.regular,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: yearController,
                      onPageChanged: (index) {
                        setState(() {
                          currentYear = index + minYear;
                          computeDay();
                          onChanged();
                        });
                      },
                      scrollDirection: Axis.vertical,
                      children: [
                        ...List.generate(yearCount, (index) {
                          bool isSelected = index + minYear == currentYear;
                          return Center(
                            child: CommonText.instance(
                              "${index + minYear}",
                              isSelected ? 18.sp : 16.sp,
                              color: isSelected
                                  ? CommonColors.white.withOpacity(0.9)
                                  : CommonColors.white.withOpacity(0.6),
                              fontWeight: isSelected ? CommonFontWeight.semiBold : CommonFontWeight.regular,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [CommonColors.color333333.withAlpha((255 * 0.5).toInt()), CommonColors.color333333],
                        begin: Alignment.center,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [CommonColors.color333333.withAlpha((255 * 0.5).toInt()), CommonColors.color333333],
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
