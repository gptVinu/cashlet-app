import 'package:flutter/material.dart';
import '../../services/passcode_service.dart';
import '../../main.dart';
import '../../widgets/security/passcode_entry.dart';
import 'passcode_screen.dart';

class PasscodeVerificationScreen extends StatefulWidget {
  const PasscodeVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PasscodeVerificationScreen> createState() =>
      _PasscodeVerificationScreenState();
}

class _PasscodeVerificationScreenState
    extends State<PasscodeVerificationScreen> {
  final PasscodeService _passcodeService = PasscodeService();
  final GlobalKey<PasscodeEntryState> _passcodeEntryKey =
      GlobalKey<PasscodeEntryState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.lock_outline, size: 70),
                const SizedBox(height: 30),
                // Using the PasscodeEntry widget directly for a numeric keypad
                PasscodeEntry(
                  key: _passcodeEntryKey,
                  mode: PasscodeEntryMode.verify,
                  onComplete: (passcode) async {
                    final isCorrect =
                        await _passcodeService.verifyPasscode(passcode);

                    if (isCorrect) {
                      // Navigate to MainScreen on success
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                      }
                    } else {
                      _passcodeEntryKey.currentState
                          ?.showError('Incorrect passcode');
                    }
                  },
                  onForgotPasscode: _showSecurityQuestion,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSecurityQuestion() async {
    final question = await _passcodeService.getSecurityQuestion();

    if (question == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No security question set. Please contact support.')));
      return;
    }

    final TextEditingController answerController = TextEditingController();
    bool obscureText = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Security Question'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    labelText: 'Your Answer',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final answer = answerController.text;
                  final isCorrect =
                      await _passcodeService.verifySecurityAnswer(answer);

                  Navigator.pop(context);

                  if (isCorrect) {
                    // Navigate to passcode reset screen
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PasscodeScreen()),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incorrect answer')));
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        });
      },
    );
  }
}
