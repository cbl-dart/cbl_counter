import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class NumberCounter extends StatelessWidget {
  const NumberCounter({
    Key? key,
    required this.number,
    this.style,
  }) : super(key: key);

  final int number;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final digits = number.toString().split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: digits
          .mapIndexed((index, digit) => AnimatedSwitcher(
                key: ValueKey(digits.length - 1 - index),
                duration: const Duration(milliseconds: 200),
                child: Text(
                  digit,
                  key: ValueKey(digit),
                  style: style,
                ),
              ))
          .toList(),
    );
  }
}
