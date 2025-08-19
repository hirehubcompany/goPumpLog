import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsDetails extends StatefulWidget {
  final String reportId;

  const ReportsDetails({super.key, required this.reportId});

  @override
  State<ReportsDetails> createState() => _ReportsDetailsState();
}

class _ReportsDetailsState extends State<ReportsDetails> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: const Color(0xFFFFD300),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 🔹 Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search stations...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // 🔹 Report details list
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('reports')
                  .doc(widget.reportId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading report details'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Report not found.'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final stations =
                List<Map<String, dynamic>>.from(data['data'] ?? []);

                if (stations.isEmpty) {
                  return const Center(
                      child: Text('No stations found for this report.'));
                }

                // 🔹 Sort alphabetically
                stations.sort((a, b) {
                  final nameA = (a['station'] ?? '').toString().toLowerCase();
                  final nameB = (b['station'] ?? '').toString().toLowerCase();
                  return nameA.compareTo(nameB);
                });

                // 🔹 Apply search filter
                final filteredStations = stations.where((station) {
                  final name =
                  (station['station'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredStations.isEmpty) {
                  return const Center(child: Text("No matching stations."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredStations.length,
                  itemBuilder: (context, index) {
                    final station = filteredStations[index];
                    final name = station['station'] ?? 'Unknown Station';
                    final entries = station['entries'] ?? 0;
                    final percentage = station['percentage'] ?? '0%';

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Entries: $entries',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Text(
                          percentage,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
