import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickalert/quickalert.dart';
import 'package:totp/token_screen.dart';

import 'api_call.dart';

class GetDetails extends StatefulWidget {
  final String mobileNumber;
  const GetDetails({super.key, required this.mobileNumber});

  static final Box<String> account = Hive.box("map");

  static get initHive async {
    await Hive.initFlutter();
    await Hive.openBox<String>("map");
  }

  static Future<void> storeData({required String data}) async {
    await account.put("user", data);
  }

  static String? get user => account.get("user");

  static bool get exist => account.isNotEmpty;

  static String? get number => jsonDecode(user ?? "")?["mobileNo"];

  @override
  State<GetDetails> createState() => _GetDetailsState();
}

class _GetDetailsState extends State<GetDetails> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();

  TextEditingController appPin = TextEditingController();
  TextEditingController confirmAppPin = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? pinValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your App PIN';
    } else if (value.length != 4) {
      return 'App PIN must be 4 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    "Welcome to SIL 2FA Authenticator",
                    style: GoogleFonts.openSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Please enter your first and last name. This will help us personalize your experience.",
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  controller: firstName,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]+"))
                  ],
                  validator: (value) {
                    // Add a validator to your TextFormField
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    if (value.length < 2) {
                      return 'First name must be at least 2 characters long';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.teal,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.teal,
                      ),
                    ),
                    // label: Text("CUSTOMER ID",style: TextStyle(color: Colors.grey),),
                    labelText: "First Name",
                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s'-]+"))
                  ],
                  validator: (value) {
                    // Add a validator to your TextFormField
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    if (value.length < 2) {
                      return 'Last name must be at least 2 characters long';
                    }
                    return null;
                  },
                  controller: lastName,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.teal,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.teal,
                      ),
                    ),
                    // label: Text("CUSTOMER ID",style: TextStyle(color: Colors.grey),),
                    labelText: "Last Name",
                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Next, create an App PIN. This will be used to secure your account.",
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  validator: pinValidator,
                  controller: appPin,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      4,
                    ),
                  ],
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.teal,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.teal,
                      ),
                    ),
                    // label: Text("CUSTOMER ID",style: TextStyle(color: Colors.grey),),
                    labelText: "App PIN",
                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  validator: pinValidator,
                  keyboardType: TextInputType.number,
                  controller: confirmAppPin,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      4,
                    ),
                  ],
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.teal,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.teal,
                      ),
                    ),
                    // label: Text("CUSTOMER ID",style: TextStyle(color: Colors.grey),),
                    labelText: "Confirm App PIN",
                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ElevatedButton(
                  // onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (appPin.text == confirmAppPin.text) {
                        // ============================================
                        // Request for gettoken
                        final tokenResponse = await ApiCall.request(
                          path: "gettoken",
                          method: HttpMethod.post,
                          body: {
                            "mobileNo": widget.mobileNumber,
                            "name":
                                "${firstName.text.trim()} ${lastName.text.trim()}",
                            // "otp": oneTimePassword.text
                          },
                        );
                        print("Token Response: ${jsonDecode(tokenResponse)}");
                        // =================================================
                        if (jsonDecode(tokenResponse)["status"] ?? false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TokenScreen(
                                mobileNumber: widget.mobileNumber,
                                firstName: firstName.text,
                                lastName: lastName.text,
                                appPin: appPin.text,
                              ),
                            ),
                          );
                        }
                      } else {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          text: "App Pin & Confirm App Pin should be same.",
                          borderRadius: 5,
                          confirmBtnColor: Colors.teal,
                        );
                      }
                    }
                  },
                  child: Text(
                    "Continue",
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
