import 'package:flutter/material.dart';

class BusinessStructureModel {
  final String id;
  final String title;
  final String badge;
  final String shortDescription;
  final String aboutDescription;
  final IconData icon;

  const BusinessStructureModel({
    required this.id,
    required this.title,
    required this.badge,
    required this.shortDescription,
    required this.aboutDescription,
    required this.icon,
  });
}

const List<BusinessStructureModel> businessStructuresList = [
  BusinessStructureModel(
    id: 'proprietorship',
    title: 'Proprietorship / Propagator',
    badge: 'Solo Starters',
    shortDescription: 'Ideal for small businesses owned & managed by a single person.',
    aboutDescription:
        'Proprietorship (Propagator) is the simplest form of business structure. It is owned, managed, and controlled by a single individual who assumes full responsibility and receives all profits.',
    icon: Icons.person_outline,
  ),
  BusinessStructureModel(
    id: 'partnership',
    title: 'Partnership Firm',
    badge: 'Co-Founders',
    shortDescription: 'Suitable for two or more co-founders sharing profits and duties.',
    aboutDescription:
        'A Partnership Firm is established by two or more partners who agree to share the profits and losses of a business. It requires minimal compliance and allows mutual pooling of expertise and capital.',
    icon: Icons.people_outline,
  ),
  BusinessStructureModel(
    id: 'pvt_ltd',
    title: 'Private Limited (Pvt Ltd)',
    badge: 'High Growth',
    shortDescription: 'Best for startups seeking investments and long-term growth.',
    aboutDescription:
        'Private Limited Company offers limited liability protection to its shareholders and creates a separate legal identity. It is the preferred structure for venture capital investment and scaling.',
    icon: Icons.apartment,
  ),
  BusinessStructureModel(
    id: 'public_ltd',
    title: 'Public Limited Company',
    badge: 'Enterprise',
    shortDescription: 'Designed for large businesses planning to raise capital publicly.',
    aboutDescription:
        'A Public Limited Company can offer shares to the general public and has limited liability. It is subject to strict regulatory compliance and suited for large scale capital generation.',
    icon: Icons.account_balance,
  ),
  BusinessStructureModel(
    id: 'opc',
    title: 'One Person Company (OPC)',
    badge: 'Solo Corporate',
    shortDescription: 'Corporate benefits with limited liability for solo founders.',
    aboutDescription:
        'One Person Company (OPC) allows a single entrepreneur to operate a corporate entity with limited liability protection, enjoying corporate prestige with fewer compliance burdens.',
    icon: Icons.laptop_mac,
  ),
  BusinessStructureModel(
    id: 'llp',
    title: 'Limited Liability Partnership (LLP)',
    badge: 'Flexible',
    shortDescription: 'Combines partnership flexibility with limited liability.',
    aboutDescription:
        'An LLP gives the benefits of limited liability of a company while allowing its members the flexibility of organizing their internal management on the basis of a mutually arrived partnership agreement.',
    icon: Icons.verified_user_outlined,
  ),
];
