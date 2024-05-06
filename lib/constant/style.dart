import 'package:flutter/material.dart';

ButtonStyle segmentedButtonStyle = SegmentedButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 40.0),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
  ),
  fixedSize: const Size(100, 100),
  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
);
