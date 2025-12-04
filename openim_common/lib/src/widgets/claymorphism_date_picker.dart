// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class ClaymorphismDatePicker extends StatefulWidget {
  const ClaymorphismDatePicker({
    super.key,
    required this.title,
    required this.initialDate,
    required this.onConfirm,
    this.minDate,
    this.maxDate,
    this.icon,
    this.onCancel,
  });

  final String title;
  final DateTime initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final IconData? icon;
  final Function(DateTime date) onConfirm;
  final Function()? onCancel;

  @override
  State<ClaymorphismDatePicker> createState() => _ClaymorphismDatePickerState();
}

class _ClaymorphismDatePickerState extends State<ClaymorphismDatePicker> {
  late DateTime selectedDate;
  late PageController pageController;
  late DateTime currentDisplayDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    currentDisplayDate = DateTime(selectedDate.year, selectedDate.month, 1);
    pageController = PageController(
      initialPage: _getInitialPage(),
    );
  }

  int _getInitialPage() {
    final minDate = widget.minDate ?? DateTime(1900);
    final yearDiff = currentDisplayDate.year - minDate.year;
    final monthDiff = currentDisplayDate.month - minDate.month;
    return yearDiff * 12 + monthDiff;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 12.r,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            20.verticalSpace,

            // Header with icon and title
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                curve: Curves.easeOutCubic,
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            widget.icon!,
                            size: 18.w,
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                        12.horizontalSpace,
                      ],
                      Text(
                        widget.title,
                        style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151
    ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            24.verticalSpace,

            // Calendar Section
            Expanded(
              child: AnimationConfiguration.staggeredList(
                position: 1,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  curve: Curves.easeOutCubic,
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9CA3AF).withOpacity(0.06),
                            offset: const Offset(0, 2),
                            blurRadius: 6.r,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFF3F4F6),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Month/Year Header
                          _buildMonthYearHeader(),

                          // Calendar
                          Expanded(
                            child: PageView.builder(
                              controller: pageController,
                              onPageChanged: _onPageChanged,
                              itemBuilder: (context, index) {
                                final date = _getDateForPage(index);
                                return _buildCalendarPage(date);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            24.verticalSpace,

            // Action Buttons
            _buildActionButtons(),

            24.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildMonthYearHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Previous button
          GestureDetector(
            onTap: _previousMonth,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Icon(
                CupertinoIcons.chevron_left,
                size: 18.w,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),

          // Month/Year display
          Expanded(
            child: Column(
              children: [
                Text(
                  _getMonthYearText(),
                  style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151
    ),
                  ),
                ),
                2.verticalSpace,
                Text(
                  _getSelectedDateText(),
                  style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280
    ),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // Next button
          GestureDetector(
            onTap: _nextMonth,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Icon(
                CupertinoIcons.chevron_right,
                size: 18.w,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPage(DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstWeekDay = firstDayOfMonth.weekday;

    final startingWeekday =
        firstWeekDay == 7 ? 0 : firstWeekDay; // Convert Sunday from 7 to 0

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280
    ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          16.verticalSpace,

          // Calendar grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 42, // 6 weeks
              itemBuilder: (context, index) {
                final dayIndex = index - startingWeekday;

                if (dayIndex < 0 || dayIndex >= daysInMonth) {
                  return const SizedBox();
                }

                final day = dayIndex + 1;
                final dayDate = DateTime(date.year, date.month, day);
                final isSelected = _isSameDay(dayDate, selectedDate);
                final isToday = _isSameDay(dayDate, DateTime.now());

                return GestureDetector(
                  onTap: () => _selectDate(dayDate),
                  child: AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 400),
                    columnCount: 7,
                    child: ScaleAnimation(
                      curve: Curves.easeOutCubic,
                      child: FadeInAnimation(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFBBF24)
                                : isToday
                                    ? const Color(0xFFFBBF24).withOpacity(0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                            border: isToday && !isSelected
                                ? Border.all(
                                    color: const Color(0xFFFBBF24),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              day.toString(),
                              style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 16.sp,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? const Color(0xFFFBBF24
    )
                                        : const Color(0xFF374151),
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
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Cancel Button
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 16.w, right: 8.w),
            child: GestureDetector(
              onTap: widget.onCancel ?? () => Get.back(),
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9CA3AF).withOpacity(0.06),
                      offset: const Offset(0, 2),
                      blurRadius: 6.r,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    StrRes.cancel,
                    style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280
    ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Confirm Button
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 8.w, right: 16.w),
            child: GestureDetector(
              onTap: () {
                Get.back();
                widget.onConfirm(selectedDate);
              },
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9CA3AF).withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 6.r,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        size: 20.w,
                        color: Colors.white,
                      ),
                      8.horizontalSpace,
                      Text(
                        StrRes.confirm,
                        style: TextStyle(
      fontFamily: 'FilsonPro',
      fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
    ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthYearText() {
    final months = [
      StrRes.january,
      StrRes.february,
      StrRes.march,
      StrRes.april,
      StrRes.may,
      StrRes.june,
      StrRes.july,
      StrRes.august,
      StrRes.september,
      StrRes.october,
      StrRes.november,
      StrRes.december
    ];
    return '${months[currentDisplayDate.month - 1]} ${currentDisplayDate.year}';
  }

  String _getSelectedDateText() {
    return '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
  }

  DateTime _getDateForPage(int page) {
    final minDate = widget.minDate ?? DateTime(1900);
    final yearAdd = page ~/ 12;
    final monthAdd = page % 12;
    return DateTime(minDate.year + yearAdd, minDate.month + monthAdd, 1);
  }

  void _onPageChanged(int page) {
    setState(() {
      currentDisplayDate = _getDateForPage(page);
    });
  }

  void _previousMonth() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextMonth() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
