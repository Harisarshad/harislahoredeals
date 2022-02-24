class Product {
  int? id;
  String? name;
  String? user_id;
  String? socname;
  String? phasename;
  String? blockname;
  String? categories;
  List? categoriesID;
  String? description;
  String? imgUrl;
  double? price;
  double? discount;
  int? qty;
  int? stock_count;
  bool? in_stock;
  int? quantity;
  String? plot_no;
  String? size;
  double? avgRating;
  int? productItemID;
  List? variations;
  List? options;

  Product({this.options,this.variations,this.in_stock,this.avgRating,this.stock_count,this.id, this.name,this.user_id,this.socname,this.phasename,this.blockname,this.productItemID,this.discount, this.price, this.categories,this.categoriesID,this.description,this.qty,this.quantity,this.plot_no,this.size, this.imgUrl});
}

class OrderProduct {
  int? id;
  String? name;
  double? price;
  int? qty;
  String? imgUrl;
  int? stock_count;
  String? variation_id;
  bool? in_stock;
  List? options =[];


  OrderProduct({this.id, this.name,this.in_stock,this.stock_count, this.price, this.qty,this.imgUrl,this.options,this.variation_id});
}

class ItemProduct {
  String? shop_id;
  int? product_id;
  double? discounted_price;
  double? unit_price;
  int? quantity;
  String? shop_product_variation_id;
  List? options =[];

  ItemProduct({this.shop_id, this.product_id, this.unit_price, this.quantity, this.discounted_price,this.shop_product_variation_id,this.options});

  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["shop_id"] = shop_id;
    map["shop_product_variation_id"] = shop_product_variation_id;
    map["product_id"] = product_id;
    map["unit_price"] = unit_price;
    map["quantity"] = quantity;
    map["discounted_price"] = discounted_price;
    map["options"] = options;
    return map;
  }
}

class Options {
  String? id;
  String? name;
  String? price;
  Options({this.id,this.name, this.price});
  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    return map;
  }
}