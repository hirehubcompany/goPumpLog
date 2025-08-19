import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Stations extends StatefulWidget {
  const Stations({super.key});

  @override
  State<Stations> createState() => _StationsState();
}

class _StationsState extends State<Stations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Stations"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('All Stations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No stations found",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final stations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              var station = stations[index];
              var data = station.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(
                    data['name'] ?? "Unknown Station",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      "Zone: ${data['zone'] ?? 'N/A'}\nME: ${data['ME'] ?? 'N/A'}",
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                  trailing: const Icon(Icons.edit, color: Colors.deepOrange),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditStationPage(
                          docId: station.id,
                          data: data,
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



class EditStationPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditStationPage({super.key, required this.docId, required this.data});

  @override
  State<EditStationPage> createState() => _EditStationPageState();
}

class _EditStationPageState extends State<EditStationPage> {
  late TextEditingController nameController;
  late TextEditingController meController;
  late TextEditingController createdAtController;

  String? selectedZone;

  final List<String> zones = [
    "UpperMiddleBelt",
    "Middle Belt",
    "South",
    "South east",
    "Takoradi",
    "North North west",
    "Tema",
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name'] ?? '');
    meController = TextEditingController(text: widget.data['ME'] ?? '');
    createdAtController =
        TextEditingController(text: widget.data['createdAt']?.toString() ?? '');

    // Initialize selected zone with current zone
    selectedZone = widget.data['zone'];
  }

  @override
  void dispose() {
    nameController.dispose();
    meController.dispose();
    createdAtController.dispose();
    super.dispose();
  }

  Future<void> updateStation() async {
    try {
      await FirebaseFirestore.instance
          .collection('All Stations')
          .doc(widget.docId)
          .update({
        'name': nameController.text,
        'zone': selectedZone,
        'ME': meController.text,
        'createdAt': createdAtController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Station updated successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error updating station: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Station"),
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField(controller: nameController, label: "Station Name"),
            const SizedBox(height: 15),

            // Zone dropdown
            DropdownButtonFormField<String>(
              value: selectedZone,
              decoration: InputDecoration(
                labelText: "Zone",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: zones.map((zone) {
                return DropdownMenuItem(
                  value: zone,
                  child: Text(zone),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedZone = value;
                });
              },
            ),

            const SizedBox(height: 15),
            _buildTextField(controller: meController, label: "ME"),
            const SizedBox(height: 15),
            _buildTextField(controller: createdAtController, label: "Created At"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateStation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Update Station",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
