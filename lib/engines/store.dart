import 'dart:async';

import 'package:collection/collection.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

typedef PurchaseListener = void Function(String productId, bool succeeded);

class Store {
  static final Store _store = Store._internal();

  factory Store() {
    return _store;
  }

  Store._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  // bool _isAvailable = false;
  // bool _purchasePending = false;
  // bool _loading = true;
  // String? _queryProductError;
  PurchaseListener? _purchaseListener;

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // TODO: showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // TODO: handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // TODO: validate purchase
          _purchases.add(purchaseDetails);
          // _purchasePending = false;
          if (_purchaseListener != null) {
            _purchaseListener!(purchaseDetails.productID, true);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<void> init(List<String> productIds, PurchaseListener? onDone) async {
    _purchaseListener = onDone;

    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });

    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      // _isAvailable = isAvailable;
      _products = [];
      _purchases = [];
      // _notFoundIds = [];
      // _purchasePending = false;
      // _loading = false;
      return;
    }

    var productDetailResponse = await _inAppPurchase.queryProductDetails(productIds.toSet());
    if (productDetailResponse.error != null) {
      // _queryProductError = productDetailResponse.error!.message;
      // _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = [];
      // _notFoundIds = productDetailResponse.notFoundIDs;
      // _purchasePending = false;
      // _loading = false;
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      // _queryProductError = null;
      // _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = [];
      // _notFoundIds = productDetailResponse.notFoundIDs;
      // _purchasePending = false;
      // _loading = false;
      return;
    }

    // _isAvailable = isAvailable;
    _products = productDetailResponse.productDetails;
    // _notFoundIds = productDetailResponse.notFoundIDs;
    // _purchasePending = false;
    // _loading = false;
  }

  Future<void> restorePurchases() {
    return _inAppPurchase.restorePurchases();
  }

  Future<bool> buyNonConsumable(String productId) async {
    var productDetails = _products.firstWhereOrNull((ProductDetails p) => p.id == productId);
    if (productDetails != null) {
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      return _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
    return false;
  }

  void dispose() {
    _subscription.cancel();
  }
}
