import 'dart:io';

void fixFile(String path) {
  final file = File(path);
  if (!file.existsSync()) return;
  
  String content = file.readAsStringSync();
  
  content = content.replaceAll(
    "_buildTierCard('STARTUP', 'Small business / new company', Icons.rocket_launch, _selectedTier == 'STARTUP', true)",
    "_buildTierCard('STARTUP', 'Small business / new company', Icons.rocket_launch, isSelected: _selectedTier == 'STARTUP', isRecommended: true)"
  );
  
  content = content.replaceAll(
    "_buildTierCard('STANDARD', 'Growing business', Icons.business, _selectedTier == 'STANDARD', false)",
    "_buildTierCard('STANDARD', 'Growing business', Icons.business, isSelected: _selectedTier == 'STANDARD')"
  );
  
  content = content.replaceAll(
    "_buildTierCard('CORPORATE', 'Large organization', Icons.location_city, _selectedTier == 'CORPORATE', false)",
    "_buildTierCard('CORPORATE', 'Large organization', Icons.location_city, isSelected: _selectedTier == 'CORPORATE')"
  );
  
  // Let's also check if the existing _buildTierCard uses InkWell and _selectedTier.
  // Wait, if it already existed, did it have onTap and update _selectedTier?
  // Let's replace the whole method just in case.
  final RegExp tierCardRegex = RegExp(r'Widget _buildTierCard.*?\{.*?\n  \}', dotAll: true);
  String newTierCardMethod = '''
  Widget _buildTierCard(String title, String subtitle, IconData icon, {bool isSelected = false, bool isRecommended = false}) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTier = title;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isRecommended)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.red, size: 10),
                        const SizedBox(width: 4),
                        Text('Recommended', style: GoogleFonts.poppins(color: Colors.red, fontSize: 9, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                Icon(icon, color: isSelected ? AppColors.primaryBlue : Colors.blue.shade300, size: 32),
                const SizedBox(height: 12),
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 11)),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }''';

  content = content.replaceFirst(tierCardRegex, newTierCardMethod);
  
  file.writeAsStringSync(content);
}

void main() {
  fixFile('lib/features/business/presentation/screens/create_propagator_screen.dart');
  fixFile('lib/features/business/presentation/screens/create_partner_screen.dart');
  fixFile('lib/features/business/presentation/screens/create_supplier_screen.dart');
  print('Fixed files!');
}
