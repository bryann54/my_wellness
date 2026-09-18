// lib/common/utils/location_map_picker.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef OnLocationPicked =
    void Function({
      required double lat,
      required double lng,
      required String address,
    });

// ── Dark map style ────────────────────────────────────────────────────────────

const _kDarkStyle = '''[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]}
]''';

// ── Compact picker (inline) ───────────────────────────────────────────────────

class LocationMapPicker extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final OnLocationPicked onLocationPicked;
  final Future<void> Function()? onRestoreGps;

  const LocationMapPicker({
    super.key,
    this.initialLat = 0.0,
    this.initialLng = 0.0,
    required this.onLocationPicked,
    this.onRestoreGps,
  });

  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  final _ctrl = Completer<GoogleMapController>();

  LatLng? _pin;
  LatLng? _gpsPin;
  String? _address;
  bool _resolving = false;
  bool _restoringGps = false;
  bool _deviated = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    if (_valid(widget.initialLat, widget.initialLng)) {
      final pos = LatLng(widget.initialLat, widget.initialLng);
      _pin = pos;
      _gpsPin = pos;
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolve(pos));
    }
  }

  @override
  void didUpdateWidget(LocationMapPicker old) {
    super.didUpdateWidget(old);
    if ((widget.initialLat != old.initialLat ||
            widget.initialLng != old.initialLng) &&
        _valid(widget.initialLat, widget.initialLng)) {
      final pos = LatLng(widget.initialLat, widget.initialLng);
      _gpsPin = pos;
      _animateTo(pos);
      _resolve(pos);
      setState(() => _deviated = false);
    }
  }

  bool _valid(double lat, double lng) => lat != 0.0 && lng != 0.0;

  Future<void> _animateTo(LatLng pos, {double zoom = 16}) async {
    if (!_ctrl.isCompleted) return;
    final c = await _ctrl.future;
    c.animateCamera(CameraUpdate.newLatLngZoom(pos, zoom));
  }

  Future<void> _onMapCreated(GoogleMapController c) async {
    if (!_ctrl.isCompleted) _ctrl.complete(c);
    if (Theme.of(context).brightness == Brightness.dark) {
      await c.setMapStyle(_kDarkStyle);
    }
    setState(() => _mapReady = true);
    if (_pin != null) _animateTo(_pin!);
  }

  void _onTap(LatLng pos) {
    HapticFeedback.selectionClick();
    final nearGps =
        _gpsPin != null &&
        (pos.latitude - _gpsPin!.latitude).abs() < 0.0001 &&
        (pos.longitude - _gpsPin!.longitude).abs() < 0.0001;
    setState(() => _deviated = !nearGps);
    _resolve(pos);
  }

  Future<void> _resolve(LatLng pos) async {
    setState(() {
      _pin = pos;
      _resolving = true;
      _address = null;
    });
    final address = await _geocode(pos);
    if (!mounted) return;
    setState(() {
      _address = address;
      _resolving = false;
    });
    widget.onLocationPicked(
      lat: pos.latitude,
      lng: pos.longitude,
      address: address,
    );
  }

  Future<void> _restoreGps() async {
    if (_restoringGps || widget.onRestoreGps == null) return;
    setState(() => _restoringGps = true);
    await widget.onRestoreGps!();
    if (mounted) setState(() => _restoringGps = false);
  }

  void _openFullscreen() => Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _FullscreenPicker(
        pin: _pin,
        gpsPin: _gpsPin,
        address: _address,
        onLocationPicked:
            ({
              required double lat,
              required double lng,
              required String address,
            }) {
              final pos = LatLng(lat, lng);
              setState(() {
                _pin = pos;
                _address = address;
                _deviated =
                    _gpsPin == null || (lat - _gpsPin!.latitude).abs() > 0.0001;
              });
              widget.onLocationPicked(lat: lat, lng: lng, address: address);
            },
        onRestoreGps: widget.onRestoreGps,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final initial = CameraPosition(
      target: LatLng(
        _valid(widget.initialLat, widget.initialLng)
            ? widget.initialLat
            : -1.286389,
        _valid(widget.initialLat, widget.initialLng)
            ? widget.initialLng
            : 36.817223,
      ),
      zoom: _valid(widget.initialLat, widget.initialLng) ? 15 : 12,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Map ──────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 220,
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: initial,
                  onMapCreated: _onMapCreated,
                  onTap: _onTap,
                  markers: _pin == null
                      ? {}
                      : {
                          Marker(
                            markerId: const MarkerId('pin'),
                            position: _pin!,
                          ),
                        },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                ),

                // Map loading overlay
                if (!_mapReady)
                  Container(
                    color: cs.surfaceContainerLow,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    ),
                  ),

                // Fullscreen button
                Positioned(
                  top: 10,
                  right: 10,
                  child: _CircleButton(
                    icon: Icons.fullscreen_rounded,
                    onTap: _openFullscreen,
                  ),
                ),

                // GPS restore
                if (_deviated && widget.onRestoreGps != null)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: _CircleButton(
                      icon: Icons.my_location_rounded,
                      isLoading: _restoringGps,
                      onTap: _restoreGps,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ── Address / hint ────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _pin == null
              ? _HintRow(key: const ValueKey('h'))
              : _AddressStrip(
                  key: const ValueKey('a'),
                  resolving: _resolving,
                  address: _address,
                ),
        ),
      ],
    );
  }
}

