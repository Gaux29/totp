import 'dart:async';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'api_call.dart';
import 'get_details.dart';

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
    ApiCall.request(
      path: "generateotp",
      method: HttpMethod.post,
      body: {
        "mobileNo": GetDetails.number?.trim() ?? "",
        "sessionId": widget.sessionId
      },
    ).then((value) {
      update = DateTime.now();
      if (jsonDecode(value) != null && jsonDecode(value)['status']) {
        setState(() {
          account = Account.fromJson(jsonDecode(value)['data']);
          progressValue = 1.0;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    int counter = 0;
    generateOtp();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        progressValue -= 1 / 60;
      });

      counter++;
      if (counter % 60 == 0) {
        generateOtp();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

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
      body: Column(
        children: <Widget>[
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
                            horizontal: MediaQuery.of(context).size.width * 0.1,
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
