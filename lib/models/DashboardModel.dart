
import 'ProductResponse.dart';

class DashboardModel {
  int total_order;
  String themeColor;
  String app_lang;
  String payment_method;
  bool enable_coupons;
  CurrencySymbol currencySymbol;
  List<ProductResponse> dealProduct;
  List<ProductResponse> suggestedProduct;
  List<ProductResponse> offer;
  List<ProductResponse> youMayLike;
  List<ProductResponse> featured;
  List<ProductResponse> newest;
  List<VendorResponse> vendor;

  DashboardModel(
      {this.themeColor,
        this.total_order,
        this.currencySymbol,
        this.app_lang,
        this.enable_coupons,
        this.payment_method,
        this.dealProduct,
        this.suggestedProduct,
        this.offer,
        this.featured,
        this.newest,
        this.youMayLike});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    themeColor = json['theme_color'];
    app_lang = json['app_lang'];
    payment_method = json['payment_method'];
    enable_coupons = json['enable_coupons'];
    total_order = json['total_order'];
    currencySymbol = json['currency_symbol'] != null
        ? new CurrencySymbol.fromJson(json['currency_symbol'])
        : null;
    if (json['deal_product'] != null) {
      dealProduct = new List<ProductResponse>();
      json['deal_product'].forEach((v) {
        dealProduct.add(new ProductResponse.fromJson(v));
      });
    }
    if (json['suggested_product'] != null) {
      suggestedProduct = new List<ProductResponse>();
      json['suggested_product'].forEach((v) {
        suggestedProduct.add(new ProductResponse.fromJson(v));
      });
    }
    if (json['offer'] != null) {
      offer = new List<ProductResponse>();
      json['offer'].forEach((v) {
        offer.add(new ProductResponse.fromJson(v));
      });
    }
    if (json['you_may_like'] != null) {
      youMayLike = new List<ProductResponse>();
      json['you_may_like'].forEach((v) {
        youMayLike.add(ProductResponse.fromJson(v));
      });
    }
    if (json['newest'] != null) {
      newest = new List<ProductResponse>();
      json['newest'].forEach((v) {
        newest.add(ProductResponse.fromJson(v));
      });
    }
    if (json['featured'] != null) {
      featured = new List<ProductResponse>();
      json['featured'].forEach((v) {
        featured.add(ProductResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_order'] = this.total_order;
    data['theme_color'] = this.themeColor;
    data['app_lang'] = this.app_lang;
    data['payment_method'] = this.payment_method;
    data['enable_coupons'] = this.enable_coupons;
    if (this.currencySymbol != null) {
      data['currency_symbol'] = this.currencySymbol.toJson();
    }
    if (this.dealProduct != null) {
      data['deal_product'] = this.dealProduct.map((v) => v.toJson()).toList();
    }
    if (this.suggestedProduct != null) {
      data['suggested_product'] =
          this.suggestedProduct.map((v) => v.toJson()).toList();
    }
    if (this.offer != null) {
      data['offer'] = this.offer.map((v) => v.toJson()).toList();
    }
    if (this.youMayLike != null) {
      data['you_may_like'] = this.youMayLike.map((v) => v.toJson()).toList();
    }
    if (this.newest != null) {
      data['newest'] = this.newest.map((v) => v.toJson()).toList();
    }
    if (this.featured != null) {
      data['featured'] = this.featured.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CurrencySymbol {
  String currencySymbol;
  String currency;

  CurrencySymbol({this.currencySymbol, this.currency});

  CurrencySymbol.fromJson(Map<String, dynamic> json) {
    currencySymbol = json['currency_symbol'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency_symbol'] = this.currencySymbol;
    data['currency'] = this.currency;
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
