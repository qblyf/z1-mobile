import 'package:flutter/cupertino.dart';

class PurchaseInboundPage extends StatelessWidget {
  final int id;

  const PurchaseInboundPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('采购入库 #$id'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.cube_box_fill,
                size: 64,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              const Text(
                '采购入库页',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '采购单ID: $id',
                style: const TextStyle(
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '(占位符页面)',
                style: TextStyle(
                  color: CupertinoColors.tertiaryLabel,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}