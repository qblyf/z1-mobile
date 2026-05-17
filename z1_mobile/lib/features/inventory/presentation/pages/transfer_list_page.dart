import 'package:flutter/cupertino.dart';

class TransferListPage extends StatelessWidget {
  const TransferListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('调拨'),
      ),
      child: Center(
        child: Text('调拨页面 - 待实现'),
      ),
    );
  }
}