class PaymentGatewayModel {
  String id;
  String method_description;
  String method_title;

  PaymentGatewayModel({this.id, this.method_description, this.method_title});

  factory PaymentGatewayModel.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayModel(
      id: json['id'],
      method_description: json['method_description'],
      method_title: json['method_title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['method_description'] = this.method_description;
    data['method_title'] = this.method_title;
    return data;
  }
}
