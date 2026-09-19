import 'package:flutter/material.dart';

class BusinessStepModel {
  final String stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final String badgeText;
  final Color bgLightColor;
  final Color iconColor;
  final Color badgeBorderColor;
  final Color badgeTextColor;
  final Color badgeBgColor;

  const BusinessStepModel({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.badgeText,
    required this.bgLightColor,
    required this.iconColor,
    required this.badgeBorderColor,
    required this.badgeTextColor,
    required this.badgeBgColor,
  });
}
