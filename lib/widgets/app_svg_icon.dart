import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon({
    super.key,
    required this.assetName,
    this.size = 20,
    this.color,
    this.semanticLabel,
  });

  final String assetName;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      semanticsLabel: semanticLabel,
    );
  }
}
