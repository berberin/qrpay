import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Avatar extends StatelessWidget {
  final String svg;
  final double size;

  const Avatar({Key key, @required this.svg, @required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svg,
      fit: BoxFit.contain,
      height: size,
      width: size,
    );
  }
}
