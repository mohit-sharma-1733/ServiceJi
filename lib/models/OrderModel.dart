import 'CustomerResponse.dart';

class OrderResponse {
  int id;
  int parentId;
  String status;
  String currency;
  String version;
  bool pricesIncludeTax;
  DateCreated dateCreated;
  DateCreated dateModified;
  String discountTotal;
  String discountTax;
  String shippingTotal;
  String shippingTax;
  String cartTax;
  String total;
  String totalTax;
  int customerId;
  String orderKey;
  Billing billing;
  Shipping shipping;
  String paymentMethod;
  String paymentMethodTitle;
  String transactionId;
  String customerIpAddress;
  String customerUserAgent;
  String createdVia;
  String customerNote;
  var dateCompleted;
  var datePaid;
  String cartHash;
  String number;
  //List<Null> metaData;
  List<LineItems> lineItems;
  // List<Null> taxLines;
  //List<Null> shippingLines;
  //List<Null> feeLines;
  //List<Null> couponLines;

  OrderResponse({
    this.id,
    this.parentId,
    this.status,
    this.currency,
    this.version,
    this.pricesIncludeTax,
    this.dateCreated,
    this.dateModified,
    this.discountTotal,
    this.discountTax,
    this.shippingTotal,
    this.shippingTax,
    this.cartTax,
    this.total,
    this.totalTax,
    this.customerId,
    this.orderKey,
    this.billing,
    this.shipping,
    this.paymentMethod,
    this.paymentMethodTitle,
    this.transactionId,
    this.customerIpAddress,
    this.customerUserAgent,
    this.createdVia,
    this.customerNote,
    this.dateCompleted,
    this.datePaid,
    this.cartHash,
    this.number,
    // this.metaData,
    this.lineItems,
    //this.taxLines,
    //this.shippingLines,
    //this.feeLines,
    //this.couponLines
  });

  OrderResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    status = json['status'];
    currency = json['currency'];
    version = json['version'];
    pricesIncludeTax = json['prices_include_tax'];
    dateCreated = json['date_created'] != null ? new DateCreated.fromJson(json['date_created']) : null;
    dateModified = json['date_modified'] != null ? new DateCreated.fromJson(json['date_modified']) : null;
    discountTotal = json['discount_total'];
    discountTax = json['discount_tax'];
    shippingTotal = json['shipping_total'];
    shippingTax = json['shipping_tax'];
    cartTax = json['cart_tax'];
    total = json['total'];
    totalTax = json['total_tax'];
    customerId = json['customer_id'];
    orderKey = json['order_key'];
    billing = json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
    shipping = json['shipping'] != null ? new Shipping.fromJson(json['shipping']) : null;
    paymentMethod = json['payment_method'];
    paymentMethodTitle = json['payment_method_title'];
    transactionId = json['transaction_id'];
    customerIpAddress = json['customer_ip_address'];
    customerUserAgent = json['customer_user_agent'];
    createdVia = json['created_via'];
    customerNote = json['customer_note'];
    dateCompleted = json['date_completed'];
    datePaid = json['date_paid'];
    cartHash = json['cart_hash'];
    number = json['number'];
//    if (json['meta_data'] != null) {
//      metaData = new List<Null>();
//      json['meta_data'].forEach((v) {
//        metaData.add(new Null.fromJson(v));
//      });
//    }
    if (json['line_items'] != null) {
      lineItems = new List<LineItems>();
      json['line_items'].forEach((v) {
        lineItems.add(new LineItems.fromJson(v));
      });
    }
//    if (json['tax_lines'] != null) {
//      taxLines = new List<Null>();
//      json['tax_lines'].forEach((v) {
//        taxLines.add(new Null.fromJson(v));
//      });
//    }
//    if (json['shipping_lines'] != null) {
//      shippingLines = new List<Null>();
//      json['shipping_lines'].forEach((v) {
//        shippingLines.add(new Null.fromJson(v));
//      });
//    }
//    if (json['fee_lines'] != null) {
//      feeLines = new List<Null>();
//      json['fee_lines'].forEach((v) {
//        feeLines.add(new Null.fromJson(v));
//      });
//    }
//    if (json['coupon_lines'] != null) {
//      couponLines = new List<Null>();
//      json['coupon_lines'].forEach((v) {
//        couponLines.add(new Null.fromJson(v));
//      });
//    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent_id'] = this.parentId;
    data['status'] = this.status;
    data['currency'] = this.currency;
    data['version'] = this.version;
    data['prices_include_tax'] = this.pricesIncludeTax;
    if (this.dateCreated != null) {
      data['date_created'] = this.dateCreated.toJson();
    }
    if (this.dateModified != null) {
      data['date_modified'] = this.dateModified.toJson();
    }
    data['discount_total'] = this.discountTotal;
    data['discount_tax'] = this.discountTax;
    data['shipping_total'] = this.shippingTotal;
    data['shipping_tax'] = this.shippingTax;
    data['cart_tax'] = this.cartTax;
    data['total'] = this.total;
    data['total_tax'] = this.totalTax;
    data['customer_id'] = this.customerId;
    data['order_key'] = this.orderKey;
    if (this.billing != null) {
      data['billing'] = this.billing.toJson();
    }
    if (this.shipping != null) {
      data['shipping'] = this.shipping.toJson();
    }
    data['payment_method'] = this.paymentMethod;
    data['payment_method_title'] = this.paymentMethodTitle;
    data['transaction_id'] = this.transactionId;
    data['customer_ip_address'] = this.customerIpAddress;
    data['customer_user_agent'] = this.customerUserAgent;
    data['created_via'] = this.createdVia;
    data['customer_note'] = this.customerNote;
    data['date_completed'] = this.dateCompleted;
    data['date_paid'] = this.datePaid;
    data['cart_hash'] = this.cartHash;
    data['number'] = this.number;
//    if (this.metaData != null) {
//      data['meta_data'] = this.metaData.map((v) => v.toJson()).toList();
//    }
    if (this.lineItems != null) {
      data['line_items'] = this.lineItems.map((v) => v.toJson()).toList();
    }
//    if (this.taxLines != null) {
//      data['tax_lines'] = this.taxLines.map((v) => v.toJson()).toList();
//    }
//    if (this.shippingLines != null) {
//      data['shipping_lines'] =
//          this.shippingLines.map((v) => v.toJson()).toList();
//    }
//    if (this.feeLines != null) {
//      data['fee_lines'] = this.feeLines.map((v) => v.toJson()).toList();
//    }
//    if (this.couponLines != null) {
//      data['coupon_lines'] = this.couponLines.map((v) => v.toJson()).toList();
//    }
    return data;
  }
}

