import '../domain/campus_place.dart';

/// The campus map. Coordinates were read off Google Maps by hand —
/// no public API knows this university's buildings.
const List<CampusPlace> campusPlaces = [
  CampusPlace(
    id: 'main_gate',
    name: 'Main Gate',
    category: PlaceCategory.other,
    latitude: 30.643116410170272,
    longitude: 73.14982198357879,
    description: 'Entry point to the campus.',
  ),
  CampusPlace(
    id: 'cs_department',
    name: 'Department of Computer Science',
    category: PlaceCategory.academic,
    latitude: 30.64138885348103,
    longitude: 73.14839086172037,
    description: 'CS and SE lecture halls and labs.',
  ),
  CampusPlace(
    id: 'mechanical_department',
    name: 'Department of Mechanical Engineering',
    category: PlaceCategory.academic,
    latitude: 30.641440379124354,
    longitude: 73.14908334401316,
  ),
  CampusPlace(
    id: 'b_block',
    name: 'B Block',
    category: PlaceCategory.academic,
    latitude: 30.64276763983519,
    longitude: 73.14831988612148,
  ),
  CampusPlace(
    id: 'w_block',
    name: 'W Block',
    category: PlaceCategory.academic,
    latitude: 30.640955680432715,
    longitude: 73.14886658089596,
  ),
  CampusPlace(
    id: 'auditorium',
    name: 'Auditorium',
    category: PlaceCategory.other,
    latitude: 30.641645287734242,
    longitude: 73.148835950297,
    description: 'Seminars, events and orientation sessions.',
  ),
  CampusPlace(
    id: 'cafeteria',
    name: 'Cafeteria',
    category: PlaceCategory.cafeteria,
    latitude: 30.642455555227105,
    longitude: 73.1488312842399,
    description: 'Canteen and chai point.',
  ),
  CampusPlace(
    id: 'masjid',
    name: 'Campus Masjid',
    category: PlaceCategory.mosque,
    latitude: 30.643497538682443,
    longitude: 73.14849035215919,
    description: 'Daily prayers and Jummah.',
  ),
  CampusPlace(
    id: 'sports_ground',
    name: 'Sports Ground',
    category: PlaceCategory.sports,
    latitude: 30.64408418236814,
    longitude: 73.14957855977208,
    description: 'Cricket and football.',
  ),
  CampusPlace(
    id: 'transport_office',
    name: 'Bus Transport Department',
    category: PlaceCategory.transport,
    latitude: 30.64461542003798,
    longitude: 73.14835121845636,
    description: 'Bus routes, cards and timings.',
  ),
  CampusPlace(
    id: 'erozgar_center',
    name: 'e-Rozgaar Centre',
    category: PlaceCategory.lab,
    latitude: 30.64131281808342,
    longitude: 73.14846142761584,
    description: 'Freelancing training lab.',
  ),
];

/// Where the map opens — roughly the middle of the campus.
const double campusCenterLat = 30.6428;
const double campusCenterLng = 73.1489;