import 'NetworkUtils.dart';
import 'woo_commerce_api.dart';

Future createCustomer(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/woocommerce/customer/register', request));
}

Future updateCustomer(id, request) async {
  return handleResponse(await WooCommerceAPI().postAsync('wc/v3/customers/$id', request));
}

Future login(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('jwt-auth/v1/token', request));
}

Future forgetPassword(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/customer/forget-password', request));
}

Future getCustomer(id) async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/customers/$id'));
}

Future getCategories(page,total) async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/products/categories?parent=0&page=$page&per_page=$total'));
}

Future getSubCategories(parent, page) async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/products/categories?&page=$page&parent=$parent'));
}

Future getAllCategories(category, page,total) async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/products?category=$category&page=$page&per_page=$total'));
}

Future getProducts(page) async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/products?page=$page'));
}

Future getFeaturedProducts(featured, page) async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/products?featured=$featured&page=$page'));
}

Future getOnSaleProducts(onSale, page) async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/products?on_sale=$onSale&page=$page'));
}

Future getWishList() async {
  return handleResponse(
    await WooCommerceAPI().getAsync('iqonic-api/api/v1/wishlist/get-wishlist/', requireToken: true),
  );
}

Future saveProfileImage(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/customer/save-profile-image', request, requireToken: true));
}

Future getProductDetail(int productId) async {
  return handleResponse(
    await WooCommerceAPI().getAsync('iqonic-api/api/v1/woocommerce/get-product-details?product_id=$productId', requireToken: true),
  );
}

Future changePassword(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/woocommerce/change-password', request, requireToken: true));
}

Future getDashboardApi() async {
 return handleResponse(await WooCommerceAPI().getAsync('iqonic-api/api/v1/woocommerce/get-dashboard'));
}

Future addWishList(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/wishlist/add-wishlist/', request, requireToken: true));
}

Future removeWishList(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/wishlist/delete-wishlist/', request, requireToken: true));
}

Future addToCart(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/cart/add-cart/', request, requireToken: true));
}

Future removeCartItem(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/cart/delete-cart/', request, requireToken: true));
}

Future getCartList() async {
  return handleResponse(await WooCommerceAPI().getAsync('iqonic-api/api/v1/cart/get-cart/', requireToken: true));
}

Future updateCartItem(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/cart/update-cart/', request, requireToken: true));
}

Future getCouponList() async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/Coupons'));
}

Future getProductReviews(id) async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v1/products/$id/reviews'));
}

Future postReview(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('wc/v3/products/reviews', request));
}

Future updateReview(id1, request) async {
  return handleResponse(await WooCommerceAPI().postAsync('wc/v3/products/reviews/$id1', request));
}

Future createOrderApi(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('wc/v3/orders', request, requireToken: true));
}

Future deleteReview(id1) async {
  return handleResponse(await WooCommerceAPI().deleteAsync('wc/v3/products/reviews/$id1'));
}

Future searchProduct(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/woocommerce/get-product', request));
}

Future getProductAttribute() async {
  return handleResponse(await WooCommerceAPI().getAsync('iqonic-api/api/v1/woocommerce/get-product-attributes', isFood: true));
}

Future getOrders() async {
  return handleResponse(await WooCommerceAPI().getAsync('iqonic-api/api/v1/woocommerce/get-customer-orders', requireToken: true));
}

Future getOrdersTracking(orderId) async {
  return handleResponse(await WooCommerceAPI().getAsync(
    'wc/v3/orders/$orderId/notes',
  ));
}

Future CreateOrderNotes(orderId, request) async {
  return handleResponse(await WooCommerceAPI().postAsync('wc/v3/orders/$orderId/notes', request));
}

Future cancelOrder(orderId, request) async {
  return handleResponse(await WooCommerceAPI().postAsync('wc/v3/orders/$orderId', request));
}

Future getCheckOutUrl(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/woocommerce/get-checkout-url', request, requireToken: true));
}

Future getActivePaymentGatewaysApi() async {
  return handleResponse(await WooCommerceAPI().getAsync('iqonic-api/api/v1/payment/get-active-payment-gateway'));
}

Future clearCartItems() async {
  return handleResponse(await WooCommerceAPI().getAsync('iqonic-api/api/v1/cart/clear-cart/', requireToken: true));
}

Future getCountries() async {
  return handleResponse(await WooCommerceAPI().getAsync('wc/v3/data/countries', requireToken: true));
}

Future getShippingMethod(request) async {
  return handleResponse(await WooCommerceAPI().postAsync('iqonic-api/api/v1/woocommerce/get-shipping-methods', request, requireToken: true));
}

Future deleteOrder(id1) async {
  return handleResponse(await WooCommerceAPI().deleteAsync('wc/v3/orders/$id1'));
}

Future getVendor() async {
  return handleResponse(await WooCommerceAPI().getAsync('iqonic-api/api/v1/woocommerce/get-vendors',));
}

Future getVendorProfile(id) async {
  return handleResponse(await WooCommerceAPI().getAsync('dokan/v1/stores/$id',));
}

Future getVendorProduct(id) async {
  return handleResponse(await WooCommerceAPI().getAsync('iqonic-api/api/v1/woocommerce/get-vendor-products?vendor_id=$id',));
}