import 'dart:io';
import 'package:caremate/components/my_elder.dart';
import 'package:caremate/components/my_textfield.dart';
import 'package:caremate/pages/health_report.dart';
import 'package:caremate/pages/scan_page.dart';
import 'package:caremate/pages/vidCall.dart';
import 'package:caremate/pages/voice_assistant_page.dart';
import 'package:caremate/services/ble_container.dart';
import 'package:caremate/services/colors.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:caremate/services/language_config.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class HomePage extends StatefulWidget {
  final bool connectionState;
  const HomePage({super.key, required this.connectionState});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var ageController = TextEditingController();
  var nameController = TextEditingController();
  var heightController = TextEditingController();
  var weightController = TextEditingController();
  File? profileController;
  LanguageConfig languageConfig = Get.find<LanguageConfig>();
  final ImagePicker picker = ImagePicker();
  String confirm = "X";
  List<String> elderNames = [];
  StreamController<List<String>> elderNameController = StreamController<List<String>>();

  // var currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {

    super.initState();
    // ListenVC();
    getElderNames();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ListenVC(); // Start listening for BLE connection after dependencies are resolved
  }

  void ListenVC() async{
    final bleContainer = Provider.of<BleContainer>(context, listen: true);
    print("Listening for BLE connections");
    if (widget.connectionState) {
      print("Connected device found");
        // final bleContainer = Provider.of<BleContainer>(context, listen: true);
        if (bleContainer.notifyCharacteristic != null) {
            await bleContainer.notifyCharacteristic!.setNotifyValue(true);
            bleContainer.notifyCharacteristic!.onValueReceived.listen((value) async{
              print("Main received: ${utf8.decode(value)}");
              if(utf8.decode(value) == "VC"){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideoCall(connectionState: widget.connectionState,)),
                );
                if (widget.connectionState) {
                  final bleContainer = Provider.of<BleContainer>(context, listen: false);
                  if (bleContainer.writeCharacteristic != null) {
                    await bleContainer.writeCharacteristic!.write(utf8.encode(confirm));
                    print("BLE message sent on page load");
                  } else {
                    print("BLE write characteristic is not available");
                  }
                } else {
                  print("BLE connection is not established");
                }
              }
              if(utf8.decode(value) == "EM"){
                emergencyNoti();
              }
              if(utf8.decode(value) == "H1"){
                hungryNoti();
              }
              if(utf8.decode(value) == "H2"){
                bathroomNoti();
              }
              if(utf8.decode(value) == "H3"){
                emergencyNoti();
              }
            });
        } else {
          print("BLE notify characteristic is not available");
        }
      } else {
        print("BLE connection is not established");
      }

  }

  void emergencyNoti()async{
    await AwesomeNotifications().createNotification(content:
    NotificationContent(id: 0, channelKey: "Emergency",
        title: "EMERGENCY BUTTON PRESSED!",
        body: "Please check on your loved one"
    )
    );
  }

  void hungryNoti()async{
    await AwesomeNotifications().createNotification(content:
    NotificationContent(id: 0, channelKey: "HandCMD",
        title: "Please check on your loved one",
        body: "Your loved one might be hungry"
    )
    );
  }

  void bathroomNoti()async{
    await AwesomeNotifications().createNotification(content:
    NotificationContent(id: 0, channelKey: "HandCMD",
        title: "Please check on your loved one",
        body: "Your loved one might need to use the bathroom"
    )
    );
  }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   ListenVC();
  // }

  void getElderNames() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final namesJson = prefs.getString("names");
    if (namesJson != null) {
      setState(() {
        elderNames = List<String>.from(jsonDecode(namesJson));
      });
      elderNameController.add(elderNames);
      print("Elder names: ${elderNames}");
    } else{
      print("namesJson is null");
    }
  }



  // disconnect device method
  void disconnectDevice() async {
    await context.read<BleContainer>().bluetoothDevice!.disconnect();
  }

  // show adding elder dialog
  void addElder() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Text(AppLocalizations.of(context)!.family_member,
                  style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
              content: StatefulBuilder(builder: (context, setState) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: 360,
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        // upload profile pic
                        GestureDetector(
                          onTap: () async {
                            final returnedImage = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);

                            if (returnedImage == null) return;

                            setState(() {
                              profileController = File(returnedImage.path);
                            });
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300]),
                            child: profileController != null
                                ? Image.file(profileController!)
                                : const Icon(Icons.image_search_rounded,
                                    size: 20),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // name textfield
                        MyTextField(
                            controller: nameController,
                            hintText: AppLocalizations.of(context)!.name,
                            prefixIcon: Icons.person_outline,
                            obscureText: false),

                        const SizedBox(height: 10),

                        // age textfield
                        MyTextField(
                            controller: ageController,
                            hintText: AppLocalizations.of(context)!.age,
                            prefixIcon: Icons.lock_clock_outlined,
                            obscureText: false,
                            keyboardType: TextInputType.number),

                        const SizedBox(height: 10),

                        // height textfield
                        MyTextField(
                            controller: heightController,
                            hintText: AppLocalizations.of(context)!.height,
                            prefixIcon: Icons.height,
                            obscureText: false,
                            keyboardType: TextInputType.number),

                        const SizedBox(height: 10),

                        // weight textfield
                        MyTextField(
                            controller: weightController,
                            hintText: AppLocalizations.of(context)!.weight,
                            prefixIcon: Icons.monitor_weight,
                            obscureText: false,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                );
              }),
              actions: [
                TextButton(
                    onPressed: () async {
                      //set elder
                      String info = '${ageController.text},${heightController.text},${weightController.text}';
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      elderNames.add(nameController.text);
                      prefs.setString("names", jsonEncode(elderNames));
                      prefs.setString(nameController.text, info);
                      elderNames.add(nameController.text);
                      nameController.clear();
                      ageController.clear();
                      heightController.clear();
                      weightController.clear();
                      profileController = null;
                      print("Elder has been set");
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.cancel,
                        style: GoogleFonts.sen(
                            fontWeight: FontWeight.bold,
                            color: ColorAsset.error))),
                TextButton(
                    onPressed: () async {
                      // show loading circle
                      showDialog(
                          context: context,
                          builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                  color: ColorAsset.primary)));

                      if (int.parse(ageController.text) > 100 ||
                          int.parse(heightController.text) > 250 ||
                          int.parse(weightController.text) > 200) {
                        return;
                      }


                      try {
                        // add elder
                        String info = '${ageController.text},${heightController.text},${weightController.text}';
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString(nameController.text, info);
                        elderNames.add(nameController.text);
                        prefs.setString("names", jsonEncode(elderNames));
                        print("Elder has been added");
                        print(elderNames);
                        nameController.clear();
                        ageController.clear();
                        heightController.clear();
                        weightController.clear();
                        profileController = null;

                        Navigator.pop(context);
                        Navigator.pop(context);
                      } catch (error) {
                        Navigator.pop(context);

                        nameController.clear();
                        ageController.clear();
                        heightController.clear();
                        weightController.clear();
                        profileController = null;

                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text("Error",
                                      style: GoogleFonts.sen(
                                          fontWeight: FontWeight.bold,
                                          color: ColorAsset.error)),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("OK",
                                            style: GoogleFonts.sen(
                                                fontWeight: FontWeight.bold,
                                                color: ColorAsset.primary)))
                                  ],
                                ));
                      }
                    },
                    child: Text("OK",
                        style: GoogleFonts.sen(
                            fontWeight: FontWeight.bold,
                            color: ColorAsset.primary)))
              ],
            ));
  }

  // show editing elder dialog
   editElder(var elder) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? elderInfo = prefs.getString(elder);
    print("Info: ${elderInfo}");
    var imageUrl = null;
    if(elderInfo != null){
      List infoList = elderInfo.split(",");
      for(int i = 0; i < infoList.length; i++){
        nameController.text = elder;
        ageController.text = infoList[0];
        heightController.text = infoList[1];
        weightController.text = infoList[2];
      }
    } else{
      return CircularProgressIndicator();
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Edit Your Loved One",
                  style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
              content: StatefulBuilder(builder: (context, setState) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: 360,
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        // upload profile pic
                        GestureDetector(
                          onTap: () async {
                            final returnedImage = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);

                            if (returnedImage == null) return;
                            if(imageUrl == null) return;

                            setState(() {
                              imageUrl = File(returnedImage.path);
                            });
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                                image: DecorationImage(
                                    image: imageUrl is File
                                        ? FileImage(imageUrl) as ImageProvider
                                        : AssetImage("assets/old-man.png"),
                                    fit: BoxFit.cover)),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // name textfield
                        MyTextField(
                            controller: nameController,
                            hintText: "Name",
                            prefixIcon: Icons.person_outline,
                            obscureText: false),

                        const SizedBox(height: 10),

                        // age textfield
                        MyTextField(
                            controller: ageController,
                            hintText: "Age",
                            prefixIcon: Icons.lock_clock_outlined,
                            obscureText: false,
                            keyboardType: TextInputType.number),

                        const SizedBox(height: 10),

                        // height textfield
                        MyTextField(
                            controller: heightController,
                            hintText: "Height",
                            prefixIcon: Icons.height,
                            obscureText: false,
                            keyboardType: TextInputType.number),

                        const SizedBox(height: 10),

                        // weight textfield
                        MyTextField(
                            controller: weightController,
                            hintText: "Weight",
                            prefixIcon: Icons.monitor_weight,
                            obscureText: false,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                );
              }),
              actions: [
                TextButton(
                    onPressed: () async {
                      // delete elder
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.remove(nameController.text);
                      elderNames.remove(nameController.text);
                      prefs.setString("names", jsonEncode(elderNames));
                      print("Shared preferences set");
                      nameController.clear();
                      ageController.clear();
                      heightController.clear();
                      weightController.clear();
                      // imageUrl = null;

                      Navigator.pop(context);
                    },
                    child: Text("DELETE",
                        style: GoogleFonts.sen(
                            fontWeight: FontWeight.bold,
                            color: ColorAsset.error))),
                TextButton(
                    onPressed: () async {
                      // show loading circle
                      showDialog(
                          context: context,
                          builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                  color: ColorAsset.primary)));

                      if (int.parse(ageController.text) > 100 ||
                          int.parse(heightController.text) > 250 ||
                          int.parse(weightController.text) > 200) {
                        return;
                      }

                      if (imageUrl is File) {
                        // String fileName =
                        //     DateTime.now().microsecondsSinceEpoch.toString();
                        //
                        // Reference referenceRoot =
                        //     FirebaseStorage.instance.ref();
                        // Reference referenceDireImages =
                        //     referenceRoot.child("profiles");
                        //
                        // Reference referenceImageToUpload =
                        //     referenceDireImages.child(fileName);
                        //
                        // await referenceImageToUpload
                        //     .putFile(File(imageUrl!.path));
                        //
                        // imageUrl =
                        //     await referenceImageToUpload.getDownloadURL();
                        try {
                          // edit elder


                          nameController.clear();
                          ageController.clear();
                          heightController.clear();
                          weightController.clear();
                          profileController = null;

                          Navigator.pop(context);
                          Navigator.pop(context);
                        } catch (error) {
                          Navigator.pop(context);

                          nameController.clear();
                          ageController.clear();
                          heightController.clear();
                          weightController.clear();
                          profileController = null;

                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.error,
                                        style: GoogleFonts.sen(
                                            fontWeight: FontWeight.bold,
                                            color: ColorAsset.error)),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("OK",
                                              style: GoogleFonts.sen(
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorAsset.primary)))
                                    ],
                                  ));
                        }
                      } else {
                        try {
                          // edit elder
                          // await FirebaseFirestore.instance
                          //     .collection("Users")
                          //     .doc(currentUser!.email)
                          //     .collection("Elders")
                          //     .doc(elder.id)
                          //     .update({
                          //   "Name": nameController.text,
                          //   "Age": ageController.text,
                          //   "Height": heightController.text,
                          //   "Weight": weightController.text,
                          // });

                          nameController.clear();
                          ageController.clear();
                          heightController.clear();
                          weightController.clear();
                          profileController = null;

                          Navigator.pop(context);
                          Navigator.pop(context);
                        } catch (error) {
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.error,
                                        style: GoogleFonts.sen(
                                            fontWeight: FontWeight.bold,
                                            color: ColorAsset.error)),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("OK",
                                              style: GoogleFonts.sen(
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorAsset.primary)))
                                    ],
                                  ));
                        }
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.edit,
                        style: GoogleFonts.sen(
                            fontWeight: FontWeight.bold,
                            color: ColorAsset.primary)))
              ],
            ));
  }

  // void _changeLanguage(Locale locale) {
  //   setState(() {
  //     _appLocale = locale;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.home,
            style: GoogleFonts.sen(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            icon: Icon(Icons.menu, color: Colors.white,),
              onSelected: (value) async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if(value == 'logout'){
                  // await FirebaseAuth.instance.signOut();
                }
                if(value == 'chinese'){
                  await prefs.setString('language', 'zh');
                  print('Chinese selected');
                }
                if(value == 'english'){
                  await prefs.setString('language', 'en');
                  print("English selected");
                }
              },
              itemBuilder: (context) => [
           PopupMenuItem(
               value: 'logout',
               child: Row(
             children: [
               Icon(Icons.logout),
               Text(AppLocalizations.of(context)!.logout),
             ],
           )),
            PopupMenuItem(
                value : 'chinese',
                child: Text("中文")),

           PopupMenuItem(
                value: 'english',
                child: Text('English'))
          ]),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              // main menu
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // welcome section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // logo
                        Image.asset("assets/logo2.png", width: 103, height: 79),

                        const SizedBox(width: 10),

                        // welcome back + username
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 170,
                              child: Text(AppLocalizations.of(context)!.welcome,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.sen(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600)),
                            ),
                            SizedBox(
                              width: 170,
                              child: Text("Admin",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.sen(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 0.6)),
                            )
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Divider(),

                    const SizedBox(height: 20),

                    // elders list
                    Text(AppLocalizations.of(context)!.under_care,
                        style: GoogleFonts.sen(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1)),

                    const SizedBox(height: 10),

                    // elders pfp
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            height: 150,
                            width: 200,
                            child: StreamBuilder<List<String>>(
                                stream: elderNameController.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index){
                                        final String item = snapshot.data![index];
                                        return Padding(
                                          padding: EdgeInsets.fromLTRB(10,0,10,0),
                                          child: GestureDetector(
                                            onTap: (){
                                              editElder(item);
                                            },
                                            child: Container(
                                                color: Color(0xfff8f8f8),
                                                width: 97,
                                                height: 150,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:  EdgeInsets.only(top: 20),
                                                      child: Container(
                                                        width: 71,
                                                        height: 71,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Image.asset("assets/old-man.png"),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 20),
                                                      child: Text(item,
                                                      style: GoogleFonts.sen(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black)
                                                      ),
                                                    )
                                                  ],
                                                ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    return SizedBox();
                                  }
                                }),
                          ),

                          // add elder
                          GestureDetector(
                            onTap: addElder,
                            child: Container(
                              width: 97,
                              height: 150,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: const BoxDecoration(
                                  color: Color(0xfff8f8f8),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // profile
                                  const SizedBox(
                                    width: 71,
                                    height: 71,
                                    child: Icon(Icons.add_circle_outline,
                                        size: 71, color: ColorAsset.primary),
                                  ),

                                  // name
                                  SizedBox(
                                      width: 120,
                                      height: 30,
                                      child: Text(AppLocalizations.of(context)!.add,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.sen(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: ColorAsset.primary)))
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // connection state
              widget.connectionState == true
                  ? Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // bluetooth icon
                          const Icon(Icons.bluetooth,
                              size: 60, color: ColorAsset.primary),

                          // device status + connect button
                          Column(children: [
                            // connection state
                            Row(
                              children: [
                                Text(AppLocalizations.of(context)!.connection_status,
                                    style: GoogleFonts.sen(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text("Connected",
                                    style: GoogleFonts.sen(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),

                            const SizedBox(height: 5),

                            // Disconnect device
                            GestureDetector(
                              onTap: disconnectDevice,
                              child: Container(
                                width: 230,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: ColorAsset.secondary,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // add icon
                                    const Icon(Icons.check_circle_outline,
                                        size: 20, color: Colors.white),

                                    const SizedBox(width: 5),

                                    // text
                                    Text(AppLocalizations.of(context)!.connection_status,
                                        style: GoogleFonts.sen(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            )
                          ])
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // bluetooth icon
                          const Icon(Icons.bluetooth_disabled,
                              size: 60, color: ColorAsset.error),

                          // device status + connect button
                          Column(children: [
                            // connection state
                            Row(
                              children: [
                                Text("${
                                  AppLocalizations.of(context)!
                                      .connection_status
                                } : ",
                                    style: GoogleFonts.sen(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text(AppLocalizations.of(context)!.disconnected,
                                    style: GoogleFonts.sen(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold))
                              ],
                            ),

                            const SizedBox(height: 5),

                            // connect device
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ScanPage()));
                              },
                              child: Container(
                                width: 230,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: ColorAsset.secondary,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // add icon
                                    const Icon(Icons.add_circle_outline,
                                        size: 20, color: Colors.white),

                                    const SizedBox(width: 5),

                                    // text
                                    Text(AppLocalizations.of(context)!.connect_device,
                                        style: GoogleFonts.sen(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            )
                          ])
                        ],
                      ),
                    ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HealthPage()),
                    );
                  },
                  child: Container(
                    width: 350,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.health_report,
                        style: GoogleFonts.sen(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            )
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
