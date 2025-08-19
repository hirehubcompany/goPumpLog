import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';import 'package:gopumplog/admin/stations/add%20stations.dart';
import 'package:gopumplog/pages/drawe/reports/homepage.dart';
import 'package:gopumplog/pages/stations/edit%20stations/editstations.dart';
import 'package:gopumplog/pages/stations/stations%20tiers/station%20tiers.dart';

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
            title: 'Edit Stations',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Stations();
              }));
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
}
