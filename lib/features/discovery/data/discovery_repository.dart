import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/fixtures/fixture_store.dart';
import '../../../core/models/models.dart';

abstract interface class DiscoveryRepository {
  Future<List<Restaurant>> list({
    int page = 1,
    String? area,
    double? latitude,
    double? longitude,
  });
  Future<List<Restaurant>> search(String query, {String? area});
  Future<Restaurant> detail(String id);
  Future<List<Map<String, Object?>>> branches(String id);
}

class ApiDiscoveryRepository implements DiscoveryRepository {
  const ApiDiscoveryRepository(this._api);
  final ApiClient _api;
  @override
  Future<List<Restaurant>> list({
    int page = 1,
    String? area,
    double? latitude,
    double? longitude,
  }) async =>
      unwrapItems(
            await _api.get(
              '/api/v1/restaurants',
              query: {
                'page': page,
                'limit': 20,
                'area': ?area,
                'latitude': ?latitude,
                'longitude': ?longitude,
              },
            ),
          )
          .map(
            (item) =>
                Restaurant.fromJson(Map<String, Object?>.from(item! as Map)),
          )
          .toList();
  @override
  Future<List<Restaurant>> search(String query, {String? area}) async =>
      unwrapItems(
            await _api.get(
              '/api/v1/restaurants/search',
              query: {'q': query, 'page': 1, 'limit': 20, 'area': ?area},
            ),
          )
          .map(
            (item) =>
                Restaurant.fromJson(Map<String, Object?>.from(item! as Map)),
          )
          .toList();
  @override
  Future<Restaurant> detail(String id) async =>
      Restaurant.fromJson(await _api.get('/api/v1/restaurants/$id'));
  @override
  Future<List<Map<String, Object?>>> branches(String id) async => unwrapItems(
    await _api.get('/api/v1/restaurants/$id/branches'),
  ).map((item) => Map<String, Object?>.from(item! as Map)).toList();
}

class FixtureDiscoveryRepository implements DiscoveryRepository {
  const FixtureDiscoveryRepository();
  @override
  Future<List<Restaurant>> list({
    int page = 1,
    String? area,
    double? latitude,
    double? longitude,
  }) async => FixtureStore.restaurants
      .where(
        (item) => area == null || item.area.toLowerCase() == area.toLowerCase(),
      )
      .toList();
  @override
  Future<List<Restaurant>> search(String query, {String? area}) async {
    final q = query.toLowerCase();
    return FixtureStore.restaurants
        .where(
          (item) =>
              (item.name.toLowerCase().contains(q) ||
                  item.cuisine.toLowerCase().contains(q) ||
                  item.area.toLowerCase().contains(q)) &&
              (area == null || item.area.toLowerCase() == area.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<Restaurant> detail(String id) async =>
      FixtureStore.restaurants.firstWhere((item) => item.id == id);
  @override
  Future<List<Map<String, Object?>>> branches(String id) async =>
      <Map<String, Object?>>[
        {
          'id': 'branch-$id',
          'branchId': 'branch-$id',
          'name': 'Main Branch',
          'status': 'ACTIVE',
          'openingHours': '12:00–23:30',
          'acceptingRequests': true,
        },
      ];
}

final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
  (ref) => ref.watch(appConfigProvider).useFixtures
      ? const FixtureDiscoveryRepository()
      : ApiDiscoveryRepository(ref.watch(apiClientProvider)),
);
final restaurantsProvider = FutureProvider<List<Restaurant>>(
  (ref) => ref.watch(discoveryRepositoryProvider).list(),
);
