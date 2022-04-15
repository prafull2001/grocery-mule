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

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('images/$assetName', width: width);
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
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          title: "Welcome!",
          body:
          "Welcome to GroceryMule! Create an account to get started.",
          image: _buildImage('logo.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Add some friends",
          body:
          "Head over to the Cowamigos tab to search and add friends",
          image: _buildImage('logo.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Create a list",
          body:
          "Create a list by pressing the + sign at the bottom right",
          image: _buildImage('logo.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Add items",
          body:
          "Add some items to your list and click the \'Personal List\' to see the items you\'ve added",
          image: _buildImage('logo.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Checkout",
          body:
          "When you\'re done shopping, add send payment requests with the touch of a button!",
          image: _buildImage('logo.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
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