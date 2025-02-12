import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class Store {
  static final String _appleApiKey = "appl_MEccyvrrXhtPGGwyIcFrXUDPwrq";
  static final String _offeringId = "default";
  static final String _packageId = "com.lvnlx.tempus.premium";
  static final String _entitlementId = "premium";

  static Future<void> initPurchases() async {
    if (!kReleaseMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    if (Platform.isIOS) {
      PurchasesConfiguration configuration;
      configuration = PurchasesConfiguration(_appleApiKey);
      await Purchases.configure(configuration);
    } else {
      throw Exception("Store is only configured for iOS");
    }
  }

  static Future<void> purchasePremium() async {
    Offerings offerings = await Purchases.getOfferings();
    Offering offering = offerings.current!;
    Package package = offering.availablePackages.first;

    try {
      await Purchases.purchasePackage(package);
    } on PlatformException catch (error) {
      switch (PurchasesErrorHelper.getErrorCode(error)) {
        case PurchasesErrorCode.purchaseCancelledError:
          print("Purchase cancelled");
        default:
          rethrow;
      }
    }
  }
}
