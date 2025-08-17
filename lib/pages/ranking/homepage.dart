import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gopumplog/pages/ranking/me%20ranking.dart';

class StationRankings extends StatefulWidget {
  const StationRankings({super.key});

  @override
  State<StationRankings> createState() => _StationRankingsState();
}

class _StationRankingsState extends State<StationRankings> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Station Rankings"),
        backgroundColor: const Color(0xFFFFD300),
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('reports').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No reports found"));
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final reportId = report.id;
              final fileName = report['fileName'] ?? "Unnamed File";
              final periodDays = report['periodDays'] ?? 0;
              final createdAt = (report['createdAt'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(reportId, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("File: $fileName\nPeriod: $periodDays days\nCreated: $createdAt"),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return MERanking(reportId: report.id);
                    }));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Clicked on $reportId")),
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
