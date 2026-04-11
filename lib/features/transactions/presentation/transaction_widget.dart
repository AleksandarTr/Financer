import 'package:financer/core/util/fixed_point_helper.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/database/database.dart';

class TransactionWidget extends StatelessWidget {
  final Transaction transaction;

  const TransactionWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: transaction.type.color, width: 2))
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: transaction.type.icon
          ),
          Expanded(child:
            Text(
              transaction.name,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            )
          ),
          Expanded(child:
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${priceToString(transaction.baseAmount)} RSD",
                  style: TextStyle(
                    fontSize: 18,
                    color: transaction.type.color
                  ),
                ),
                if (transaction.convertedAmount != transaction.baseAmount) ...[
                  const SizedBox(width: 8),
                  Text(
                    "(${priceToString(transaction.convertedAmount)} RSD)",
                    style: TextStyle(
                      fontSize: 14,
                      color: transaction.type.color
                    ),
                  )
                ]
              ]
            )
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
                transaction.date.toString().split(' ')[0]
            )
          )
        ],
      ));
  }
}