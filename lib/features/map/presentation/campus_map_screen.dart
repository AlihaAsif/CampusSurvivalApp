import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_spacing.dart';
import '../data/campus_places.dart';
import '../domain/campus_place.dart';
import 'map_providers.dart';

class CampusMapScreen extends ConsumerStatefulWidget {
  const CampusMapScreen({super.key});

  @override
  ConsumerState<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends ConsumerState<CampusMapScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();

  bool _showList = false;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _goTo(CampusPlace place) {
    ref.read(selectedPlaceProvider.notifier).state = place;
    _mapController.move(
      LatLng(place.latitude, place.longitude),
      18,
    );
    setState(() => _showList = false);
    FocusScope.of(context).unfocus();
  }

  Future<void> _openDirections(CampusPlace place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&destination=${place.latitude},${place.longitude}',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Maps.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final places = ref.watch(filteredPlacesProvider);
    final selected = ref.watch(selectedPlaceProvider);
    final category = ref.watch(categoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus map'),
        actions: [
          IconButton(
            icon: Icon(_showList ? Icons.map_outlined : Icons.list),
            tooltip: _showList ? 'Show map' : 'Show list',
            onPressed: () => setState(() => _showList = !_showList),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ---------- Search ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.sm,
              AppSpacing.screenH,
              0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search buildings',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                ),
                filled: true,
                fillColor: scheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                setState(() => _showList = value.isNotEmpty);
              },
            ),
          ),

          // ---------- Category chips ----------
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
                vertical: AppSpacing.sm,
              ),
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: category == null,
                  onSelected: (_) {
                    ref.read(categoryFilterProvider.notifier).state = null;
                  },
                ),
                ...PlaceCategory.values
                    .where((value) => campusPlaces
                    .any((place) => place.category == value))
                    .map(
                      (value) => Padding(
                    padding:
                    const EdgeInsets.only(left: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(value.label),
                      selected: category == value,
                      onSelected: (_) {
                        ref
                            .read(categoryFilterProvider.notifier)
                            .state = category == value ? null : value;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------- Map or list ----------
          Expanded(
            child: _showList
                ? _buildList(places, theme, scheme)
                : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(
                      campusCenterLat,
                      campusCenterLng,
                    ),
                    initialZoom: 17,
                    minZoom: 14,
                    maxZoom: 19,
                    onTap: (_, __) {
                      ref
                          .read(selectedPlaceProvider.notifier)
                          .state = null;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                      'com.example.campus_survival',
                    ),
                    MarkerLayer(
                      markers: places.map((place) {
                        final isSelected = selected?.id == place.id;

                        return Marker(
                          point: LatLng(
                            place.latitude,
                            place.longitude,
                          ),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _goTo(place),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(
                                  place.category.colorValue,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: isSelected ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _iconFor(place.category),
                                size: isSelected ? 22 : 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // OpenStreetMap requires attribution.
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    color: Colors.white.withValues(alpha: 0.75),
                    child: Text(
                      '© OpenStreetMap',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                // ---------- Selected place sheet ----------
                if (selected != null)
                  Positioned(
                    left: AppSpacing.screenH,
                    right: AppSpacing.screenH,
                    bottom: AppSpacing.screenH,
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppSpacing.cardPad,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Color(
                                      selected.category.colorValue,
                                    ).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _iconFor(selected.category),
                                    size: 18,
                                    color: Color(
                                      selected.category.colorValue,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: AppSpacing.md,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selected.name,
                                        style: theme
                                            .textTheme.bodyLarge,
                                      ),
                                      Text(
                                        selected.category.label,
                                        style: theme
                                            .textTheme.bodySmall
                                            ?.copyWith(
                                          color: scheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  iconSize: 18,
                                  onPressed: () => ref
                                      .read(selectedPlaceProvider
                                      .notifier)
                                      .state = null,
                                ),
                              ],
                            ),
                            if (selected.description != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                selected.description!,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.45,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: FilledButton.icon(
                                onPressed: () =>
                                    _openDirections(selected),
                                icon: const Icon(
                                  Icons.directions,
                                  size: 18,
                                ),
                                label: const Text('Directions'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      List<CampusPlace> places,
      ThemeData theme,
      ColorScheme scheme,
      ) {
    if (places.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 40,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Nothing found', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Try a different name or category.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.sm,
        AppSpacing.screenH,
        AppSpacing.xxl,
      ),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.card),
              onTap: () => _goTo(place),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPad),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(place.category.colorValue)
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconFor(place.category),
                        size: 20,
                        color: Color(place.category.colorValue),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            place.description ?? place.category.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.directions, size: 20),
                      tooltip: 'Directions',
                      onPressed: () => _openDirections(place),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _iconFor(PlaceCategory category) {
    return switch (category) {
      PlaceCategory.academic => Icons.school_outlined,
      PlaceCategory.library => Icons.menu_book_outlined,
      PlaceCategory.lab => Icons.computer_outlined,
      PlaceCategory.cafeteria => Icons.restaurant_outlined,
      PlaceCategory.admin => Icons.business_outlined,
      PlaceCategory.medical => Icons.local_hospital_outlined,
      PlaceCategory.mosque => Icons.mosque_outlined,
      PlaceCategory.sports => Icons.sports_cricket_outlined,
      PlaceCategory.parking => Icons.local_parking_outlined,
      PlaceCategory.hostel => Icons.hotel_outlined,
      PlaceCategory.transport => Icons.directions_bus_outlined,  // <-- naya
      PlaceCategory.other => Icons.place_outlined,
    };
  }
}