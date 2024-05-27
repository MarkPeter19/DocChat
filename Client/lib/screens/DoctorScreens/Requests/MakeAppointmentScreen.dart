import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:doctorgpt/services/booking_services.dart';

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
  late BookingServices bookingServices;
  String _message = '';
  DateTime _selectedDay = DateTime.now();
  late List<DateTime> _bookedTimes;
  DateTime? _selectedTime;
  bool _dateSelected = false;

  @override
  void initState() {
    super.initState();
    bookingServices = BookingServices();
    _bookedTimes = []; // Initialize booked times list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Appointment'),
      ),
      body: Column(
        children: [
          _tableCalendar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
            child: Center(
              child: Text(
                'Select Consultation Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          _dateSelected
              ? Expanded(child: _buildTimeSlots())
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 30,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Please select a date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
          const SizedBox(height: 20),
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    _message = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _selectedTime != null ? _uploadBooking : null,
            label: const Text('Send Appointment'),
            icon: const Icon(Icons.send),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 112, 60, 139),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  // Table calendar
  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _selectedDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2023, 12, 31),
      calendarFormat: CalendarFormat.month,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _dateSelected = true;
        });
      },
    );
  }

  // Build time slots
  Widget _buildTimeSlots() {
    final availableTimes = _generateAvailableTimes();

    return ListView.builder(
      itemCount: availableTimes.length,
      itemBuilder: (context, index) {
        final time = availableTimes[index];
        final isBooked = _bookedTimes.contains(time);
        final isSelected = _selectedTime == time;

        return InkWell(
          onTap: isBooked ? null : () => _selectTime(time),
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isBooked ? Colors.red : (isSelected ? Colors.yellow : Colors.green),
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              '${time.hour}:${time.minute}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBooked ? Colors.white : null,
              ),
            ),
          ),
        );
      },
    );
  }

  // Generate available times for selected day
  List<DateTime> _generateAvailableTimes() {
    // Example: Generating available times from 9 AM to 5 PM with 30 min interval
    final startTime = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 9);
    final endTime = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, 17);
    final List<DateTime> times = [];
    for (var time = startTime; time.isBefore(endTime); time = time.add(const Duration(minutes: 30))) {
      times.add(time);
    }
    return times;
  }

  // Select time slot
  void _selectTime(DateTime time) {
    setState(() {
      _selectedTime = time;
    });
  }

  // Upload booking
  Future<void> _uploadBooking() async {
    try {
      await bookingServices.uploadBooking(
        doctorId: widget.doctorId,
        patientId: widget.patientId,
        bookingStart: _selectedTime!,
        bookingEnd: _selectedTime!.add(const Duration(minutes: 30)),
        message: _message,
      );

      //Navigator.of(context).pushNamed('success_booking');
    } catch (e) {
      print('Error uploading booking: $e');
    }
  }
}
