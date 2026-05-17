import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class TransferDetailPage extends StatelessWidget {
  final int id;

  const TransferDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('调拨详情'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
      ),
      child: Center(
        child: Text('调拨详情页面 - ID: $id'),
      ),
    );
  }
}