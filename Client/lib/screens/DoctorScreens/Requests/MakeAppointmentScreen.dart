import 'package:doctorgpt/screens/DoctorScreens/DoctorHomeScreen.dart';
import 'package:doctorgpt/services/booking_services.dart';
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
  List<String> _bookedTimeSlots = [];

  final BookingServices _bookingServices = BookingServices();

  @override
  void initState() {
    super.initState();
    _fetchBookedTimeSlots();
  }

  // Fetch booked time slots for the selected day
  Future<void> _fetchBookedTimeSlots() async {
    List<String> bookedTimeSlots = await _bookingServices.getBookedTimeSlots(
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
                      _fetchBookedTimeSlots(); // Fetch booked time slots for the selected day
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_today, size: 30,),
                        SizedBox(width: 5),
                        Text(
                          'Selected Date:',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 5),
                        Text(
                          '${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}',
                          style: TextStyle(
                            fontSize: 20,
                            color: _selectedTime == null ? Colors.red : Color.fromARGB(255, 31, 160, 119),
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.access_time, size: 30,),
                        SizedBox(width: 5),
                        Text(
                          _selectedTime ?? '-- : --',
                          style: TextStyle(
                            fontSize: 20,
                            color: _selectedTime == null ? Colors.red : Color.fromARGB(255, 31, 160, 119),
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
              children: _buildTimeButtons(_bookedTimeSlots), 
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
                onPressed: () async {
                  if (_selectedTime != null && _messageController.text.isNotEmpty) {
                    // Ellenőrizzük, hogy az adott időpontra már van-e foglalás
                    bool isAvailable = await _bookingServices.isAppointmentAvailable(
                      doctorId: widget.doctorId,
                      year: _selectedDay.year,
                      month: _selectedDay.month,
                      day: _selectedDay.day,
                      hourMinute: _selectedTime!,
                    );

                    if (isAvailable) {
                      // Ha elérhető az időpont, mentjük a foglalást
                      _bookingServices.saveAppointment(
                        doctorId: widget.doctorId,
                        patientId: widget.patientId,
                        year: _selectedDay.year,
                        month: _selectedDay.month,
                        day: _selectedDay.day,
                        hourMinute: _selectedTime!,
                        message: _messageController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Appointment saved successfully')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorHomeScreen()),
                      );
                    } else {
                      // Ha már foglalt az időpont, megjelenítünk egy üzenetet és nem engedjük a mentést
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('This time slot is already booked')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a time and enter a message')),
                    );
                  }
                },
                label: const Text('Send Appointment'),
                icon: const Icon(Icons.send,),
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
  // Build time buttons
List<Widget> _buildTimeButtons(List<String> bookedTimeSlots) {
  List<Widget> buttons = [];
  for (int hour = 8; hour <= 16; hour++) {
    for (int minute = 0; minute < 60; minute += 30) {
      String minuteString = minute.toString().padLeft(2, '0');
      String time = '$hour:$minuteString';
      bool isBooked = bookedTimeSlots.contains(time); // Check if time is in bookedTimeSlots

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
            primary: _selectedTime == time
                ? Color.fromARGB(255, 231, 145, 102) // Change color to orange if selected
                : isBooked
                    ? Colors.red // Change color to red if booked
                    : Color.fromARGB(255, 85, 194, 143), // Otherwise, keep it green
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Text(
            time,
            style: TextStyle(
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
