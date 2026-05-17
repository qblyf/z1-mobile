import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class TransferAddPage extends StatelessWidget {
  const TransferAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('新建调拨'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
      ),
      child: const Center(
        child: Text('新建调拨页面 - 待实现'),
      ),
    );
  }
}