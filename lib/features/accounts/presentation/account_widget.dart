import 'package:financer/features/accounts/domain/account.dart';
import 'package:flutter/material.dart';

import '../../../core/util/fixed_point_helper.dart';
import '../../../core/widgets/hoverable_card.dart';

class AccountWidget extends StatelessWidget {
  final Account account;

  const AccountWidget({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return HoverableCard(
      onTap: () {

      },
      borderColor: Theme.of(context).colorScheme.secondary,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: account.type.icon,
          ),
          Expanded(
            child: Text(
              account.name,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Text(
              "${FixedPointHelper.priceToString(account.currentBalance)} ${account.currency}",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}