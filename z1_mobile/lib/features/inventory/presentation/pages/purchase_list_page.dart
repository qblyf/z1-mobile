import 'package:flutter/cupertino.dart';

class PurchaseListPage extends StatelessWidget {
  const PurchaseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('采购'),
      ),
      child: Center(
        child: Text('采购页面 - 待实现'),
      ),
    );
  }
}