import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';

// 60×60dp hitbox back arrow (spec 02 §Child Side, spec 11 §Hitbox sizes).
class ChildBackButton extends StatelessWidget {
  const ChildBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          iconSize: 40,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back_rounded, color: kTextPrimary),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
    );
  }
}
