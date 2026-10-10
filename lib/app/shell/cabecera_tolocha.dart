import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CabeceraTolocha extends StatelessWidget {
  const CabeceraTolocha({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset('assets/icons/tolocha.svg', width: 28, height: 28),
        const SizedBox(width: 8),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Tolocha'),
                TextSpan(
                  text: 'Fuel',
                  style: TextStyle(color: tema.colorScheme.primary),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            style: tema.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}
