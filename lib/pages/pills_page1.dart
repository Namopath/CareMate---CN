import 'package:caremate/components/my_pill.dart';
import 'package:caremate/components/my_textfield.dart';
import 'package:caremate/services/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

class PillsPage extends StatefulWidget {
  const PillsPage({super.key});

  @override
  State<PillsPage> createState() => _PillsPageState();
}

class _PillsPageState extends State<PillsPage> {
  // variable
  var pillController = TextEditingController();

  // initially set date to present day
  DateTime today = DateTime.now();

  // current user
  var currentUser = FirebaseAuth.instance.currentUser;

  String formattedDate = DateFormat("yyyy:MM:dd").format(DateTime.now());

  void managePill(String dateTime, String pill) async {
    TimeOfDay? selectedTime = TimeOfDay.now();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Manage Pill",
                  style: GoogleFonts.sen(
                    fontWeight: FontWeight.bold,
                  )),
              content: StatefulBuilder(builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // pill name textfield
                      MyTextField(
                          controller: pillController,
                          hintText: "Pill name",
                          prefixIcon: Icons.medical_services_outlined,
                          obscureText: false),

                      const SizedBox(height: 20),

                      // time picker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // time
                          SizedBox(
                            width: 110,
                            child: Text(
                                "${selectedTime!.hour} : ${selectedTime!.minute} ${selectedTime!.period.name}",
                                style: GoogleFonts.sen(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ),

                          // set time button
                          SizedBox(
                            width: 110,
                            child: TextButton(
                                onPressed: () async {
                                  var setTime = await showTimePicker(
                                      context: context,
                                      initialTime: selectedTime!,
                                      initialEntryMode:
                                          TimePickerEntryMode.dial);
                                  if (setTime != null) {
                                    setState(() {
                                      selectedTime = setTime;
                                    });
                                  }
                                },
                                child: Text("Set Time",
                                    style: GoogleFonts.sen(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: ColorAsset.primary))),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel",
                        style: GoogleFonts.sen(
                            fontWeight: FontWeight.bold,
                            color: ColorAsset.error))),
                TextButton(
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                  color: ColorAsset.primary)));
                      await FirebaseFirestore.instance
                          .collection("Users")
                          .doc(currentUser!.email)
                          .collection("Pills")
                          .doc(dateTime)
                          .update({
                        "${pill}_Name": pillController.text,
                        "${pill}_Hour": selectedTime!.hour,
                        "${pill}_Minute":
                            selectedTime!.minute.toString().length == 1
                                ? "0${selectedTime!.minute}"
                                : selectedTime!.minute,
                        "${pill}_Period": selectedTime!.period.name,
                      });
                      pillController.clear();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text("OK",
                        style: GoogleFonts.sen(
                            fontWeight: FontWeight.bold,
                            color: ColorAsset.primary))),
              ],
            ));
  }

  void deletePill(String dateTime, String pill) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete Pill",
                  style: GoogleFonts.sen(
                    fontWeight: FontWeight.bold,
                  )),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel",
                        style: GoogleFonts.sen(
                            fontWeight: FontWeight.bold, color: Colors.black))),
                TextButton(
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                  color: ColorAsset.primary)));
                      await FirebaseFirestore.instance
                          .collection("Users")
                          .doc(currentUser!.email)
                          .collection("Pills")
                          .doc(dateTime)
                          .update({
                        "${pill}_Name": "",
                        "${pill}_Hour": "",
                        "${pill}_Minute": "",
                        "${pill}_Period": "",
                      });

                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text("DELETE",
                        style: GoogleFonts.sen(
                            fontWeight: FontWeight.bold,
                            color: ColorAsset.error))),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text("Pills Management",
            style: GoogleFonts.sen(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              // calendar
              Container(
                padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: TableCalendar<Event>(
                  headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.sen(
                        fontWeight: FontWeight.bold,
                      )),
                  availableGestures: AvailableGestures.all,
                  selectedDayPredicate: (day) => isSameDay(day, today),
                  onDaySelected: (selectedDay, focusedDay) async {
                    setState(
                      () {
                        formattedDate =
                            DateFormat("yyyy:MM:dd").format(selectedDay);
                        today = selectedDay;
                      },
                    );
                    var pillDoc = FirebaseFirestore.instance
                        .collection("Users")
                        .doc(currentUser!.email)
                        .collection("Pills")
                        .doc(formattedDate);

                    var pillDocStatus = await pillDoc.get();
                    if (!pillDocStatus.exists) {
                      await pillDoc.set({
                        "Pill01_Name": "",
                        "Pill01_Hour": "",
                        "Pill01_Minute": "",
                        "Pill01_Period": "",
                        "Pill02_Name": "",
                        "Pill02_Hour": "",
                        "Pill02_Minute": "",
                        "Pill02_Period": "",
                        "Pill03_Name": "",
                        "Pill03_Hour": "",
                        "Pill03_Minute": "",
                        "Pill03_Period": "",
                      });
                    }
                  },
                  focusedDay: today,
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                ),
              ),

              const SizedBox(height: 20),

              // pills
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Users")
                        .doc(currentUser!.email)
                        .collection("Pills")
                        .doc(formattedDate)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var pills = snapshot.data!;
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                pills["Pill01_Name"] != ""
                                    ? deletePill(formattedDate, "Pill01")
                                    : managePill(formattedDate, "Pill01");
                              },
                              child: MyPill(
                                pillName: pills["Pill01_Name"] != ""
                                    ? pills["Pill01_Name"]
                                    : "No Data Yet",
                                time: pills["Pill01_Hour"] != ""
                                    ? "${pills["Pill01_Hour"]}:${pills["Pill01_Minute"]}"
                                    : "----",
                                timeIndicator: pills["Pill01_Period"] != ""
                                    ? pills["Pill01_Period"] == "pm"
                                        ? "p.m."
                                        : "a.m."
                                    : "----",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                pills["Pill02_Name"] != ""
                                    ? deletePill(formattedDate, "Pill02")
                                    : managePill(formattedDate, "Pill02");
                              },
                              child: MyPill(
                                pillName: pills["Pill02_Name"] != ""
                                    ? pills["Pill02_Name"]
                                    : "No Data Yet",
                                time: pills["Pill02_Hour"] != ""
                                    ? "${pills["Pill02_Hour"]}:${pills["Pill02_Minute"]}"
                                    : "----",
                                timeIndicator: pills["Pill02_Period"] != ""
                                    ? pills["Pill02_Period"] == "pm"
                                        ? "p.m."
                                        : "a.m."
                                    : "----",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                pills["Pill03_Name"] != ""
                                    ? deletePill(formattedDate, "Pill03")
                                    : managePill(formattedDate, "Pill03");
                              },
                              child: MyPill(
                                pillName: pills["Pill03_Name"] != ""
                                    ? pills["Pill03_Name"]
                                    : "No Data Yet",
                                time: pills["Pill03_Hour"] != ""
                                    ? "${pills["Pill03_Hour"]}:${pills["Pill03_Minute"]}"
                                    : "----",
                                timeIndicator: pills["Pill03_Period"] != ""
                                    ? pills["Pill03_Period"] == "pm"
                                        ? "p.m."
                                        : "a.m."
                                    : "----",
                              ),
                            )
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: ColorAsset.primary));
                      } else {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: ColorAsset.primary));
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
