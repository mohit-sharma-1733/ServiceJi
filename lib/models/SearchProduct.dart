class SearchProduct {
    int id;
    var name;
    var slug;
    var status;
    bool featured;
    var catalog_visibility;
    var description;
    var short_description;
    var sku;
    var price;
    var regular_price;
    var sale_price;
    int total_sales;
    var tax_status;
    var tax_class;
    bool manage_stock;
    var stock_quantity;
    var stock_status;
    var backorders;
    var low_stock_amount;
    bool sold_individually;
    var weight;
    var length;
    var width;
    var height;
    List<int> upsell_ids;
    List<int> cross_sell_ids;
    int parent_id;
    bool reviews_allowed;
    var purchase_note;
    int menu_order;
    var post_password;
    bool virtual;
    bool downloadable;
    List<int> category_ids;
    int shipping_class_id;
    var image_id;
    List<int> gallery_image_ids;
    int download_limit;
    int download_expiry;
    var average_rating;
    int review_count;
    Images images;

    SearchProduct({this.id, this.name, this.slug, this.status, this.featured, this.catalog_visibility, this.description
      , this.short_description, this.sku, this.price, this.regular_price, this.sale_price,  this.total_sales
      , this.tax_status, this.tax_class, this.manage_stock, this.stock_quantity, this.stock_status, this.backorders
      , this.low_stock_amount, this.sold_individually, this.weight, this.length, this.width, this.height,
      this.upsell_ids, this.cross_sell_ids, this.parent_id, this.reviews_allowed, this.purchase_note,
      this.menu_order, this.post_password, this.virtual, this.downloadable, this.category_ids,
      this.shipping_class_id,  this.image_id, this.gallery_image_ids, this.download_limit,
      this.download_expiry,  this.average_rating, this.review_count, this.images});

    factory SearchProduct.fromJson(Map<String, dynamic> json) {
        return SearchProduct(
            id: json['id'], 
            name: json['name'], 
            slug: json['slug'], 
            status: json['status'],
            featured: json['featured'], 
            catalog_visibility: json['catalog_visibility'], 
            description: json['description'], 
            short_description: json['short_description'], 
            sku: json['sku'], 
            price: json['price'], 
            regular_price: json['regular_price'], 
            sale_price: json['sale_price'], 
            total_sales: json['total_sales'],
            tax_status: json['tax_status'], 
            tax_class: json['tax_class'], 
            manage_stock: json['manage_stock'], 
            stock_status: json['stock_status'],
            backorders: json['backorders'], 
            low_stock_amount: json['low_stock_amount'], 
            sold_individually: json['sold_individually'], 
            weight: json['weight'], 
            length: json['length'], 
            width: json['width'], 
            height: json['height'], 
            upsell_ids: json['upsell_ids'] != null ? new List<int>.from(json['upsell_ids']) : null, 
            cross_sell_ids: json['cross_sell_ids'] != null ? new List<int>.from(json['cross_sell_ids']) : null, 
            parent_id: json['parent_id'], 
            reviews_allowed: json['reviews_allowed'], 
            purchase_note: json['purchase_note'], 
            menu_order: json['menu_order'],
            post_password: json['post_password'], 
            virtual: json['virtual'], 
            downloadable: json['downloadable'], 
            category_ids: json['category_ids'] != null ? new List<int>.from(json['category_ids']) : null, 
            image_id: json['image_id'],
            gallery_image_ids: json['gallery_image_ids'] != null ? new List<int>.from(json['gallery_image_ids']) : null, 
            download_limit: json['download_limit'], 
            download_expiry: json['download_expiry'], 
            average_rating: json['average_rating'],
            review_count: json['review_count'], 
            images: json['images'] != null ? Images.fromJson(json['images']) : null,
        );
    }

}

class Images {
    List<String> image;
    List<String> gallery;

    Images({this.image, this.gallery});

    factory Images.fromJson(Map<String, dynamic> json) {
        return Images(
            image: json['image'] != null ? new List<String>.from(json['image']) : null, 
            gallery: json['gallery'] != null ? new List<String>.from(json['gallery']) : null, 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        if (this.image != null) {
            data['image'] = this.image;
        }
        if (this.gallery != null) {
            data['gallery'] = this.gallery;
        }
        return data;
    }
}
