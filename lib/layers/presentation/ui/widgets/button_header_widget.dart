import 'package:flutter/material.dart';

class ButtonHeaderWidget extends StatelessWidget {
  final Widget widget;
  final void Function()? onPressed;
  const ButtonHeaderWidget({super.key, this.onPressed, required this.widget});

  @override
  Widget build(context) {
    return Row(
      children: [
        IconButton(onPressed: onPressed, icon: widget),
        const SizedBox(width: 16),
      ],
    );
  }
}
