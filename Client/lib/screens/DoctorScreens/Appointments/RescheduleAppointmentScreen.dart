import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorgpt/components/success_dialog.dart';
import 'package:doctorgpt/screens/DoctorScreens/DoctorHomeScreen.dart';
import 'package:doctorgpt/services/appointments_services.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  final String patientId;
  final String doctorId;
  final String oldAppointmentId;

  const RescheduleAppointmentScreen({
    Key? key,
    required this.patientId,
    required this.doctorId,
    required this.oldAppointmentId,
  }) : super(key: key);

  @override
  _RescheduleAppointmentScreenState createState() =>
      _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState
    extends State<RescheduleAppointmentScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _messageController = TextEditingController();
  String? _selectedTime;
  List<String> _bookedTimeSlots = [];

  final AppointmentServices _AppointmentServices = AppointmentServices();

  @override
  void initState() {
    super.initState();
    _fetchBookedTimeSlots();
  }

  // Fetch booked time slots for the selected day
  Future<void> _fetchBookedTimeSlots() async {
    List<String> bookedTimeSlots =
        await _AppointmentServices.getBookedTimeSlots(
      doctorId: widget.doctorId,
      year: _selectedDay.year,
      month: _selectedDay.month,
      day: _selectedDay.day,
    );
    setState(() {
      _bookedTimeSlots = bookedTimeSlots;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Appointment'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //calendar
            Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _selectedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _selectedTime =
                          null; // Reset selected time when day changes
                      _fetchBookedTimeSlots(); // Fetch booked time slots for the selected day
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            //selected date
            Card(
              margin: const EdgeInsets.all(5.0),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 30,
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Selected Date:',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}',
                          style: TextStyle(
                            fontSize: 20,
                            color: _selectedTime == null
                                ? Colors.red
                                : const Color.fromARGB(255, 31, 160, 119),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time,
                          size: 30,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _selectedTime ?? '-- : --',
                          style: TextStyle(
                            fontSize: 20,
                            color: _selectedTime == null
                                ? Colors.red
                                : const Color.fromARGB(255, 31, 160, 119),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            // select time
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _buildTimeButtons(_bookedTimeSlots),
            ),

            const SizedBox(height: 20),

            //message
            Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Message',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message here...',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            //send button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_selectedTime != null &&
                      _messageController.text.isNotEmpty) {
                    // Ellenőrizzük, hogy az adott időpontra már van-e foglalás
                    bool isAvailable =
                        await _AppointmentServices.isAppointmentAvailable(
                      doctorId: widget.doctorId,
                      year: _selectedDay.year,
                      month: _selectedDay.month,
                      day: _selectedDay.day,
                      hourMinute: _selectedTime!,
                    );

                    if (isAvailable) {
                      Timestamp sendTime = Timestamp.now();
                      // save rescheduled appointment
                      await _AppointmentServices.rescheduleAppointment(
                        doctorId: widget.doctorId,
                        patientId: widget.patientId,
                        oldAppointmentId: widget.oldAppointmentId,
                        oldYear: _selectedDay.year,
                        oldMonth: _selectedDay.month,
                        oldDay: _selectedDay.day,
                        oldHourMinute: _selectedTime!,
                        newYear: _selectedDay.year,
                        newMonth: _selectedDay.month,
                        newDay: _selectedDay.day,
                        newHourMinute: _selectedTime!,
                        message: _messageController.text,
                        sendTime: sendTime,
                      );
                      // success dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SuccessDialog(
                            message:
                                'Appointment rescheduled successfully!',
                            onPressed: () {
                              Navigator.pop(context); // Dialógus bezárása
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DoctorHomeScreen()),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      // if not available
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('This time slot is already booked')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please select a time and enter a message')),
                    );
                  }
                },
                label: const Text(
                  'Reschedule Appointment',
                  style: TextStyle(fontSize: 16),
                ),
                icon: const Icon(
                  Icons.send,
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 155, 138, 71),
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.all(15),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Build time buttons
  List<Widget> _buildTimeButtons(List<String> bookedTimeSlots) {
    List<Widget> buttons = [];
    for (int hour = 8; hour <= 16; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        String minuteString = minute.toString().padLeft(2, '0');
        String time = '$hour:$minuteString';
        bool isBooked = bookedTimeSlots
            .contains(time); // Check if time is in bookedTimeSlots

        buttons.add(
          ElevatedButton(
            onPressed: !isBooked
                ? () {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedTime == time
                  ? const Color.fromARGB(
                      255, 231, 145, 102) // Change color to orange if selected
                  : isBooked
                      ? Colors.red // Change color to red if booked
                      : const Color.fromARGB(
                          255, 85, 194, 143), // Otherwise, keep it green
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: Text(
              time,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    }
    return buttons;
  }
}
