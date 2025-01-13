import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// Replace this import with the correct path to your GetStarted screen.
// For example: import 'package:totp/get_started.dart';
import 'package:totp/get_started.dart';

class Sliders extends StatefulWidget {
  const Sliders({super.key});

  @override
  State<Sliders> createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea prevents overlap with iOS notches, etc.
      body: SafeArea(
        child: Column(
          children: [
            // Expanded widget so the PageView takes remaining space
            Expanded(
              flex: 8,
              child: PageView(
                controller: _pageController,
                children: const [
                  SlideItem(
                    title: "Embrace the Power of 2FA",
                    subTitle:
                        "Two-Factor Authentication, or 2FA, is like a unique shield for your account. Besides your usual username and password, it adds a second level of verification—a code generated via an app on your mobile device.\n\nThis extra layer means even if someone cracks your password, they can't unlock your account without the unique verification code.",
                  ),
                  SlideItem(
                    title: "The Advantages of 2FA",
                    subTitle:
                        "With 2FA at the helm, you're navigating the digital world with enhanced security. Even if your password falls into the wrong hands, they won't be able to unlock your account without the unique code generator in your possession. This significantly minimizes threats and unauthorized access, reinforcing your account's protection.",
                  ),
                  SlideItem(
                    title: "2FA and Your Banking Experience",
                    subTitle:
                        "Our 2FA OTP App takes your banking experience to an unparalleled level of security. By generating a unique, time-sensitive code for each of your transactions, it effectively replaces traditional OTPs received via SMS. This makes your transactions quicker, seamless, and above all, more secure as the code is only available to you.\n\nImagine a personal banker who is available anytime, anywhere, ensuring every transaction is authenticated by you.",
                  ),
                  SlideItem(
                    title: "Elevate Your Transaction Experience",
                    subTitle:
                        "Whether you're transferring money to a loved one, paying bills, or managing other banking activities, the 2FA OTP App ensures each of these operations is authenticated and secured uniquely by you. Now, your transactions are not just simple actions, but a demonstration of advanced, personalized security.\n\nThis is not just banking — this is your banking redefined, backed with cutting-edge security and customized convenience.",
                  ),
                ],
              ),
            ),
            // Bottom actions and indicator
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Get Started" Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: const GetStarted(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        // padding: EdgeInsets.zero,
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        "Get Started",
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Page Indicator
                  Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: 4,
                      effect: const ExpandingDotsEffect(
                        activeDotColor: Colors.black54,
                        dotColor: Colors.black38,
                        dotHeight: 7,
                        dotWidth: 7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SlideItem extends StatelessWidget {
  final String title;
  final String subTitle;

  const SlideItem({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // SingleChildScrollView ensures no overflow if content is long
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reduced spacer to avoid overflow
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: GoogleFonts.openSans(
                fontSize: 25,
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
              subTitle,
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
          // Add extra spacing at the end if desired
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
