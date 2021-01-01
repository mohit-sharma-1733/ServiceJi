class Line_items {
  int proId;
  String quantity;

  Line_items({this.proId, this.quantity});

  Line_items.fromJson(Map<String, dynamic> json) {
    proId = json['product_id'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.proId;
    data['quantity'] = this.quantity;
    return data;
  }
}
