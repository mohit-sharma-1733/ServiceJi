class ShippingMethodResponse {
  String message;
  List<Method> methods;

  ShippingMethodResponse({this.message, this.methods});

  factory ShippingMethodResponse.fromJson(Map<String, dynamic> json) {
    return ShippingMethodResponse(
      message: json['message'],
      methods: json['methods'] != null
          ? (json['methods'] as List).map((i) => Method.fromJson(i)).toList()
          : null,
    );
  }
}

class Method {
  String id;
  String min_amount;
  String requires;
  String method_title;
  String method_description;
  String enabled;
  String title;
  String tax_status;
  String cost;
  String type;
  int method_order;
  InstanceSettings instanceSettings;

  Method(
      {this.id,
      this.min_amount,
      this.requires,
      this.method_title,
      this.method_description,
      this.enabled,
      this.title,
      this.tax_status,
      this.cost,
      this.type,
      this.method_order,
      this.instanceSettings});

  factory Method.fromJson(Map<String, dynamic> json) {
    return Method(
        id: json['id'],
        min_amount: json['min_amount'],
        requires: json['requires'],
        method_title: json['method_title'],
        method_description: json['method_description'],
        enabled: json['enabled'],
        title: json['title'],
        tax_status: json['tax_status'],
        cost: json['cost'],
        type: json['type'],
        method_order: json['method_order'],
        instanceSettings: json['instance_settings'] != null
            ? InstanceSettings.fromJson(json['instance_settings'])
            : null);
  }
}

class InstanceSettings {
  String title;
  String requires;
  String min_amount;
  String ignore_discounts;

  InstanceSettings(
      {this.title, this.requires, this.min_amount, this.ignore_discounts});

  factory InstanceSettings.fromJson(Map<String, dynamic> json) {
    return InstanceSettings(
      title: json['title'],
      requires: json['requires'],
      min_amount: json['min_amount'],
      ignore_discounts: json['ignore_discounts'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['requires'] = this.requires;
    data['min_amount'] = this.min_amount;
    data['ignore_discounts'] = this.ignore_discounts;
    return data;
  }
}
