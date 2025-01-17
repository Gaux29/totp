import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:totp/get_details.dart';

import 'api_call.dart';

class Dashboard extends StatefulWidget {
  final String sessionId;

  const Dashboard({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  late Timer _timer;
  double progressValue = 1;
  Account? account;
  DateTime? update;

  void generateOtp() {
    print("USER ID: ${jsonDecode(GetDetails.user ?? "")?["userId"]}");
/*    ApiCall.request(
      path: "generateToken",
      method: HttpMethod.post,
      body: {
        // "mobileNo": GetDetails.number?.trim() ?? "",
        // "sessionId": widget.sessionId,
        "userId": GetDetails.user ?? "SONAL416",
      },
    ).then(value){
      print(value);
    };*/
    ApiCall.request(
      path: "generateotp",
      method: HttpMethod.post,
      body: {
        // "mobileNo": GetDetails.number?.trim() ?? "",
        // "sessionId": widget.sessionId,
        "userId": jsonDecode(GetDetails.user ?? "")?["userId"],
        "token": dashboardToken.text,
      },
    ).then((value) {
      update = DateTime.now();
      print("Json Data: ${jsonDecode(value)}");
      if (jsonDecode(value) != null && jsonDecode(value)['status']) {
        setState(() {
          account = Account.fromJson(jsonDecode(value)['data']);
          progressValue = 1.0;
          int counter = 0;
// Setting Timer when success message will be removed as per the requirements
          _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
            setState(() {
              progressValue -= 1 / 60;
            });

            counter++;
            if (counter % 60 == 0) {
              generateOtp();
            }
          });
        });
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: jsonDecode(value)['message'],
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  TextEditingController dashboardToken = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SIL 2FA Authenticator',
          style:
              GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: dashboardToken,
                    validator: (value) {
                      // Add a validator
                      if (value == null || value.isEmpty) {
                        return 'Token cannot be empty';
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
                      labelText: "Enter Token ",
                      labelStyle: TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                generateOtp();
              },
              child: Text("Submit"),
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.teal),
            ),
            if (account != null)
              Card(
                elevation: 5,
                shadowColor: Colors.teal.withOpacity(0.1),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: "Name: ",
                                style: GoogleFonts.openSans(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                              TextSpan(
                                text: account!.name.toUpperCase(),
                                style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: "Mobile: ",
                                style: GoogleFonts.openSans(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                              TextSpan(
                                text: account!.number,
                                style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.1,
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CircularProgressIndicator(
                                value: progressValue,
                                backgroundColor: Colors.white,
                                strokeWidth: 10,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "OTP",
                                style: GoogleFonts.openSans(
                                  fontSize: 20.0,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                account!.otp,
                                style: GoogleFonts.openSans(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          "Last Updated:",
                          style: GoogleFonts.openSans(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          DateFormat.yMMMd().add_jm().format(
                                update ?? DateTime.now(),
                              ), // change the format as per your requirement
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Account {
  String name;
  String number;
  String otp;

  Account({required this.name, required this.number, required this.otp});

  Account.fromJson(
    Map<String, dynamic> json,
  )   : name = json['name'],
        number = json['mobileNo'],
        otp = json['otp'];
}
