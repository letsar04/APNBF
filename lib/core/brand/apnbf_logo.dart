import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ApnbfLogo extends StatelessWidget {
  const ApnbfLogo({super.key, this.height = 42, this.compact = false});
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/brand/apnbf_logo.svg',
      height: height,
      fit: BoxFit.contain,
      semanticsLabel: 'APNBF',
    );
  }
}
