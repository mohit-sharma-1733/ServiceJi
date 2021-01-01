import 'package:ServiceJi/models/OrderModel.dart';

import 'CustomerResponse.dart';

class CreateOrderRequestModel {
  var lineItems = List<LineItemsRequest>();
  Shipping shipping;
  Billing billing;
  int customer_id;
  var payment_method;
  var status;
  var set_paid;
  var transaction_id;
  List<ShippingLines> shippingLines;

  CreateOrderRequestModel({this.set_paid, this.status, this.lineItems, this.shipping, this.billing, this.customer_id, this.payment_method, this.transaction_id, this.shippingLines});

  CreateOrderRequestModel.fromJson(Map<String, dynamic> json) {
    set_paid = json['set_paid'];
    status = json['status'];
    if (json['line_items'] != null) {
      lineItems = new List<LineItemsRequest>();
      json['line_items'].forEach((v) {
        lineItems.add(new LineItemsRequest.fromJson(v));
      });
    }

    shipping = json['shipping'] != null ? new Shipping.fromJson(json['shipping']) : null;
    billing = json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
    payment_method = json['payment_method'];
    transaction_id = json['transaction_id'];
    customer_id = json['customer_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['set_paid'] = this.set_paid;
    data['status'] = this.status;
    if (this.lineItems != null) {
      data['line_items'] = this.lineItems.map((v) => v.toJson()).toList();
    }
    if (this.shippingLines != null) {
      data['shipping_lines'] = this.shippingLines.map((v) => v.toJson()).toList();
    }
    data['shipping'] = this.shipping;
    data['billing'] = this.billing;
    data['payment_method'] = this.payment_method;
    data['transaction_id'] = this.transaction_id;
    data['customer_id'] = this.customer_id;
    return data;
  }
}

class LineItemsRequest {
  int product_id;
  String quantity;
  int variation_id;

  LineItemsRequest({this.product_id, this.quantity, this.variation_id});

  factory LineItemsRequest.fromJson(Map<String, dynamic> json) {
    return LineItemsRequest(product_id: json['product_id'], quantity: json['quantity'], variation_id: json['variation_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.product_id;
    data['quantity'] = this.quantity;
    data['variation_id'] = this.variation_id;
    return data;
  }
}
