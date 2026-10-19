import 'package:flutter/material.dart';

/// Tab Cari — pencarian dan filter hotel.
class CariTab extends StatefulWidget {
  const CariTab({super.key});

  @override
  State<CariTab> createState() => _CariTabState();
}

class _CariTabState extends State<CariTab> {
  final _searchController = TextEditingController();

  final _results = [
    {'name': 'Grand Amora Resort', 'location': 'Seminyak, Bali', 'price': 'Rp 850.000', 'rating': '4.9'},
    {'name': 'Alila Cliff Sanctuary', 'location': 'Uluwatu, Bali', 'price': 'Rp 1.450.000', 'rating': '4.8'},
    {'name': 'Padma Resort Ubud', 'location': 'Ubud, Bali', 'price': 'Rp 1.200.000', 'rating': '4.7'},
    {'name': 'Kuta Beach Hotel', 'location': 'Kuta, Bali', 'price': 'Rp 450.000', 'rating': '4.3'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B4D8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Cari hotel, kota, destinasi...',
              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(Icons.search, color: Color(0xFF00B4D8), size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final h = _results[i];
          return _buildResultCard(h);
        },
      ),
    );
  }

  Widget _buildResultCard(Map<String, String> hotel) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hotel, color: Color(0xFF00B4D8), size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF00B4D8), size: 12),
                        const SizedBox(width: 2),
                        Text(
                          hotel['location']!,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          hotel['price']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const Text(
                          '/malam',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                        const Spacer(),
                        const Icon(Icons.star,
                            color: Color(0xFFFBBC05), size: 13),
                        const SizedBox(width: 2),
                        Text(
                          hotel['rating']!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
