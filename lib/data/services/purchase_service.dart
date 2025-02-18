import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/constants.dart';
import 'package:tempus/util.dart';

class PurchaseService extends ChangeNotifier {
  final PreferenceService _preferenceService;

  late bool _isPremium;

  static final String _appleApiKey = "appl_MEccyvrrXhtPGGwyIcFrXUDPwrq";
  static final String _entitlementId = "premium";

  PurchaseService(this._preferenceService);

  Future<void> init() async {
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

    _isPremium = await _preferenceService.getIsPremium();
  }

  bool get isPremium => _isPremium;

  Future<void> purchasePremium(BuildContext context) async {
    if (_isPremium) {
      await showDialog(DialogConfiguration(
          context, "Premium Access", "You already have access to premium"));

      return;
    }

    Offerings offerings = await Purchases.getOfferings();
    Offering offering = offerings.current!;
    Package package = offering.availablePackages.first;

    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      if (customerInfo.entitlements.active.containsKey(_entitlementId)) {
        _isPremium = true;
        _preferenceService.setIsPremium(true);

        notifyListeners();

        if (context.mounted) {
          await showDialog(DialogConfiguration(context, "Purchase Succeeded",
              "You now have access to premium features"));
        }
      } else {
        if (context.mounted) {
          await showDialog(DialogConfiguration(context, "Purchase Failed",
              "There was an error verifying your purchase. Please reach out to the app's support at ${Constants.supportEmail}"));
        }
      }
    } on PlatformException catch (error) {
      switch (PurchasesErrorHelper.getErrorCode(error)) {
        case PurchasesErrorCode.purchaseCancelledError:
          return;
        default:
          rethrow;
      }
    } catch (_) {
      if (context.mounted) {
        await showDialog(DialogConfiguration(context, "Purchase Failed",
            "There was an error completing your purchase. Please contact support if the issue persists"));
      }
    }
  }

  Future<void> restorePremium(BuildContext context) async {
    if (_isPremium) {
      await showDialog(DialogConfiguration(
          context, "Premium Access", "You already have access to premium"));

      return;
    }

    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      if (customerInfo.entitlements.active.containsKey("premium")) {
        _isPremium = true;
        _preferenceService.setIsPremium(true);

        notifyListeners();

        if (context.mounted) {
          await showDialog(DialogConfiguration(
            context,
            "Restore Succeeded",
            "Your premium purchase was restored. You now have access to premium features",
          ));
        }
      } else {
        if (context.mounted) {
          await showDialog(DialogConfiguration(
            context,
            "Restore Failed",
            "It looks like your account has not purchased premium. If you believe this is incorrect, please reach out to support at ${Constants.supportEmail}",
          ));
        }
      }
    } catch (_) {
      if (context.mounted) {
        await showDialog(DialogConfiguration(
          context,
          "Restore Failed",
          "There was an error while restoring your purchase. Please contact support if the issue persists",
        ));
      }
    }
  }
}
