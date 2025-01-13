import 'package:flutter/material.dart';

/// A base class that represents a loading dialog
abstract class DialogWidget extends StatelessWidget {
  /// Creates a new instance of [DialogWidget].
  const DialogWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    Key? key,
  }) : super(key: key);

  /// The message to display in the loading dialog.
  final String? message;

  /// The background color of the loading dialog.
  final Color backgroundColor;

  /// The color of the text in the loading dialog.
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
            color: backgroundColor, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.black,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              message ?? "Loading...",
              style: TextStyle(color: textColor),
            )
          ],
        ),
      ),
    );
  }
}

/// A subclass of [DialogWidget] that has a dark background.
class DarkDialogWidget extends DialogWidget {
  /// Creates a new instance of [DarkDialogWidget].
  const DarkDialogWidget({
    String? message,
    Color textColor = Colors.white,
    Key? key,
  }) : super(
    message: message,
    backgroundColor: Colors.black,
    textColor: textColor,
    key: key,
  );
}

/// A subclass of [DialogWidget] that has a light background.
class LightDialogWidget extends DialogWidget {
  /// Creates a new instance of [LightDialogWidget].
  const LightDialogWidget({
    String? message,
    Color textColor = Colors.black,
    Key? key,
  }) : super(
    message: message,
    backgroundColor: Colors.white,
    textColor: textColor,
    key: key,
  );
}

/// A class that provides methods for displaying and closing a loading dialog.
class LoadingHandler {
  /// The context in which the loading dialog will be displayed.
  final BuildContext context;

  /// Creates a new instance of [LoadingHandler].
  LoadingHandler(this.context);

  /// Displays a loading dialog with a dark background.
  void loadingWidgetDark({String? message, Color textColor = Colors.white}) {
    showDialog(
      context: context,
      builder: (context) => DarkDialogWidget(message: message, textColor: textColor),
    );
  }

  /// Displays a loading dialog with a light background.
  void loadingWidgetLight({String? message, Color textColor = Colors.black}) {
    showDialog(
      context: context,
      builder: (context) => LightDialogWidget(message: message, textColor: textColor),
    );
  }
}
