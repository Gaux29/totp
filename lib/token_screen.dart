import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'api_call.dart';
import 'get_details.dart';
import 'loading_handler.dart';
import 'login.dart';

class TokenScreen extends StatefulWidget {
  final String mobileNumber;
  final String firstName;
  final String lastName;
  final String appPin;
  const TokenScreen({
    super.key,
    required this.mobileNumber,
    required this.firstName,
    required this.lastName,
    required this.appPin,
  });

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController token = TextEditingController();

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
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Finally, enter your TOKEN. This is an additional security measure to verify your identity.",
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
                  controller: token,
                  validator: (value) {
                    // Add a validator to your TextFormField
                    if (value == null || value.isEmpty) {
                      return 'Please enter your token';
                    }
                    if (value.length < 5) {
                      return 'Token must be at least 5 characters long';
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
                    labelText: "TOKEN",

                    labelStyle: TextStyle(color: Colors.grey),
                    floatingLabelStyle: TextStyle(color: Colors.teal),
                  ),
                ),
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
                      LoadingHandler(context).loadingWidgetLight();
                      await ApiCall.request(
                        path: "registration",
                        method: HttpMethod.post,
                        body: {
                          "mobileNo": widget.mobileNumber,
                          "name":
                              "${widget.firstName.trim()} ${widget.lastName.trim()}",
                          "token": token.text,
                          "pin": widget.appPin,
                        },
                      ).then((value) async {
                        if (jsonDecode(value)["status"]) {
                          await GetDetails.storeData(
                            data: jsonEncode({
                              "mobileNo": widget.mobileNumber,
                              "name":
                                  "${widget.firstName.trim()} ${widget.lastName.trim()}",
                              "token": token.text,
                              "pin": widget.appPin,
                            }),
                          ).then((_) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                              (route) => false,
                            );
                          });
                        } else {
                          Navigator.pop(context);
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            text: jsonDecode(value)["message"],
                            borderRadius: 5,
                            confirmBtnColor: Colors.teal,
                          );
                        }
                      });
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
