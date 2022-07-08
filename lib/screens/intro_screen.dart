import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_mule/constants.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:grocery_mule/screens/welcome_screen.dart';

class IntroScreen extends StatefulWidget {
  static String id = 'intro_screen';

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {

  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, WelcomeScreen.id);
  }

  Widget _buildImage(String assetName, double thisScale, [double width = 350]) {
    return Image.asset('images/$assetName', width: width, scale: thisScale,);
  }

  Widget _buildFeedbackImage(String assetName, double thisScale, [double width = 200]) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2 ),
      ),
      child: Image.asset('images/$assetName', width: width, scale: thisScale,)
    );
  }



  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: cream,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
          ),
        ),
      ),
      globalFooter: SizedBox(
        width: double.infinity,
        height: 80,
        child: ElevatedButton(
          child: const Text(
            'Let\'s go right away!',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
          ),
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          title: "Hey There! 👋",
          body:
          "Nice to meet you. Sign in with Google or your email to get started!",
          image: _buildImage('logo.png', 3),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Feedback and 🐞s",
          body:
          "Your feedback directly helps us improve the quality of GroceryMule! Please provide feedback through our Google Form found here!",
          image: _buildFeedbackImage('bug_reporting.png', 1),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Connect with PayPal 💵",
          body:
          "Add your PayPal.me link to your account to set up future payments",
          image: _buildImage('paypal.png', 7),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Find Your Crowd 🔍",
          body:
          "Head over to the \'Cowamigos\' tab to search for friends and add them to shopping trips!",
          image: _buildImage('friends.png', .9),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Create a List 📝",
          body:
          "Create a list to host a shopping trip by pressing the + sign at the bottom right of your home screen.",
          image: _buildImage('list.png', 0.9),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Add Items 🍎",
          body:
          "Add items to your list and click \'Personal List\' to view the items you\'ve added to that list.",
          image: _buildImage('items.png', 0.9),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Checkout 💰",
          body:
          "When you\'re done shopping for a list, click \'Checkout\' to send automatically calculated payment requests with the touch of a button!",
          image: _buildImage('checkout.png', 0.9),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back, color: Colors.orange),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward, color: Colors.orange),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }

}