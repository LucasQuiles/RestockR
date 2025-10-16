import 'package:flutter/material.dart';
import '../../core/app_export.dart';

class HelpTutorialModal extends StatefulWidget {
  const HelpTutorialModal({Key? key}) : super(key: key);

  @override
  State<HelpTutorialModal> createState() => _HelpTutorialModalState();
}

class _HelpTutorialModalState extends State<HelpTutorialModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialSlide> _slides = [
    TutorialSlide(
      title: 'Welcome to RestockR',
      description:
          'Track product restocks in real-time and never miss a drop again. Swipe to learn how to use the app.',
      icon: Icons.shopping_bag_outlined,
      iconColor: Color(0xFFEF4444),
    ),
    TutorialSlide(
      title: 'Managing Your Watchlist',
      description:
          'Tap the watchlist icon to view all tracked products. Use the + button to add products, or tap the star icon on any product to toggle subscriptions.',
      icon: Icons.star_border_outlined,
      iconColor: Color(0xFFEAB308),
      tips: [
        'Star icon adds/removes products',
        'Manage all at once in "Manage Watchlist"',
        'View subscription count in profile',
      ],
    ),
    TutorialSlide(
      title: 'Restock History',
      description:
          'View detailed restock activity with our interactive heatmap. Tap any date to see hourly breakdowns and restock patterns.',
      icon: Icons.calendar_today_outlined,
      iconColor: Color(0xFF3B82F6),
      tips: [
        'Heatmap shows daily activity',
        'Tap dates for hourly details',
        'Filter by date range',
      ],
    ),
    TutorialSlide(
      title: 'Filters & Settings',
      description:
          'Customize your experience with global filters, retailer-specific overrides, and notification preferences.',
      icon: Icons.tune_outlined,
      iconColor: Color(0xFF8B5CF6),
      tips: [
        'Global filters apply everywhere',
        'Override settings per retailer',
        'Toggle notifications on/off',
      ],
    ),
    TutorialSlide(
      title: 'You\'re All Set!',
      description:
          'Start tracking products and get notified instantly when they restock. Happy hunting!',
      icon: Icons.check_circle_outline,
      iconColor: Color(0xFF10B981),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 40.h),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.h),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16.h),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.h),
                    decoration: BoxDecoration(
                      color: Color(0xFFF4F4F4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20.h,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: _buildSlide(_slides[index]),
                  );
                },
              ),
            ),
            // Page indicator dots
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),
            // Navigation buttons
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 20.h),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: _buildButton(
                        text: 'Back',
                        isPrimary: false,
                        onTap: () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  if (_currentPage > 0) SizedBox(width: 12.h),
                  Expanded(
                    child: _buildButton(
                      text: _currentPage == _slides.length - 1
                          ? 'Get Started'
                          : 'Next',
                      isPrimary: true,
                      onTap: () {
                        if (_currentPage == _slides.length - 1) {
                          Navigator.pop(context);
                        } else {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(TutorialSlide slide) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(24.h),
            decoration: BoxDecoration(
              color: slide.iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 64.h,
              color: slide.iconColor,
            ),
          ),
          SizedBox(height: 32.h),
          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF21252B),
              fontSize: 24.fSize,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 16.fSize,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          // Tips (if any)
          if (slide.tips != null && slide.tips!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12.h),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16.h,
                        color: Color(0xFFEAB308),
                      ),
                      SizedBox(width: 8.h),
                      Text(
                        'Quick Tips',
                        style: TextStyle(
                          color: Color(0xFF21252B),
                          fontSize: 14.fSize,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...slide.tips!.map(
                    (tip) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 6.h),
                            width: 4.h,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Color(0xFF666666),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.h),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 14.fSize,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.h),
      width: isActive ? 24.h : 8.h,
      height: 8.h,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFFEF4444) : Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(4.h),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: isPrimary ? Color(0xFFEF4444) : Colors.white,
          borderRadius: BorderRadius.circular(12.h),
          border: isPrimary
              ? null
              : Border.all(
                  color: Color(0xFFD1D5DB),
                  width: 1.h,
                ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isPrimary ? Colors.white : Color(0xFF666666),
            fontSize: 16.fSize,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class TutorialSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final List<String>? tips;

  TutorialSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.tips,
  });
}