// ── Fullscreen picker ─────────────────────────────────────────────────────────

class _FullscreenPicker extends StatefulWidget {
  final LatLng? pin;
  final LatLng? gpsPin;
  final String? address;
  final OnLocationPicked onLocationPicked;
  final Future<void> Function()? onRestoreGps;

  const _FullscreenPicker({
    required this.pin,
    required this.gpsPin,
    required this.address,
    required this.onLocationPicked,
    this.onRestoreGps,
  });

  @override
  State<_FullscreenPicker> createState() => _FullscreenPickerState();
}

class _FullscreenPickerState extends State<_FullscreenPicker> {
  final _ctrl = Completer<GoogleMapController>();
  final _searchCtrl = TextEditingController();

  LatLng? _pin;
  String? _address;
  bool _resolving = false;
  bool _restoringGps = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _pin = widget.pin;
    _address = widget.address;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(GoogleMapController c) async {
    if (!_ctrl.isCompleted) _ctrl.complete(c);
    if (Theme.of(context).brightness == Brightness.dark) {
      await c.setMapStyle(_kDarkStyle);
    }
    setState(() => _mapReady = true);
    if (_pin != null) _animateTo(_pin!);
  }

  Future<void> _animateTo(LatLng pos, {double zoom = 16}) async {
    if (!_ctrl.isCompleted) return;
    final c = await _ctrl.future;
    c.animateCamera(CameraUpdate.newLatLngZoom(pos, zoom));
  }

  void _onTap(LatLng pos) {
    HapticFeedback.selectionClick();
    _resolve(pos);
  }

  Future<void> _resolve(LatLng pos) async {
    setState(() {
      _pin = pos;
      _resolving = true;
      _address = null;
    });
    final address = await _geocode(pos);
    if (!mounted) return;
    setState(() {
      _address = address;
      _resolving = false;
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    try {
      final results = await locationFromAddress(query);
      if (results.isEmpty || !mounted) return;
      final pos = LatLng(results.first.latitude, results.first.longitude);
      _animateTo(pos);
      _resolve(pos);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location not found')));
      }
    }
  }

  Future<void> _restoreGps() async {
    if (_restoringGps || widget.onRestoreGps == null) return;
    setState(() => _restoringGps = true);
    await widget.onRestoreGps!();
    if (mounted) {
      setState(() => _restoringGps = false);
      if (widget.gpsPin != null) {
        _animateTo(widget.gpsPin!);
        _resolve(widget.gpsPin!);
      }
    }
  }

  void _confirm() {
    if (_pin == null || _address == null || _resolving) return;
    widget.onLocationPicked(
      lat: _pin!.latitude,
      lng: _pin!.longitude,
      address: _address!,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _pin ?? const LatLng(-1.286389, 36.817223),
              zoom: _pin != null ? 15 : 12,
            ),
            onMapCreated: _onMapCreated,
            onTap: _onTap,
            markers: _pin == null
                ? {}
                : {Marker(markerId: const MarkerId('p'), position: _pin!)},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
          ),

          if (!_mapReady)
            Container(
              color: cs.surface,
              child: Center(
                child: CircularProgressIndicator(color: cs.primary),
              ),
            ),

          // ── Top bar: back + search ────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: cs.onSurface,
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: _search,
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── GPS restore ─────────────────────────────────────────
          if (widget.onRestoreGps != null)
            Positioned(
              right: 12,
              bottom: 130,
              child: _CircleButton(
                icon: Icons.my_location_rounded,
                isLoading: _restoringGps,
                onTap: _restoreGps,
              ),
            ),

          // ── Bottom confirm panel ─────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AddressStrip(resolving: _resolving, address: _address),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _pin != null && !_resolving ? _confirm : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Confirm Location',
                        style: GoogleFonts.syne(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Future<String> _geocode(LatLng pos) async {
  try {
    final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    final p = marks.first;
    final address = [
      p.street,
      p.subLocality,
      p.locality,
      p.administrativeArea,
    ].where((s) => s != null && s.isNotEmpty).join(', ');
    return address.isNotEmpty ? address : _coordStr(pos);
  } catch (_) {
    return _coordStr(pos);
  }
}

String _coordStr(LatLng p) =>
    '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  )
                : Icon(icon, size: 20, color: cs.onSurface),
          ),
        ),
      ),
    );
  }
}

class _AddressStrip extends StatelessWidget {
  final bool resolving;
  final String? address;

  const _AddressStrip({super.key, required this.resolving, this.address});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: resolving
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Resolving address...',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(Icons.location_pin, size: 14, color: cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.touch_app_rounded,
          size: 14,
          color: cs.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 6),
        Text(
          'Tap the map to set location',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: cs.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
