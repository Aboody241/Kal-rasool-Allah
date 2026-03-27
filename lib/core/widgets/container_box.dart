import 'package:flutter/material.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

class ContainerBox extends StatefulWidget {
  const ContainerBox({super.key, required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  State<ContainerBox> createState() => _ContainerBoxState();
}

class _ContainerBoxState extends State<ContainerBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(width: 2, color: AppColors.secondary),
        borderRadius: BorderRadius.circular(20)
      ),
      child: widget.child,
    );
  }
}
