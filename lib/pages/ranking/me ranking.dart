import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MERanking extends StatefulWidget {
  final String reportId;

  const MERanking({super.key, required this.reportId});

  @override
  State<MERanking> createState() => _MERankingState();
}

class _MERankingState extends State<MERanking> {
  Map<String, dynamic> meStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMERanking();
  }

  Future<void> _loadMERanking() async {
    try {
      // Get the report document
      DocumentSnapshot reportDoc = await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .get();

      if (!reportDoc.exists) {
        setState(() => isLoading = false);
        return;
      }

      // stations list inside reports
      List<dynamic> stationsList = reportDoc['data'];
      int totalStations = stationsList.length;

      Map<String, int> counts = {};

      // For each station in report -> lookup AllStations to get ME
      for (var station in stationsList) {
        String stationName = station['station']; // field inside reports
        String meName = "Unknown";

        // Query AllStations to find ME
        var querySnapshot = await FirebaseFirestore.instance
            .collection('AllStations')
            .where('name', isEqualTo: stationName)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          meName = querySnapshot.docs.first['ME'] ?? "Unknown";
        }

        counts[meName] = (counts[meName] ?? 0) + 1;
      }

      // Convert counts into percentage + sort by ranking
      Map<String, dynamic> results = {};
      var sortedEntries = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)); // descending order

      for (var entry in sortedEntries) {
        results[entry.key] = {
          "count": entry.value,
          "percentage":
          ((entry.value / totalStations) * 100).toStringAsFixed(1),
        };
      }

      setState(() {
        meStats = results;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ME Ranking - ${widget.reportId}")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : meStats.isEmpty
          ? const Center(child: Text("No data found"))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: meStats.entries.map((entry) {
          return Card(
            child: ListTile(
              title: Text("ME: ${entry.key}"),
              subtitle: Text(
                "Stations: ${entry.value['count']} "
                    "(${entry.value['percentage']}%)",
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
