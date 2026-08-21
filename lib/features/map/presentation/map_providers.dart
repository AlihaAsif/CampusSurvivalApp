import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/campus_places.dart';
import '../domain/campus_place.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final categoryFilterProvider =
StateProvider<PlaceCategory?>((ref) => null);

final filteredPlacesProvider = Provider<List<CampusPlace>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(categoryFilterProvider);

  return campusPlaces.where((place) {
    if (category != null && place.category != category) return false;
    return place.matches(query);
  }).toList();
});

final selectedPlaceProvider = StateProvider<CampusPlace?>((ref) => null);