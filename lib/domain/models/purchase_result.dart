enum PurchaseResultStatus {
  alreadyPurchased,
  purchaseCancelled,
  purchaseFailed,
  purchaseSucceeded,
  restoreFailed,
  restoreSucceeded;

  @override
  String toString() {
    switch (this) {
      case PurchaseResultStatus.alreadyPurchased:
        return "Already Purchased";
      case PurchaseResultStatus.purchaseCancelled:
        return "Purchase Cancelled";
      case PurchaseResultStatus.purchaseFailed:
        return "Purchase Failed";
      case PurchaseResultStatus.purchaseSucceeded:
        return "Purchase Succeeded";
      case PurchaseResultStatus.restoreFailed:
        return "Restore Failed";
      case PurchaseResultStatus.restoreSucceeded:
        return "Restore Succeeded";
    }
  }
}

class PurchaseResult {
  final PurchaseResultStatus status;
  final String message;

  PurchaseResult(this.status, this.message);
}
