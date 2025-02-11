import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:tempus/app_state.dart';

class Store {
  static late final InAppPurchase _client;
  static late final StreamSubscription<List<PurchaseDetails>> _subscription;

  static final String _premiumId = "com.lvnlx.tempus.premium";
  static final String _premiumName = "Premium";

  static void init(
      void Function(List<PurchaseDetails> purchaseDetails)
          postInitStateCallback) async {
    _client = InAppPurchase.instance;
    Stream<List<PurchaseDetails>> purchaseUpdated = _client.purchaseStream;
    _subscription = purchaseUpdated.listen(
        (purchaseDetailsList) => postInitStateCallback(purchaseDetailsList),
        onDone: () => _subscription.cancel(),
        onError: (error) => print("Purchase stream error: $error"));
  }

  static void handlePurchaseStreamOnData(
      BuildContext context, List<PurchaseDetails> purchaseDetailsList) {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if(purchaseDetails.pendingCompletePurchase) {
        Provider.of<AppState>(context, listen: false).setIsPremium(true);
        _client.completePurchase(purchaseDetails);
      }
    }
  }

  static Future<void> purchasePremium() async {
    ProductDetails productDetails = await _getPremiumProductDetails();
    PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _client.buyNonConsumable(purchaseParam: purchaseParam);
  }

  static Future<ProductDetails> _getPremiumProductDetails() async {
    bool isClientAvailable = await _client.isAvailable();
    if (!isClientAvailable) {
      throw Exception("Unable to connect to store");
    }

    ProductDetailsResponse response =
        await _client.queryProductDetails({_premiumId});
    if (response.error != null) {
      throw Exception(response.error.toString);
    }
    if (response.notFoundIDs.isNotEmpty) {
      throw Exception(
          "Unable to retrieve product(s) from store: ${response.notFoundIDs.map((id) => "\"$id\"").join(", ")}");
    }

    return response.productDetails.firstWhere(
        (prdocutDetails) => prdocutDetails.title == "Premium",
        orElse: () => throw Exception(
            "Unable to retrieve product \"$_premiumName\" from store"));
  }
}
