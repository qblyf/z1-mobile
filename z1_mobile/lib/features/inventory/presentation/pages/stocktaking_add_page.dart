import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../injection.dart';
import '../../data/models/stocktaking_model.dart';
import '../bloc/stocktaking_detail_bloc.dart';

class StocktakingAddPage extends StatefulWidget {
  const StocktakingAddPage({super.key});

  @override
  State<StocktakingAddPage> createState() => _StocktakingAddPageState();
}

class _StocktakingAddPageState extends State<StocktakingAddPage> {
  late final StocktakingAddBloc _bloc;
  final TextEditingController _remarksController = TextEditingController();
  WarehouseModel? _selectedWarehouse;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<StocktakingAddBloc>();
    _bloc.add(const StocktakingLoadWarehousesRequested());
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<StocktakingAddBloc, StocktakingAddState>(
        listener: (context, state) {
          if (state is StocktakingAddSuccess) {
            context.pushReplacement(
                '/inventory/stocktaking/${state.stocktakingId}');
          } else if (state is StocktakingAddError) {
            showCupertinoDialog(
              context: context,
              builder: (ctx) => CupertinoAlertDialog(
                title: const Text('创建失败'),
                content: Text(state.message),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('确定'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          List<WarehouseModel> warehouses = [];
          bool isLoading = false;
          bool isSubmitting = false;

          if (state is StocktakingAddLoading) {
            isLoading = true;
          } else if (state is StocktakingAddWarehouseLoaded) {
            warehouses = state.warehouses;
          } else if (state is StocktakingAddSubmitting) {
            warehouses = state.warehouses;
            isSubmitting = true;
          } else if (state is StocktakingAddError) {
            warehouses = state.warehouses;
          }

          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('新建盘库'),
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.back),
                onPressed: () => context.pop(),
              ),
            ),
            child: SafeArea(
              child: isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '选择仓库',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () =>
                                _showWarehousePicker(context, warehouses),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: CupertinoColors.separator),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedWarehouse?.name ?? '请选择仓库',
                                    style: TextStyle(
                                      color: _selectedWarehouse != null
                                          ? CupertinoColors.label
                                          : CupertinoColors.tertiaryLabel,
                                    ),
                                  ),
                                  const Icon(
                                    CupertinoIcons.chevron_down,
                                    color: CupertinoColors.secondaryLabel,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '备注',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CupertinoTextField(
                            controller: _remarksController,
                            placeholder: '可选填写备注信息',
                            maxLines: 3,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: CupertinoColors.separator),
                            ),
                          ),
                          const Spacer(),
                          CupertinoButton(
                            color: CupertinoColors.activeBlue,
                            borderRadius: BorderRadius.circular(12),
                            onPressed:
                                _selectedWarehouse != null && !isSubmitting
                                    ? () => _submit()
                                    : null,
                            child: isSubmitting
                                ? const CupertinoActivityIndicator(
                                    color: CupertinoColors.white)
                                : const Text(
                                    '创建盘库单',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _showWarehousePicker(
      BuildContext context, List<WarehouseModel> warehouses) {
    if (warehouses.isEmpty) return;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('取消'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('确定'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedWarehouse = warehouses[index];
                  });
                },
                children:
                    warehouses.map((w) => Center(child: Text(w.name))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_selectedWarehouse == null) return;

    _bloc.add(StocktakingAddSubmitted(
      warehouseID: _selectedWarehouse!.id,
      remarks:
          _remarksController.text.isNotEmpty ? _remarksController.text : null,
    ));
  }
}
