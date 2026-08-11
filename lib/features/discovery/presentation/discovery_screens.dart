import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/widgets/seat_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../data/discovery_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(restaurantsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(restaurantsProvider.future),
      child: CustomScrollView(
        key: const PageStorageKey('home-scroll'),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverList.list(
              children: [
                Text(
                  l.discoverTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 18),
                Semantics(
                  button: true,
                  label: l.searchHint,
                  child: TextField(
                    readOnly: true,
                    onTap: () => context.push('/search'),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l.searchHint,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l.recommended,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          data.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: SeatAsyncError(
                error: e,
                onRetry: () => ref.invalidate(restaurantsProvider),
              ),
            ),
            data: (items) => items.isEmpty
                ? SliverFillRemaining(
                    child: Center(child: Text(l.noRestaurants)),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      itemBuilder: (_, i) => RestaurantCard(
                        restaurant: items[i],
                        onTap: () =>
                            context.push('/restaurants/${items[i].id}'),
                      ),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchState();
}

class _SearchState extends ConsumerState<SearchScreen> {
  final controller = TextEditingController();
  List<Restaurant> results = [];
  bool loading = false;
  Future<void> search() async {
    setState(() => loading = true);
    try {
      results = await ref
          .read(discoveryRepositoryProvider)
          .search(controller.text);
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SeatPage(
      title: l.search,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l.searchHint,
                suffixIcon: IconButton(
                  onPressed: search,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (loading) const LinearProgressIndicator(),
            Expanded(
              child: results.isEmpty
                  ? Center(child: Text(l.changeSearch))
                  : ListView.separated(
                      itemCount: results.length,
                      itemBuilder: (_, i) => RestaurantCard(
                        restaurant: results[i],
                        onTap: () =>
                            context.push('/restaurants/${results[i].id}'),
                      ),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantDetailScreen extends ConsumerWidget {
  const RestaurantDetailScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return FutureBuilder(
      future: () async {
        final repository = ref.read(discoveryRepositoryProvider);
        return (await repository.detail(id), await repository.branches(id));
      }(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SeatPage(
            title: '',
            child: SeatAsyncError(
              error: snapshot.error!,
              onRetry: () => context.pushReplacement('/restaurants/$id'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final (r, branches) = snapshot.data!;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(r.name),
                  background: RestaurantCard(restaurant: r, onTap: () {}),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList.list(
                  children: [
                    Text(
                      '${r.cuisine} · ${r.area}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.about,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(r.description.isEmpty ? '—' : r.description),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: branches.isEmpty
                  ? null
                  : () => context.push(
                      '/restaurants/$id/request?branchId=${branches.first['id'] ?? branches.first['branchId']}',
                    ),
              child: Text(l.requestReservation),
            ),
          ),
        );
      },
    );
  }
}
