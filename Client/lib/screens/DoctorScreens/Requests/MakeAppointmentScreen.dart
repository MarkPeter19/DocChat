import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MakeAppointmentScreen extends StatefulWidget {
  final String patientId;
  final String doctorId;

  const MakeAppointmentScreen({
    Key? key,
    required this.patientId,
    required this.doctorId,
  }) : super(key: key);

  @override
  State<MakeAppointmentScreen> createState() => _MakeAppointmentScreenState();
}

class _MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  TextEditingController _messageController = TextEditingController();
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Appointment'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //calendar
            Card(
              margin: EdgeInsets.all(8.0),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(Duration(days: 365)),
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
                      _selectedTime = null; // Reset selected time when day changes
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            //selected date
            Card(
              margin: EdgeInsets.all(5.0),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 5),
                        Text(
                          'Selected Date:',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 5),
                        Text(
                          '${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}',
                          style: TextStyle(
                            fontSize: 20,
                            color: _selectedTime == null ? Colors.red : Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.access_time),
                        SizedBox(width: 5),
                        Text(
                          _selectedTime ?? '-- : --',
                          style: TextStyle(
                            fontSize: 20,
                            color: _selectedTime == null ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),

            // select time
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _buildTimeButtons(),
            ),
            SizedBox(height: 20),

            //message
            Card(
              margin: EdgeInsets.all(8.0),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        border: OutlineInputBorder(),
                        hintMaxLines: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            //send button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () => {},
                label: const Text('Send Appointment'),
                icon: const Icon(Icons.send),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 112, 60, 139),
                  minimumSize: const Size(double.infinity, 50),
                  padding: EdgeInsets.all(15),
                ),
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  // Build time buttons
  List<Widget> _buildTimeButtons() {
    List<Widget> buttons = [];
    for (int hour = 8; hour <= 16; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        String time = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        buttons.add(
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedTime = time;
              });
            },
            style: ElevatedButton.styleFrom(
              primary: _selectedTime == time ? Colors.green : Colors.grey[300],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: _selectedTime == time ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }
    }
    return buttons;
  }
}
