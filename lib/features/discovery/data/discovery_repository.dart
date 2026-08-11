import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/models.dart';

class DiscoveryRepository {
  const DiscoveryRepository(this._api);
  final ApiClient _api;
  Future<List<Restaurant>> list({
    int page = 1,
    String? area,
    double? latitude,
    double? longitude,
  }) async {
    final data = await _api.get(
      '/api/v1/restaurants',
      query: {
        'page': page,
        'limit': 20,
        'area': ?area,
        'latitude': ?latitude,
        'longitude': ?longitude,
      },
    );
    return unwrapItems(data)
        .map(
          (item) =>
              Restaurant.fromJson(Map<String, Object?>.from(item! as Map)),
        )
        .toList();
  }

  Future<List<Restaurant>> search(String query, {String? area}) async {
    final data = await _api.get(
      '/api/v1/restaurants/search',
      query: {'q': query, 'page': 1, 'limit': 20, 'area': ?area},
    );
    return unwrapItems(data)
        .map(
          (item) =>
              Restaurant.fromJson(Map<String, Object?>.from(item! as Map)),
        )
        .toList();
  }

  Future<Restaurant> detail(String id) async =>
      Restaurant.fromJson(await _api.get('/api/v1/restaurants/$id'));
  Future<List<Map<String, Object?>>> branches(String id) async => unwrapItems(
    await _api.get('/api/v1/restaurants/$id/branches'),
  ).map((item) => Map<String, Object?>.from(item! as Map)).toList();
}

final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
  (ref) => DiscoveryRepository(ref.watch(apiClientProvider)),
);
final restaurantsProvider = FutureProvider<List<Restaurant>>(
  (ref) => ref.watch(discoveryRepositoryProvider).list(),
);
