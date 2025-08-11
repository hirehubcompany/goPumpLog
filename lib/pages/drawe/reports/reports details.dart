import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsDetails extends StatefulWidget {
  final String reportId;

  const ReportsDetails({super.key, required this.reportId});

  @override
  State<ReportsDetails> createState() => _ReportsDetailsState();
}

class _ReportsDetailsState extends State<ReportsDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details'),
        backgroundColor: const Color(0xFFFFD300),
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('reports')
            .doc(widget.reportId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading report details'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Report not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final stations = List<Map<String, dynamic>>.from(data['data'] ?? []);

          if (stations.isEmpty) {
            return const Center(child: Text('No stations found for this report.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
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
    );
  }
}
