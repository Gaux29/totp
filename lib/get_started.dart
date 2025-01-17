import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';
import 'package:totp/api_call.dart';
import 'package:totp/get_details.dart';
import 'package:totp/loading_handler.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  bool otp = false;
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController userId = TextEditingController();
  TextEditingController oneTimePassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 5)
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SafeArea(
                child: SizedBox(
                  height: 20,
                ),
              ),
              if (otp)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Enter OTP sent to ${maskMobileNumber(mobileNumber.text)}, to verify and continue.",
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      // fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
              if (otp)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // const Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 20),
                    //   child: Text("Enter OTP"),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: OtpTextField(
                        numberOfFields: 4,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                              4), // for limiting the length to 4 digits
                        ],
                        borderColor: Colors.teal,
                        showFieldAsBox: false,
                        onSubmit: (String verificationCode) {
                          setState(() {
                            oneTimePassword.text += verificationCode;
                          });
                          onTap();
                        }, // end onSubmit
                      ),
                    ),
                  ],
                ),
              if (!otp)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: userId,
                        validator: (value) {
                          // Add a validator
                          if (value == null || value.isEmpty) {
                            return 'User Id cannot be empty';
                          }
                          return null;
                        },
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(
                            18,
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
                          labelText: "User Id ",
                          labelStyle: TextStyle(color: Colors.grey),
                          floatingLabelStyle: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: mobileNumber,
                        validator: (value) {
                          // Add a validator
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 10) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            10,
                          ), // for limiting the length to 10 digits
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
                          labelText: "Mobile Number",
                          labelStyle: TextStyle(color: Colors.grey),
                          floatingLabelStyle: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    otp ? "Continue" : "Continue to OTP",
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'By continuing, you agree to our ',
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(color: Colors.teal),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(
                        text: ' and ',
                      ),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: const TextStyle(color: Colors.teal),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(
                        text: '.',
                      ),
                    ],
                    style: GoogleFonts.openSans(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Welcome to SIL 2FA Authenticator",
              style: GoogleFonts.openSans(
                fontSize: 28,
                fontWeight: FontWeight.w500,
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
              "Sign in to sync and backup your codes. This will ensure that your codes are safe and accessible across your devices.",
              style: GoogleFonts.openSans(
                fontSize: 16,
                // fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
          const Spacer(),
          const Spacer()
        ],
      ),
    );
  }

  // void onTap() async {
  //   if (_formKey.currentState!.validate()) {
  //     if (otp) {
  //
  //       LoadingHandler(context).loadingWidgetLight();
  //       ApiCall.request(
  //         path: "validateotp",
  //         method: HttpMethod.post,
  //         body: {"mobileNo": mobileNumber.text, "otp": oneTimePassword.text},
  //       ).then((value) async {
  //         if (jsonDecode(value)["status"]) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => GetDetails(
  //                 mobileNumber: mobileNumber.text,
  //               ),
  //             ),
  //           );
  //         } else {
  //           Navigator.pop(context);
  //           QuickAlert.show(
  //             context: context,
  //             type: QuickAlertType.error,
  //             text: jsonDecode(value)["message"],
  //             borderRadius: 5,
  //             confirmBtnColor: Colors.teal,
  //           );
  //         }
  //       });
  //     } else {
  //       FocusManager.instance.primaryFocus?.unfocus();
  //       FocusScope.of(context).requestFocus(FocusNode());
  //       FocusScope.of(context).unfocus();
  //       LoadingHandler(context).loadingWidgetLight();
  //       ApiCall.request(
  //         path: "sendOtp",
  //         method: HttpMethod.post,
  //         body: {"mobileNo": mobileNumber.text},
  //         // jsonParser: null
  //       ).then((valueOld) async {
  //         log(valueOld);
  //         if (jsonDecode(valueOld)["status"]) {
  //           await deviceInfo.androidInfo.then((value) {
  //             log(jsonEncode(value.data), name: "IMEI");
  //             // if (jsonDecode(valueOld)["data"]["imei"]) {
  //               Navigator.pop(context);
  //               setState(() {
  //                 otp = true;
  //               });
  //             // }
  //           });
  //         } else {
  //           Navigator.pop(context);
  //           QuickAlert.show(
  //             context: context,
  //             type: QuickAlertType.error,
  //             text: jsonDecode(valueOld)["message"],
  //             borderRadius: 5,
  //           );
  //         }
  //       });
  //     }
  //   }
  // }

  /// Triggered when the user taps on the primary button.
  void onTap() async {
    // Validate form (mobile number or OTP).
    if (_formKey.currentState!.validate()) {
      // Hide the keyboard.
      FocusManager.instance.primaryFocus?.unfocus();

      // Show loading overlay.
      LoadingHandler(context).loadingWidgetLight();

      // Determine which endpoint and request body to use.
      final path = otp ? "validateotp" : "sendOtp";
      final requestBody = otp
          ? {/*"userId": userId.text,*/"mobileNo": mobileNumber.text, "otp": oneTimePassword.text}
          // Here will be the user id in the input
          : {"mobileNo": mobileNumber.text};

      try {
        // Perform the API call.
        final responseValue = await ApiCall.request(
          path: path,
          method: HttpMethod.post,
          body: requestBody,
        );

        // Parse the response.
        final response = jsonDecode(responseValue);
        Navigator.pop(context); // Remove loading overlay

        // Debug: Print response to console.
        log('Response object: $response', name: 'GetStarted');

        // If status is true, proceed to next step.
        if (response["status"]) {
          log('Server returned status: true', name: 'GetStarted');

          if (otp) {
            // If we already were in OTP flow, it means the OTP is verified.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GetDetails(
                  mobileNumber: mobileNumber.text,
                  userId: userId.text,
                ),
              ),
            );
          } else {
            // We just sent the OTP; now we switch to the OTP input UI.
            try {
              // Attempt to get device info (optional).
              final androidInfo = await deviceInfo.androidInfo;
              log(jsonEncode(androidInfo.data), name: "IMEI");
            } catch (deviceError) {
              // If there's an error, just log it; we won't block the user.
              log('Error fetching device info: $deviceError',
                  name: 'GetStarted');
            }

            // Update the UI to show the OTP fields.
            setState(() {
              otp = true;
            });
          }
        } else {
          // The server responded with an error status.
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: response["message"],
            borderRadius: 5,
            confirmBtnColor: Colors.teal,
          );
        }
      } catch (e) {
        // Catch any network or parsing errors.
        Navigator.pop(context); // Remove loading overlay
        log('Exception in onTap: $e', name: 'GetStarted');

        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: otp
              ? 'Failed to validate OTP. Please try again.'
              : 'Failed to send OTP. Please try again.',
          borderRadius: 5,
          confirmBtnColor: Colors.teal,
        );
      }
    }
  }
}
