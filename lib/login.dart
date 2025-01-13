import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';
import 'package:totp/dashboard.dart';
import 'package:totp/get_details.dart';

import 'api_call.dart';
import 'loading_handler.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController controller = TextEditingController();
  bool _obscureText = true; // add this line

  void _togglePasswordView() {
    // add this method
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.teal,
          onPressed: () async {
            LoadingHandler(context).loadingWidgetLight();
            log(jsonEncode({
              "mobileNo": GetDetails.number?.trim() ?? "",
              "pin": controller.text
            }));
            await ApiCall.request(
              path: "login",
              method: HttpMethod.post,
              body: {
                "mobileNo": GetDetails.number?.trim() ?? "",
                "pin": controller.text
              },
            ).then((value) {
              log(value);
              if (jsonDecode(value)["status"]) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Dashboard(
                      sessionId: jsonDecode(value)["data"]["sessionId"],
                    ),
                  ),
                  (route) => false,
                );
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
          },
          label: const Row(
            children: [
              Text(
                "Login",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                Icons.check,
                size: 20,
                color: Colors.white,
              ),
            ],
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text(
                  "Welcome to SIL 2FA Authenticator Login",
                  style: GoogleFonts.openSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.teal,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text("Mobile Number"),
                  Text(
                    maskMobileNumber(GetDetails.number ?? ""),
                    style: GoogleFonts.aBeeZee(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withOpacity(0.5),
                        letterSpacing: 2),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                obscureText: _obscureText, // use _obscureText
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Enter App PIN",
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Based on passwordVisible state choose the icon
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed:
                        _togglePasswordView, // Toggle the state of the password visible variable
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String maskMobileNumber(String number) {
    if (number.length <= 6) {
      return number;
    } else {
      return number.replaceRange(
        2,
        number.length - 2,
        '*' * (number.length - 4),
      );
    }
  }
}
