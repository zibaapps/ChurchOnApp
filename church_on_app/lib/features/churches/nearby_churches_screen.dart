import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../common/providers/church_directory_providers.dart';

class NearbyChurchesScreen extends ConsumerStatefulWidget {
  const NearbyChurchesScreen({super.key});
  @override
  ConsumerState<NearbyChurchesScreen> createState() => _NearbyChurchesScreenState();
}

class _NearbyChurchesScreenState extends ConsumerState<NearbyChurchesScreen> {
  Position? _pos;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
    final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() => _pos = p);
  }

  @override
  Widget build(BuildContext context) {
    final churches = ref.watch(churchListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Churches')),
      body: churches.when(
        data: (list) {
          if (_pos == null) return const Center(child: Text('Waiting for location permission...'));
          final lat = _pos!.latitude;
          final lng = _pos!.longitude;
          final withDistance = list.map((c) {
            final m = _distanceKm(lat, lng, (c as dynamic).lat ?? 0.0, (c as dynamic).lng ?? 0.0);
            return {'c': c, 'km': m};
          }).toList();
          withDistance.sort((a, b) => (a['km'] as double).compareTo(b['km'] as double));
          return ListView.builder(
            itemCount: withDistance.length,
            itemBuilder: (context, i) {
              final c = withDistance[i]['c'];
              final km = withDistance[i]['km'] as double;
              return ListTile(
                leading: const Icon(Icons.church),
                title: Text((c as dynamic).name as String),
                subtitle: Text('${km.toStringAsFixed(1)} km away'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180.0);
}