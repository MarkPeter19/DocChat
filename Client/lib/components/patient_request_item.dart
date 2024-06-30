import 'package:flutter/material.dart';
import '../screens/DoctorScreens/Requests/PatientDataDetailsScreen.dart';
import '../../services/doctor_services.dart'; // Importáljuk a szolgáltatások osztályt

class PatientRequestItem extends StatelessWidget {
  final String patientName;
  final String documentDate;
  final String documentId;
  final String patientId;
  final String tag;

  const PatientRequestItem({
    Key? key,
    required this.patientName,
    required this.documentDate,
    required this.documentId,
    required this.patientId,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color avatarBackgroundColor;
    Color titleColor;
    Color subtitleColor;

    // Set colors based on tag
    switch (tag) {
      case 'urgent':
        backgroundColor = const Color.fromARGB(255, 191, 56, 65);
        avatarBackgroundColor = const Color.fromARGB(255, 205, 55, 100);
        titleColor = const Color.fromARGB(255, 246, 221, 221);
        subtitleColor = const Color.fromARGB(255, 255, 193, 193);
        break;
      case 'not urgent':
        backgroundColor = const Color.fromARGB(255, 255, 242, 59);
        avatarBackgroundColor = const Color.fromARGB(255, 219, 209, 77);
        titleColor = Colors.black; // Change to black for better contrast
        subtitleColor = const Color.fromARGB(255, 0, 0, 0);
        break;
      case 'done':
        backgroundColor = const Color.fromARGB(255, 56, 207, 97);
        avatarBackgroundColor = const Color.fromARGB(255, 55, 205, 107);
        titleColor = Colors.white; // Change to white for better contrast
        subtitleColor = const Color.fromARGB(255, 255, 255, 255);
        break;
      default:
        backgroundColor = Colors.white;
        avatarBackgroundColor = const Color.fromARGB(255, 163, 163, 163);
        titleColor = Colors.black;
        subtitleColor = const Color.fromARGB(255, 123, 121, 121);
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: backgroundColor,
      elevation: 5.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarBackgroundColor,
          foregroundColor: Colors.white,
          radius: 25,
          child: Text(patientName[0], style: const TextStyle(fontSize: 18)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patientName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tag.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                color: titleColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
        subtitle: Text(
          documentDate,
          style: TextStyle(
            fontSize: 16,
            color: subtitleColor,
          ),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          color: Colors.white,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PatientDataDetailsScreen(
                patientId: patientId,
                documentId: documentId,
              ),
            ),
          );
        },
        // Long press handler for deletion
        onLongPress: () {
          _showDeleteConfirmationDialog(context);
        },
      ),
    );
  }

  // Method to show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Confirmation"),
          content: const Text("Are you sure you want to delete this request?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                // Call the method to delete the request
                _deleteRequest(context);
              },
              child: const Text(
                "DELETE",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to delete the request
  void _deleteRequest(BuildContext context) async {
    try {
      // Delete request using DoctorServices
      await DoctorServices().deleteRequest(patientId, documentId);

      // Notify user with a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request deleted')),
      );

      // Close the dialog
      Navigator.of(context).pop();
    } catch (e) {
      print('Error deleting request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete request')),
      );
    }
  }
}
