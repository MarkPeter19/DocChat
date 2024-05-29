import 'package:doctorgpt/components/success_dialog.dart';
import 'package:doctorgpt/services/appointments_services.dart';
import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';

class ViewAppointmentScreen extends StatefulWidget {
  final String appointmentId;
  final String doctorId;
  final Map<String, dynamic> date;
  final String hourMinute;
  final String message;

  const ViewAppointmentScreen({
    Key? key,
    required this.appointmentId,
    required this.doctorId,
    required this.date,
    required this.hourMinute,
    required this.message,
  }) : super(key: key);

  @override
  _ViewAppointmentScreenState createState() => _ViewAppointmentScreenState();
}

class _ViewAppointmentScreenState extends State<ViewAppointmentScreen> {
  bool isDeclined = false;
  final TextEditingController declineReasonController = TextEditingController();

  @override
  void dispose() {
    declineReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Appointment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 3,
            color: const Color.fromARGB(255, 223, 255, 228),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 69, 167, 83)),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.calendar_month_outlined,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Hi, you have got an appointment, is it suitable for you?',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<String>(
                    future: DoctorServices().getDoctorName(widget.doctorId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 123, 203, 247)),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                        title: Text(snapshot.data ?? "Unknown",
                            style: const TextStyle(fontSize: 18)),
                      );
                    },
                  ),
                  FutureBuilder<String>(
                    future:
                        DoctorServices().getDoctorAddress(widget.doctorId),
                    builder: (context, addressSnapshot) {
                      if (addressSnapshot.hasError) {
                        return Text('Error: ${addressSnapshot.error}');
                      }
                      return ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 235, 164, 58),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child:
                                Icon(Icons.location_on, color: Colors.white),
                          ),
                        ),
                        title: Text(addressSnapshot.data ?? "Unknown Address",
                            style: const TextStyle(fontSize: 18)),
                      );
                    },
                  ),
                  ListTile(
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 125, 211, 75)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.calendar_today, color: Colors.white),
                      ),
                    ),
                    title: Text(
                        'Date: ${widget.date['year']}-${widget.date['month']}-${widget.date['day']}',
                        style: const TextStyle(fontSize: 18)),
                  ),
                  ListTile(
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 209, 103, 128)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.access_time, color: Colors.white),
                      ),
                    ),
                    title: Text('Time: ${widget.hourMinute}',
                        style: const TextStyle(fontSize: 18)),
                  ),
                  ListTile(
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 184, 78, 203)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.message, color: Colors.white),
                      ),
                    ),
                    title: Text(widget.message,
                        style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 20),

                  //buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          setState(() {
                            isDeclined = false;
                          });
                          try {
                            await AppointmentServices().acceptAppointment(widget.appointmentId);

                            // success dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SuccessDialog(
                                  message: 'Appointment accepted successfully!',
                                  onPressed: () {
                                    Navigator.pop(context); // Dialógus bezárása
                                    Navigator.pop(context); // Visszalépés a PatientHomeScreen-re
                                  },
                                );
                              },
                            );
                          } catch (e) {
                            print('Error accepting appointment: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error accepting appointment')),
                            );
                          }
                        },
                        icon: const Icon(Icons.check, size: 30, color: Colors.white),
                        label: const Text('Accept', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isDeclined = true;
                          });
                        },
                        icon: const Icon(Icons.close, size: 30, color: Colors.white),
                        label: const Text('Decline', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                  if (isDeclined)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        TextField(
                          controller: declineReasonController,
                          decoration: const InputDecoration(
                            labelText: 'Type reason for decline...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            setState(() {
                              isDeclined = false;
                            });
                            try {
                              String declineReason = declineReasonController.text;
                              await AppointmentServices().declineAppointment(widget.appointmentId, declineReason);
                              showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SuccessDialog(
                                  message: 'Decline message sent successfully!',
                                  onPressed: () {
                                    Navigator.pop(context); // Dialógus bezárása
                                    Navigator.pop(context); // Visszalépés a PatientHomeScreen-re
                                  },
                                );
                              },
                            );
                             // Navigator.pop(context); // Navigálás a PatientHomeScreen-re
                            } catch (e) {
                              print('Error declining appointment: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error declining appointment')),
                              );
                            }
                          },
                          icon: const Icon(Icons.send, size: 30, color: Colors.white),
                          label: const Text('Send Respond', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 231, 185, 60),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          ),
                        ),
                      ],
                    ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
