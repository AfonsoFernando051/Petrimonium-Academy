import 'package:flutter/material.dart';
import 'package:petrimonium/core/constants/app_colors.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_event.dart';
import 'package:petrimonium/features/portfolio/domain/entities/dividend_type_display.dart';
import 'package:petrimonium/core/utils/formatters.dart';

/// One confirmed corporate-action row inside the Dividend Radar — either an
/// upcoming announced payment or a past paid one. [showAsReceived] switches
/// the copy between "você deve receber" (forward-looking) and "você recebeu"
/// (confirmed past), since the underlying `DividendEvent.status` already
/// guarantees the amount is scaled by the quantity the user actually held at
/// the relevant date (see `GetDividendRadarUseCaseImpl.quantityHeldAsOf`).
class DividendEventTile extends StatelessWidget {
  const DividendEventTile({super.key, required this.event});

  final DividendEvent event;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final isPaid = event.status == DividendStatus.PAID;
    final date = isPaid ? event.paymentDate : (event.paymentDate ?? event.dataCom);
    final typeColor = event.type.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: typeColor.withValues(alpha: 0.4)),
            ),
            child: Icon(event.type.icon, size: 16, color: typeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      event.ticker,
                      style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.type.label,
                        style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  date != null
                      ? '${isPaid ? 'Pago em' : 'Pagamento em'} ${AppFormatters.date(date)}'
                      : 'Data de pagamento a confirmar',
                  style: TextStyle(color: tokens.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currency(event.estimatedGrossAmount),
                style: TextStyle(
                  color: isPaid ? tokens.success : AppColors.goldenBorder,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${event.userQuantity.toStringAsFixed(0)} cotas · ${AppFormatters.currency(event.ratePerShare)}/cota',
                style: TextStyle(color: tokens.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
