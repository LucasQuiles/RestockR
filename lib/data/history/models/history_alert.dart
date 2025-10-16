/// Represents a detailed restock alert from history
class HistoryAlert {
  final String id;
  final String store;
  final String sku;
  final String product;
  final double? price;
  final String? url;
  final String? image;
  final DateTime timestamp;
  final int yesReactions;
  final int noReactions;

  const HistoryAlert({
    required this.id,
    required this.store,
    required this.sku,
    required this.product,
    this.price,
    this.url,
    this.image,
    required this.timestamp,
    this.yesReactions = 0,
    this.noReactions = 0,
  });

  factory HistoryAlert.fromJson(Map<String, dynamic> json) {
    // Parse price - backend may return empty string or string number
    double? price;
    final priceValue = json['price'];
    if (priceValue != null && priceValue != '') {
      if (priceValue is num) {
        price = priceValue.toDouble();
      } else if (priceValue is String) {
        price = double.tryParse(priceValue);
      }
    }

    return HistoryAlert(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      store: json['store'] ?? '',
      sku: json['sku'] ?? '',
      product: json['product'] ?? 'Unknown Product',
      price: price,
      url: json['url'],
      image: json['image'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      yesReactions: json['reactions']?['yes'] ?? 0,
      noReactions: json['reactions']?['no'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store': store,
      'sku': sku,
      'product': product,
      if (price != null) 'price': price,
      if (url != null) 'url': url,
      if (image != null) 'image': image,
      'timestamp': timestamp.toIso8601String(),
      'reactions': {
        'yes': yesReactions,
        'no': noReactions,
      },
    };
  }
}
