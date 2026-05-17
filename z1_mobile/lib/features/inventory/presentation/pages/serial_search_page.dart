import 'package:flutter/cupertino.dart';

class SerialSearchPage extends StatelessWidget {
  const SerialSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('序列号查询'),
      ),
      child: Center(
        child: Text('序列号查询页面 - 待实现'),
      ),
    );
  }
}