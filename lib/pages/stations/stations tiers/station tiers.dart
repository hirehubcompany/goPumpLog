import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StationPerformanceTiers extends StatefulWidget {
  const StationPerformanceTiers({super.key});

  @override
  State<StationPerformanceTiers> createState() =>
      _StationPerformanceTiersState();
}

class _StationPerformanceTiersState extends State<StationPerformanceTiers> {
  // Function to group stations into performance tiers
  Map<String, List<Map<String, dynamic>>> groupStations(
      List<Map<String, dynamic>> allStations,
      List<Map<String, dynamic>> reportedStations) {
    Map<String, List<Map<String, dynamic>>> groups = {
      "80% - 100%": [],
      "40% - 79%": [],
      "1% - 39%": [],
      "No Entries": [],
    };

    // Track reported station names
    final reportedNames =
    reportedStations.map((s) => (s['station'] ?? "").toString()).toSet();

    for (var station in reportedStations) {
      final percentageStr = station['percentage'] ?? "0%";
      final entries = station['entries'] ?? 0;
      final percentage =
          double.tryParse(percentageStr.replaceAll('%', '')) ?? 0;

      if (entries == 0) {
        groups["No Entries"]!.add(station);
      } else if (percentage >= 80) {
        groups["80% - 100%"]!.add(station);
      } else if (percentage >= 40) {
        groups["40% - 79%"]!.add(station);
      } else if (percentage >= 1) {
        groups["1% - 39%"]!.add(station);
      }
    }

    // Add stations that never appeared in reports → "No Entries"
    for (var station in allStations) {
      final name = station['name'] ?? "Unknown Station";
      final zone = station['zone'] ?? "Unknown Zone";
      if (!reportedNames.contains(name)) {
        groups["No Entries"]!.add({
          "station": name,
          "entries": 0,
          "percentage": "0%",
          "zone": zone,
        });
      }
    }

    return groups;
  }

  // 🎨 Helper: get color badge for percentage tiers
  Color getBadgeColor(String percentageStr) {
    final value = double.tryParse(percentageStr.replaceAll('%', '')) ?? 0;
    if (value >= 80) return Colors.green.shade600;
    if (value >= 40) return Colors.orange.shade600;
    if (value >= 1) return Colors.red.shade600;
    return Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "📊 Station Performance Tiers",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        backgroundColor: const Color(0xFFFFD300),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder(
        future: Future.wait([
          FirebaseFirestore.instance.collection('All Stations').get(),
          FirebaseFirestore.instance.collection('reports').get(),
        ]),
        builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading stations"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allStations = snapshot.data![0].docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          List<Map<String, dynamic>> reportedStations = [];
          for (var doc in snapshot.data![1].docs) {
            final data = doc.data() as Map<String, dynamic>;
            final stationList =
            List<Map<String, dynamic>>.from(data['data'] ?? []);
            reportedStations.addAll(stationList);
          }

          // Group stations
          final groupedStations = groupStations(allStations, reportedStations);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: groupedStations.entries.map((entry) {
              final groupName = entry.key;
              final groupStations = entry.value;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                  title: Text(
                    "$groupName (${groupStations.length})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  children: groupStations.isEmpty
                      ? [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "No stations in this category",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  ]
                      : groupStations.map((station) {
                    final percentage = station['percentage'] ?? "0%";
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          station['station'] ?? "Unknown Station",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "Zone: ${station['zone'] ?? 'Unknown Zone'}\nEntries: ${station['entries'] ?? 0}",
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: getBadgeColor(percentage),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            percentage,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
