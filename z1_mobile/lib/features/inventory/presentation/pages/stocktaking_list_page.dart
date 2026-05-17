import 'package:flutter/cupertino.dart';

class StocktakingListPage extends StatelessWidget {
  const StocktakingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('盘库'),
      ),
      child: Center(
        child: Text('盘库页面 - 待实现'),
      ),
    );
  }
}