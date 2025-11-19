import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import 'app_svg_icon.dart';

class BottomNavCurvePainter extends CustomPainter {
  BottomNavCurvePainter({
    Color? backgroundColor,
    this.gradient,
    this.insetRadius = 38,
  }) : backgroundColor = backgroundColor ?? Colors.black;

  final Color backgroundColor;
  final LinearGradient? gradient;
  final double insetRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    if (gradient != null) {
      paint.shader = gradient!.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height + 56),
      );
    } else {
      paint.color = backgroundColor;
    }

    final path = Path()..moveTo(0, 12);
    final insetCurveBeginnningX = size.width / 2 - insetRadius;
    final insetCurveEndX = size.width / 2 + insetRadius;
    final transitionToInsetCurveWidth = size.width * .05;

    path.quadraticBezierTo(
      size.width * 0.20,
      0,
      insetCurveBeginnningX - transitionToInsetCurveWidth,
      0,
    );
    path.quadraticBezierTo(
      insetCurveBeginnningX,
      0,
      insetCurveBeginnningX,
      insetRadius / 2,
    );
    path.arcToPoint(
      Offset(insetCurveEndX, insetRadius / 2),
      radius: const Radius.circular(10.0),
      clockwise: false,
    );
    path.quadraticBezierTo(
      insetCurveEndX,
      0,
      insetCurveEndX + transitionToInsetCurveWidth,
      0,
    );
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 12);
    path.lineTo(size.width, size.height + 56);
    path.lineTo(0, size.height + 56);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CustomNavBarCurved extends StatefulWidget {
  const CustomNavBarCurved({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    this.onFabPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback? onFabPressed;

  @override
  State<CustomNavBarCurved> createState() => CustomNavBarCurvedState();
}

class CustomNavBarCurvedState extends State<CustomNavBarCurved> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(CustomNavBarCurved oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() => _selectedIndex = widget.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const height = 56.0;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size.width, height + 7),
            painter: BottomNavCurvePainter(
              backgroundColor: backgroundColor,
              gradient: AppGradients.primary,
            ),
          ),
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              backgroundColor: primaryColor,
              elevation: 0.1,
              onPressed: widget.onFabPressed,
              child: const AppSvgIcon(
                assetName: AppIcons.wind,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarIcon(
                  text: AppStrings.dashboard,
                  iconAsset: AppIcons.dashboard,
                  selected: _selectedIndex == 0,
                  onPressed: () => _onNavBarItemTapped(0),
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
                NavBarIcon(
                  text: AppStrings.invoices,
                  iconAsset: AppIcons.receipt,
                  selected: _selectedIndex == 1,
                  onPressed: () => _onNavBarItemTapped(1),
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
                const SizedBox(width: 56),
                NavBarIcon(
                  text: AppStrings.payroll,
                  iconAsset: AppIcons.team,
                  selected: _selectedIndex == 2,
                  onPressed: () => _onNavBarItemTapped(2),
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
                NavBarIcon(
                  text: AppStrings.settings,
                  iconAsset: AppIcons.settings,
                  selected: _selectedIndex == 3,
                  onPressed: () => _onNavBarItemTapped(3),
                  defaultColor: secondaryColor,
                  selectedColor: primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onNavBarItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    widget.onItemSelected(index);
  }
}

class NavBarIcon extends StatelessWidget {
  const NavBarIcon({
    super.key,
    required this.text,
    required this.iconAsset,
    required this.selected,
    required this.onPressed,
    this.selectedColor = const Color(0xffFF8527),
    this.defaultColor = Colors.black54,
  });

  final String text;
  final String iconAsset;
  final bool selected;
  final VoidCallback onPressed;
  final Color defaultColor;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : defaultColor;
    return IconButton(
      onPressed: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: CircleAvatar(
        backgroundColor: selected ? Colors.white : Colors.transparent,
        child: AppSvgIcon(assetName: iconAsset, size: 24, color: color),
      ),
    );
  }
}