class DateCreated {
  String date;
  int timezoneType;
  String timezone;

  DateCreated({this.date, this.timezoneType, this.timezone});

  DateCreated.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    timezoneType = json['timezone_type'];
    timezone = json['timezone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['timezone_type'] = this.timezoneType;
    data['timezone'] = this.timezone;
    return data;
  }
}

class LineItems {
  int id;
  int orderId;
  String name;
  int productId;
  int variationId;
  int quantity;
  String taxClass;
  String subtotal;
  String subtotalTax;
  String total;
  String totalTax;
  //Taxes taxes;
  //List<Null> metaData;
  List<ProductImages> productImages;

  LineItems(
      {this.id,
      this.orderId,
      this.name,
      this.productId,
      this.variationId,
      this.quantity,
      this.taxClass,
      this.subtotal,
      this.subtotalTax,
      this.total,
      this.totalTax,
      //this.taxes,
      //  this.metaData,
      this.productImages});

  LineItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    name = json['name'];
    productId = json['product_id'];
    variationId = json['variation_id'];
    quantity = json['quantity'];
    taxClass = json['tax_class'];
    subtotal = json['subtotal'];
    subtotalTax = json['subtotal_tax'];
    total = json['total'];
    totalTax = json['total_tax'];
    //taxes = json['taxes'] != null ? new Taxes.fromJson(json['taxes']) : null;
//    if (json['meta_data'] != null) {
//      metaData = new List<Null>();
//      json['meta_data'].forEach((v) {
//        metaData.add(new Null.fromJson(v));
//      });
//    }
    if (json['product_images'] != null) {
      productImages = new List<ProductImages>();
      json['product_images'].forEach((v) {
        productImages.add(new ProductImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['name'] = this.name;
    data['product_id'] = this.productId;
    data['variation_id'] = this.variationId;
    data['quantity'] = this.quantity;
    data['tax_class'] = this.taxClass;
    data['subtotal'] = this.subtotal;
    data['subtotal_tax'] = this.subtotalTax;
    data['total'] = this.total;
    data['total_tax'] = this.totalTax;
    // if (this.taxes != null) {
    //   data['taxes'] = this.taxes.toJson();
    // }
//    if (this.metaData != null) {
//      data['meta_data'] = this.metaData.map((v) => v.toJson()).toList();
//    }
    if (this.productImages != null) {
      data['product_images'] = this.productImages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductImages {
  int id;
  String dateCreated;
  String dateModified;
  String src;
  String name;
  String alt;
  int position;

  ProductImages({this.id, this.dateCreated, this.dateModified, this.src, this.name, this.alt, this.position});

  ProductImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateCreated = json['date_created'];
    dateModified = json['date_modified'];
    src = json['src'];
    name = json['name'];
    alt = json['alt'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date_created'] = this.dateCreated;
    data['date_modified'] = this.dateModified;
    data['src'] = this.src;
    data['name'] = this.name;
    data['alt'] = this.alt;
    data['position'] = this.position;
    return data;
  }
}

class ShippingLines {
  String method_id;
  String method_title;
  String total;

  ShippingLines({this.method_id, this.method_title, this.total});

  factory ShippingLines.fromJson(Map<String, dynamic> json) {
    return ShippingLines(
      method_id: json['method_id'],
      method_title: json['method_title'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['method_id'] = this.method_id;
    data['method_title'] = this.method_title;
    data['total'] = this.total ?? "";
    return data;
  }
}
