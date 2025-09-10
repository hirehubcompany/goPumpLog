import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:gopumplog/admin/stations/add%20stations.dart';
import 'package:gopumplog/pages/Unknown%20ME/Unlnown%20ME.dart';
import 'package:gopumplog/pages/drawe/reports/homepage.dart';
import 'package:gopumplog/pages/final%20reports/homepage.dart';
import 'package:gopumplog/pages/ranking/me%20RANKING/homepage.dart';
import 'package:gopumplog/pages/stations/edit%20stations/editstations.dart';
import 'package:gopumplog/pages/stations/stations%20tiers/station%20tiers.dart';
import 'package:share_plus/share_plus.dart';
import '../ONLY ME/only me.dart';

class AddDrawer extends StatefulWidget {
  const AddDrawer({super.key});

  @override
  State<AddDrawer> createState() => _AddDrawerState();
}

class _AddDrawerState extends State<AddDrawer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Go Sales Weekly Entry Reports',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Menu Items
          _buildMenuItem(
            icon: Icons.insert_chart_outlined,
            title: 'All Reports',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ReportsPage();
              }));
            },
          ),
          _buildMenuItem(
            icon: Icons.report,
            title: 'Final Reports',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return FinalReports();
              }));
            },
          ),
          _buildMenuItem(
            icon: Icons.assessment,
            title: 'Station Performance Tiers',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return StationPerformanceTiers();
              }));
            },
          ),
          _buildMenuItem(
            icon: Icons.edit,
            title: 'M.E Rankings',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MERanking();
              }));
            },
          ),
          _buildMenuItem(
            icon: Icons.edit_note_rounded,
            title: 'Edit Stations',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Stations();
              }));
            },
          ),
          _buildMenuItem(
            icon: Icons.report,
            title: "Unknown ME's",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return UnknownME();
              }));
            },
          ),
          _buildMenuItem(
            icon: Icons.edit,
            title: 'M.E STATION MANAGER',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ManageStationsPage();
              }));
            },
          ),

          // ✅ Download All Stations button
          _buildMenuItem(
            icon: Icons.download,
            title: 'Download All Stations',
            onTap: () async {
              await _shareStations();
            },
          ),

          const Divider(
            thickness: 1,
            color: Colors.black12,
            indent: 16,
            endIndent: 16,
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Log Out',
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black87,
    Color iconColor = Colors.orange,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _shareStations() async {
    try {
      // Fetch all stations
      final snapshot = await FirebaseFirestore.instance
          .collection("All Stations")
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No stations found")),
        );
        return;
      }

      // Create Excel
      final excel = Excel.createExcel();
      const sheetName = 'Stations';
      excel.rename(excel.getDefaultSheet()!, sheetName);
      final sheet = excel[sheetName];

      // Header
      sheet.appendRow([
        TextCellValue("ME"),
        TextCellValue("Station Name"),
        TextCellValue("Zone"),
      ]);

      // Data rows
      for (final doc in snapshot.docs) {
        final data = doc.data();
        sheet.appendRow([
          TextCellValue((data['ME'] ?? '').toString()),
          TextCellValue((data['name'] ?? '').toString()),
          TextCellValue((data['zone'] ?? '').toString()),
        ]);
      }

      // Encode to bytes
      final bytes = excel.encode();
      if (bytes == null) throw Exception("Failed to encode Excel file");

      // Save to temp dir for sharing
      final tempDir = await getTemporaryDirectory();
      final filePath = "${tempDir.path}/All_Stations.xlsx";
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Share file
      await Share.shareXFiles([XFile(filePath)], text: "Goil Stations List");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

}
