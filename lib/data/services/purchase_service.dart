import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/constants.dart';
import 'package:tempus/domain/models/purchase_result.dart';

class PurchaseService {
  final PreferenceService _preferenceService;

  late final ValueNotifier<bool> _isPremiumValueNotifier;

  static final String _appleApiKey = "appl_MEccyvrrXhtPGGwyIcFrXUDPwrq";
  static final String _entitlementId = "premium";

  PurchaseService(this._preferenceService);

  Future<void> init() async {
    _isPremiumValueNotifier =
        ValueNotifier(await _preferenceService.getIsPremium());

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

  bool get isPremium => _isPremiumValueNotifier.value;
  ValueNotifier<bool> get isPremiumValueNotifier => _isPremiumValueNotifier;

  Future<PurchaseResult> purchasePremium() async {
    if (isPremium) {
      return PurchaseResult(PurchaseResultStatus.alreadyPurchased,
          "You already have access to premium");
    }

    Offerings offerings = await Purchases.getOfferings();
    Offering offering = offerings.current!;
    Package package = offering.availablePackages.first;

    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      if (customerInfo.entitlements.active.containsKey(_entitlementId)) {
        _isPremiumValueNotifier.value = true;
        _preferenceService.setIsPremium(true);

        return PurchaseResult(PurchaseResultStatus.purchaseSucceeded,
            "You now have access to premium features");
      } else {
        return PurchaseResult(PurchaseResultStatus.purchaseFailed,
            "There was an error verifying your purchase. Please reach out to the app's support at ${Constants.supportEmail}");
      }
    } on PlatformException catch (error) {
      switch (PurchasesErrorHelper.getErrorCode(error)) {
        case PurchasesErrorCode.purchaseCancelledError:
          return PurchaseResult(PurchaseResultStatus.purchaseCancelled,
              "The purchase was cancelled");
        default:
          return PurchaseResult(PurchaseResultStatus.purchaseFailed,
              "There was an error completing your purchase. Please contact support if the issue persists");
      }
    } catch (_) {
      return PurchaseResult(PurchaseResultStatus.purchaseFailed,
          "There was an error completing your purchase. Please contact support if the issue persists");
    }
  }

  Future<PurchaseResult> restorePremium() async {
    if (isPremium) {
      return PurchaseResult(PurchaseResultStatus.alreadyPurchased,
          "You already have access to premium");
    }

    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      if (customerInfo.entitlements.active.containsKey("premium")) {
        _isPremiumValueNotifier.value = true;
        _preferenceService.setIsPremium(true);

        return PurchaseResult(
          PurchaseResultStatus.restoreSucceeded,
          "Your premium purchase was restored. You now have access to premium features",
        );
      } else {
        return PurchaseResult(
          PurchaseResultStatus.restoreFailed,
          "It looks like your account has not purchased premium. If you believe this is incorrect, please reach out to support at ${Constants.supportEmail}",
        );
      }
    } catch (_) {
      return PurchaseResult(
        PurchaseResultStatus.restoreFailed,
        "There was an error while restoring your purchase. Please contact support if the issue persists",
      );
    }
  }
}
