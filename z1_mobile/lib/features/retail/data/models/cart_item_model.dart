import 'package:equatable/equatable.dart';
import 'product_model.dart';
import 'service_model.dart';

enum CartItemType { goods, service }

class CartItem extends Equatable {
  final int id;
  final CartItemType type;
  final String name;
  final String? specName;
  final int price;
  final int quantity;
  final dynamic item;

  const CartItem({
    required this.id,
    required this.type,
    required this.name,
    this.specName,
    required this.price,
    this.quantity = 1,
    this.item,
  });

  int get subtotal => price * quantity;

  factory CartItem.fromGoodsSku(SkuModel sku, {int quantity = 1}) {
    return CartItem(
      id: sku.skuId,
      type: CartItemType.goods,
      name: sku.skuName,
      specName: null,
      price: sku.price,
      quantity: quantity,
      item: sku,
    );
  }

  factory CartItem.fromService(ServiceModel service, {int quantity = 1}) {
    return CartItem(
      id: service.id,
      type: CartItemType.service,
      name: service.name,
      specName: service.shortName,
      price: service.price,
      quantity: quantity,
      item: service,
    );
  }

  CartItem copyWith({
    int? id,
    CartItemType? type,
    String? name,
    String? specName,
    int? price,
    int? quantity,
    dynamic item,
  }) {
    return CartItem(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      specName: specName ?? this.specName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      item: item ?? this.item,
    );
  }

  @override
  List<Object?> get props => [id, type, name, specName, price, quantity];
}