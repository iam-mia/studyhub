import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CashewSheetHandle extends StatelessWidget {
  const CashewSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4.5,
        decoration: BoxDecoration(
          color: getColor(context, "dividerColor").withOpacity(0.25),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

Future<T?> showCashewModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
}) {
  final isDesktop = MediaQuery.of(context).size.width >= 720;

  if (isDesktop) {
    // On desktop, display as elegant centered dialog with max width
    return showDialog<T>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: getColor(context, "lightDarkAccent"),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
          child: builder(ctx),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: getColor(context, "lightDarkAccent"),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: builder(ctx),
    ),
  );
}
