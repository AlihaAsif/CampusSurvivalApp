import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';


final tickerProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(
    const Duration(seconds: 30),
        (_) => DateTime.now(),
  ).asBroadcastStream();
});


final nowProvider = Provider<DateTime>((ref) {
  return ref.watch(tickerProvider).value ?? DateTime.now();
});