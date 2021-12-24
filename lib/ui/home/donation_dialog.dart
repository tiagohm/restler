import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class DonationDialog extends StatefulWidget {
  const DonationDialog({
    Key key,
  }) : super(key: key);

  static Future<DialogResult<bool>> show(
    BuildContext context,
  ) async {
    return showDialog<DialogResult<bool>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DonationDialog(),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _DonationDialogState();
  }
}

class _DonationDialogState extends State<DonationDialog>
    with StateMixin<DonationDialog> {
  final _products = <_Product>[];
  final _selectedProduct = ValueNotifier<_Product>(null);

  @override
  void initState() {
    _initInAppPurchase();
    super.initState();
  }

  @override
  void dispose() {
    _endInAppPurchase();
    _selectedProduct.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<bool>(
      doneText: i18n.donate,
      onDone: _onDonate,
      title: i18n.donation,
      bodyBuilder: (context) {
        return Container(
          width: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Message.
              Text(i18n.donateMessage),
              // Products.
              ValueListenableBuilder<_Product>(
                valueListenable: _selectedProduct,
                builder: (context, product, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      // Product.
                      return RadioListTile<_Product>(
                        title: Text(_products[index].price),
                        value: _products[index],
                        groupValue: _selectedProduct.value,
                        onChanged: (item) {
                          print('${item.id}: ${item.price}');
                          _selectedProduct.value = item;
                        },
                      );
                    },
                  );
                },
              ),
              // Instruction.
              Text(i18n.donateInstruction),
            ],
          ),
        );
      },
    );
  }

  Future<void> _initInAppPurchase() async {
    final result = await FlutterInappPurchase.instance.initConnection;
    print('Established IAP Connection: $result');

    // Produtos disponíveis para a compra.
    final availableProducts = await FlutterInappPurchase.instance.getProducts(
      ['0_buy_me_a_coffee', '1_buy_me_two_coffees', '2_buy_me_four_coffees'],
    );

    _products.clear();

    // Percorre todos os produtos já comprados e atribui seu token.
    for (final item in availableProducts) {
      _products.add(_Product(item.productId, item.localizedPrice));
    }

    // Ordena do menor preço ao maior preço.
    _products.sort((a, b) => a.id.compareTo(b.id));

    // Seleciona o primeiro produto.
    if (_products.isNotEmpty) {
      _selectedProduct.value = _products[0];
    }
  }

  Future<void> _endInAppPurchase() async {
    final result = await FlutterInappPurchase.instance.endConnection;
    print('Closed IAP Connection: $result');
  }

  Future<bool> _onDonate() async {
    final _product = _selectedProduct.value;
    StreamSubscription subscription0, subscription1;
    final result = Completer<bool>();

    if (_product == null) {
      return null;
    }

    // Vamos consumir tudo da lista de produtos comprados e que ainda não foram consumidos.

    try {
      final purchases =
          await FlutterInappPurchase.instance.getAvailablePurchases();

      for (final item in purchases) {
        print('Consuming product ${item.productId} before purchase it again');
        await FlutterInappPurchase.instance
            .consumePurchaseAndroid(item.purchaseToken);
      }
    } catch (e) {
      // nada.
    }

    // Vamos comprar o produto.

    try {
      print('Buying product ${_product.id}');

      subscription0 =
          FlutterInappPurchase.purchaseUpdated.listen((purchase) async {
        print('Product purchased: $purchase');

        if (purchase != null) {
          // Como queremos que o usuário possa comprar novamente, vamos consumir ele.
          print('Consuming product ${_product.id}');
          await FlutterInappPurchase.instance
              .consumePurchaseAndroid(purchase.purchaseToken);
          print('Product consumed');
        }

        result.complete(purchase != null);
      });

      subscription1 = FlutterInappPurchase.purchaseError.listen((error) async {
        print('Purchase error: $error');
        // Dont close the dialog.
        result.complete(null);
      });

      // Dont add await!
      FlutterInappPurchase.instance.requestPurchase(_product.id);
    } catch (e) {
      print(e);
      result.complete(false);
    }

    return result.future.whenComplete(() async {
      print('completed');
      await subscription0?.cancel();
      await subscription1?.cancel();
    });
  }
}

class _Product {
  final String id;
  final String price;

  _Product(this.id, this.price);
}
