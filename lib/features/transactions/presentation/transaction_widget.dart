import 'package:financer/core/util/fixed_point_helper.dart';
import 'package:financer/core/widgets/hoverable_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/database/database.dart';

class TransactionWidget extends StatelessWidget {
  final Transaction transaction;

  const TransactionWidget({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      onTap: () {

      },
      borderColor: transaction.type.color,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: transaction.type.icon,
          ),
          Expanded(
            child: Text(
              transaction.name,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${priceToString(transaction.baseAmount)} RSD",
                  style: const TextStyle(fontSize: 18),
                ),
                if (transaction.convertedAmount !=
                    transaction.baseAmount) ...[
                  const SizedBox(width: 8),
                  Text(
                    "(${priceToString(
                        transaction.convertedAmount)} RSD)",
                    style: const TextStyle(fontSize: 14),
                  )
                ]
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: Text(
              transaction.date.toString().split(' ')[0],
            ),
          )
        ],
      ),
    );
  }
}