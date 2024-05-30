import 'dart:io';
import 'package:caremate/components/my_elder.dart';
import 'package:caremate/components/my_textfield.dart';
import 'package:caremate/services/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var ageController = TextEditingController();
  var nameController = TextEditingController();
  var heightController = TextEditingController();
  var weightController = TextEditingController();
  File? profileController;

  var currentUser = FirebaseAuth.instance.currentUser;

  // show adding elder dialog
  void addElder() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Add Your Loved One",
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
                    onPressed: () {
                      nameController.clear();
                      ageController.clear();
                      heightController.clear();
                      weightController.clear();
                      profileController = null;

                      Navigator.pop(context);
                    },
                    child: Text("Cancel",
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

                      String fileName =
                          DateTime.now().microsecondsSinceEpoch.toString();

                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDireImages =
                          referenceRoot.child("profiles");

                      Reference referenceImageToUpload =
                          referenceDireImages.child(fileName);

                      await referenceImageToUpload
                          .putFile(File(profileController!.path));

                      var imageUrl =
                          await referenceImageToUpload.getDownloadURL();

                      try {
                        // add elder
                        await FirebaseFirestore.instance
                            .collection("Users")
                            .doc(currentUser!.email)
                            .collection("Elders")
                            .doc()
                            .set({
                          "Name": nameController.text,
                          "Age": ageController.text,
                          "Height": heightController.text,
                          "Weight": weightController.text,
                          "Profile": imageUrl
                        });
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
  void editElder(var elder) {
    nameController.text = elder["Name"];
    ageController.text = elder["Age"];
    heightController.text = elder["Height"];
    weightController.text = elder["Weight"];
    var imageUrl = elder["Profile"];
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
                                        : NetworkImage(imageUrl),
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
                      await FirebaseFirestore.instance
                          .collection("Users")
                          .doc(currentUser!.email)
                          .collection("Elders")
                          .doc(elder.id)
                          .delete();

                      nameController.clear();
                      ageController.clear();
                      heightController.clear();
                      weightController.clear();
                      imageUrl = null;

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
                        String fileName =
                            DateTime.now().microsecondsSinceEpoch.toString();

                        Reference referenceRoot =
                            FirebaseStorage.instance.ref();
                        Reference referenceDireImages =
                            referenceRoot.child("profiles");

                        Reference referenceImageToUpload =
                            referenceDireImages.child(fileName);

                        await referenceImageToUpload
                            .putFile(File(imageUrl!.path));

                        imageUrl =
                            await referenceImageToUpload.getDownloadURL();
                        try {
                          // edit elder
                          await FirebaseFirestore.instance
                              .collection("Users")
                              .doc(currentUser!.email)
                              .collection("Elders")
                              .doc(elder.id)
                              .update({
                            "Name": nameController.text,
                            "Age": ageController.text,
                            "Height": heightController.text,
                            "Weight": weightController.text,
                            "Profile": imageUrl
                          });
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
                      } else {
                        try {
                          // edit elder
                          await FirebaseFirestore.instance
                              .collection("Users")
                              .doc(currentUser!.email)
                              .collection("Elders")
                              .doc(elder.id)
                              .update({
                            "Name": nameController.text,
                            "Age": ageController.text,
                            "Height": heightController.text,
                            "Weight": weightController.text,
                          });
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
                      }
                    },
                    child: Text("EDIT",
                        style: GoogleFonts.sen(
                            fontWeight: FontWeight.bold,
                            color: ColorAsset.primary)))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Home",
            style: GoogleFonts.sen(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        actions: [
          IconButton(
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) => const Center(
                        child: CircularProgressIndicator(
                            color: ColorAsset.primary)));
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout, color: Colors.white))
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
                              child: Text("Welcome Back!",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.sen(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600)),
                            ),
                            SizedBox(
                              width: 170,
                              child: Text(currentUser!.email!.split("@")[0],
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
                    Text("These are the loved ones under CareMate's care!",
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
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("Users")
                                    .doc(currentUser!.email)
                                    .collection("Elders")
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          final elder =
                                              snapshot.data!.docs[index];

                                          return GestureDetector(
                                            onTap: () {
                                              editElder(elder);
                                            },
                                            child: MyElder(
                                                elderName: elder["Name"],
                                                elderProfile: elder["Profile"]),
                                          );
                                        });
                                  } else if (snapshot.hasError) {
                                    return Text("Error : ${snapshot.error}");
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator(
                                            color: ColorAsset.primary));
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
                                      child: Text("Add",
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
              Container(
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
                          Text("Connection State : ",
                              style: GoogleFonts.sen(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Connected",
                              style: GoogleFonts.sen(
                                  fontSize: 16, fontWeight: FontWeight.bold))
                        ],
                      ),

                      const SizedBox(height: 5),

                      // connect device
                      Container(
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
                            Text("Connect Device",
                                style: GoogleFonts.sen(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                      )
                    ])
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
