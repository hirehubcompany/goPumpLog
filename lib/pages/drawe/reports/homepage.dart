import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gopumplog/pages/drawe/reports/reports%20details.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reports'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return const Center(child: Text('No reports found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;
              final reportName = snapshot.data!.docs[index].id;

              final createdAt = report['createdAt']?.toDate() ?? DateTime.now();

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    reportName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Created: ${createdAt.toLocal()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportsDetails(
                          reportId: snapshot.data!.docs[index].id,
                        ),
                      ),
                    );
                  },

                ),
              );
            },
          );
        },
      ),
    );
  }
}
