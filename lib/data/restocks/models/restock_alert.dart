import 'package:equatable/equatable.dart';

/// Data model for a restock alert from the backend.
/// Maps to the Restock model in API/models/Restock.js
class RestockAlert extends Equatable {
  final String id;
  final String store;
  final String sku;
  final String product;
  final String? price;
  final String url;
  final String? originalUrl;
  final String? image;
  final DateTime timestamp;
  final String source;
  final RestockReactions reactions;
  final List<String> reactedUsers;

  const RestockAlert({
    required this.id,
    required this.store,
    required this.sku,
    required this.product,
    this.price,
    required this.url,
    this.originalUrl,
    this.image,
    required this.timestamp,
    required this.source,
    required this.reactions,
    required this.reactedUsers,
  });

  factory RestockAlert.fromJson(Map<String, dynamic> json) {
    return RestockAlert(
      id: json['id'] ?? json['_id'] ?? '',
      store: json['store'] ?? '',
      sku: json['sku'] ?? '',
      product: json['product'] ?? 'Unknown Product',
      price: json['price']?.toString(),
      url: json['url'] ?? '',
      originalUrl: json['originalUrl'],
      image: json['image'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      source: json['source'] ?? 'manual',
      reactions: RestockReactions.fromJson(json['reactions'] ?? {}),
      reactedUsers: (json['reactedUsers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store': store,
      'sku': sku,
      'product': product,
      'price': price,
      'url': url,
      'originalUrl': originalUrl,
      'image': image,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'reactions': reactions.toJson(),
      'reactedUsers': reactedUsers,
    };
  }

  RestockAlert copyWith({
    String? id,
    String? store,
    String? sku,
    String? product,
    String? price,
    String? url,
    String? originalUrl,
    String? image,
    DateTime? timestamp,
    String? source,
    RestockReactions? reactions,
    List<String>? reactedUsers,
  }) {
    return RestockAlert(
      id: id ?? this.id,
      store: store ?? this.store,
      sku: sku ?? this.sku,
      product: product ?? this.product,
      price: price ?? this.price,
      url: url ?? this.url,
      originalUrl: originalUrl ?? this.originalUrl,
      image: image ?? this.image,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
      reactions: reactions ?? this.reactions,
      reactedUsers: reactedUsers ?? this.reactedUsers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        store,
        sku,
        product,
        price,
        url,
        originalUrl,
        image,
        timestamp,
        source,
        reactions,
        reactedUsers,
      ];
}

/// Reaction counts for a restock alert
class RestockReactions extends Equatable {
  final int yes;
  final int no;

  const RestockReactions({
    required this.yes,
    required this.no,
  });

  factory RestockReactions.fromJson(Map<String, dynamic> json) {
    return RestockReactions(
      yes: json['yes'] ?? 0,
      no: json['no'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'yes': yes,
      'no': no,
    };
  }

  RestockReactions copyWith({int? yes, int? no}) {
    return RestockReactions(
      yes: yes ?? this.yes,
      no: no ?? this.no,
    );
  }

  @override
  List<Object?> get props => [yes, no];
}
