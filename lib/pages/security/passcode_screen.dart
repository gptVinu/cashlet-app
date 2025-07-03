import 'package:flutter/material.dart';
import '../../services/passcode_service.dart';

class PasscodeScreen extends StatefulWidget {
  final bool verifyOnly;

  const PasscodeScreen({
    Key? key,
    this.verifyOnly = false,
  }) : super(key: key);

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final TextEditingController _passcodeController = TextEditingController();
  final TextEditingController _securityAnswerController =
      TextEditingController();
  final PasscodeService _passcodeService = PasscodeService();

  bool _isPasscodeEnabled = false;
  bool _isError = false;
  String _errorMessage = '';

  // Screens
  final int _SET_PASSCODE = 0;
  final int _CONFIRM_PASSCODE = 1;
  final int _VERIFY_PASSCODE = 2;
  final int _SET_SECURITY_QUESTION = 3;
  final int _VERIFY_SECURITY_QUESTION = 4;

  int _currentScreen = 0;
  String _initialPasscode = '';

  // Security question options
  final List<String> _securityQuestions = [
    "What was your first pet's name?",
    "What is your mother's maiden name?",
    "What was the name of your first school?",
    "In what city were you born?",
    "What is the name of your favorite childhood teacher?",
  ];

  String _selectedQuestion = '';
  String _storedQuestion = '';

  @override
  void initState() {
    super.initState();
    _checkPasscodeStatus();
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  Future<void> _checkPasscodeStatus() async {
    final isEnabled = await _passcodeService.isPasscodeEnabled();
    String storedQuestion = await _passcodeService.getSecurityQuestion();

    // Ensure we have a default security question selected
    String defaultQuestion =
        _securityQuestions.isNotEmpty ? _securityQuestions[0] : "";

    setState(() {
      _isPasscodeEnabled = isEnabled;
      _storedQuestion = storedQuestion;
      _selectedQuestion = defaultQuestion; // Always set a default value

      if (widget.verifyOnly && isEnabled) {
        _currentScreen = _VERIFY_PASSCODE;
      } else if (isEnabled) {
        _currentScreen = _VERIFY_PASSCODE;
      } else {
        _currentScreen = _SET_PASSCODE;
      }
    });
  }

  Future<void> _handlePasscodeSubmission() async {
    final enteredText = _passcodeController.text;

    if (enteredText.isEmpty || enteredText.length < 4) {
      setState(() {
        _isError = true;
        _errorMessage = 'Passcode must be at least 4 digits';
      });
      return;
    }

    switch (_currentScreen) {
      case 0: // Set passcode
        setState(() {
          _initialPasscode = enteredText;
          _currentScreen = _CONFIRM_PASSCODE;
          _passcodeController.clear(); // Clear the field for confirmation
          _isError = false;
        });
        break;

      case 1: // Confirm passcode
        if (enteredText == _initialPasscode) {
          setState(() {
            _currentScreen = _SET_SECURITY_QUESTION;
            _passcodeController.clear(); // Clear the passcode field
            _isError = false;

            // Ensure we have a valid security question selected
            if (_selectedQuestion.isEmpty && _securityQuestions.isNotEmpty) {
              _selectedQuestion = _securityQuestions[0];
            }
          });
        } else {
          setState(() {
            _isError = true;
            _errorMessage = 'Passcodes do not match. Try again.';
            _passcodeController.clear(); // Clear for retry
          });
        }
        break;

      case 2: // Verify passcode
        final isCorrect = await _passcodeService.verifyPasscode(enteredText);
        if (isCorrect) {
          if (widget.verifyOnly) {
            Navigator.pop(
                context, true); // Return true for verification success
          } else {
            // Allow disabling passcode or changing it
            _showPasscodeOptions();
          }
        } else {
          setState(() {
            _isError = true;
            _errorMessage = 'Incorrect passcode. Try again.';
            _passcodeController.clear();
          });
        }
        break;
    }
  }

  Future<void> _handleSecurityQuestionSubmission() async {
    final answer = _securityAnswerController.text;

    if (answer.isEmpty) {
      setState(() {
        _isError = true;
        _errorMessage = 'Please enter an answer';
      });
      return;
    }

    if (_currentScreen == _SET_SECURITY_QUESTION) {
      // Save passcode and security question
      await _passcodeService.setPasscode(_initialPasscode);
      await _passcodeService.setSecurityQuestion(_selectedQuestion, answer);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Passcode and security question set successfully')),
      );
      Navigator.pop(context); // Return to settings
    } else if (_currentScreen == _VERIFY_SECURITY_QUESTION) {
      final isCorrect = await _passcodeService.verifySecurityAnswer(answer);

      if (isCorrect) {
        setState(() {
          _currentScreen = _SET_PASSCODE;
          _securityAnswerController.clear();
          _isError = false;
        });
      } else {
        setState(() {
          _isError = true;
          _errorMessage = 'Incorrect answer. Try again.';
          _securityAnswerController.clear();
        });
      }
    }
  }

  void _showPasscodeOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Passcode Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Change Passcode'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentScreen = _SET_PASSCODE;
                  _passcodeController.clear();
                  _initialPasscode = '';
                  _isError = false;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Change Security Question'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentScreen = _SET_SECURITY_QUESTION;
                  _securityAnswerController.clear();
                  if (_securityQuestions.isNotEmpty) {
                    _selectedQuestion = _securityQuestions[0];
                  }
                  _isError = false;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.no_encryption),
              title: const Text('Disable Passcode Protection'),
              onTap: () {
                Navigator.pop(context);
                _confirmDisablePasscode();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDisablePasscode() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Passcode'),
        content: const Text(
            'Are you sure you want to disable passcode protection? Your data will no longer be protected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _passcodeService.disablePasscode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passcode protection disabled')),
      );
      Navigator.pop(context); // Return to settings
    }
  }

  void _forgotPasscode() {
    setState(() {
      _currentScreen = _VERIFY_SECURITY_QUESTION;
      _passcodeController.clear();
      _isError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Icon for the current screen
              Icon(
                _getScreenIcon(),
                size: 64,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: 24),

              // Description text
              Text(
                _getScreenDescription(),
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Input fields based on current screen
              if (_currentScreen == _SET_PASSCODE ||
                  _currentScreen == _CONFIRM_PASSCODE ||
                  _currentScreen == _VERIFY_PASSCODE)
                _buildPasscodeInput(),

              if (_currentScreen == _SET_SECURITY_QUESTION)
                _buildSecurityQuestionSetup(),

              if (_currentScreen == _VERIFY_SECURITY_QUESTION)
                _buildSecurityQuestionVerification(),

              const SizedBox(height: 24),

              // Action button
              ElevatedButton(
                onPressed: () {
                  if (_currentScreen == _SET_PASSCODE ||
                      _currentScreen == _CONFIRM_PASSCODE ||
                      _currentScreen == _VERIFY_PASSCODE) {
                    _handlePasscodeSubmission();
                  } else {
                    _handleSecurityQuestionSubmission();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_getActionButtonText()),
              ),

              const SizedBox(height: 16),

              // Forgot passcode option
              if (_currentScreen == _VERIFY_PASSCODE)
                TextButton(
                  onPressed: _forgotPasscode,
                  child: const Text('Forgot Passcode?'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasscodeInput() {
    return TextField(
      controller: _passcodeController,
      keyboardType: TextInputType.number,
      obscureText: true,
      textAlign: TextAlign.center,
      maxLength: 6,
      decoration: InputDecoration(
        hintText: 'Enter passcode',
        errorText: _isError ? _errorMessage : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        counterText: '',
      ),
      onChanged: (value) {
        if (_isError) {
          setState(() {
            _isError = false;
          });
        }
      },
    );
  }

  Widget _buildSecurityQuestionSetup() {
    // Ensure a valid default value
    if (_selectedQuestion.isEmpty && _securityQuestions.isNotEmpty) {
      _selectedQuestion = _securityQuestions[0];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fix the dropdown overflow issue
        DropdownButtonFormField<String>(
          value: _selectedQuestion,
          decoration: InputDecoration(
            labelText: 'Security Question',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // Allow content to wrap within the input
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          isExpanded: true, // This is crucial to prevent overflow
          menuMaxHeight: 300, // Set a max height for the dropdown menu
          items: _securityQuestions.map((String question) {
            return DropdownMenuItem<String>(
              value: question,
              // Set a flexible child that allows wrapping or ellipsis
              child: Container(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
                child: Text(
                  question,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  softWrap: true,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedQuestion = newValue;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _securityAnswerController,
          decoration: InputDecoration(
            labelText: 'Answer',
            hintText: 'Enter your answer',
            errorText: _isError ? _errorMessage : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            if (_isError) {
              setState(() {
                _isError = false;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSecurityQuestionVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            _storedQuestion,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          controller: _securityAnswerController,
          decoration: InputDecoration(
            labelText: 'Answer',
            hintText: 'Enter your answer',
            errorText: _isError ? _errorMessage : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            if (_isError) {
              setState(() {
                _isError = false;
              });
            }
          },
        ),
      ],
    );
  }

  String _getScreenTitle() {
    switch (_currentScreen) {
      case 0:
        return 'Set Passcode';
      case 1:
        return 'Confirm Passcode';
      case 2:
        return 'Enter Passcode';
      case 3:
        return 'Set Security Question';
      case 4:
        return 'Answer Security Question';
      default:
        return '';
    }
  }

  IconData _getScreenIcon() {
    switch (_currentScreen) {
      case 0:
      case 1:
        return Icons.lock_open;
      case 2:
        return Icons.lock_outline;
      case 3:
      case 4:
        return Icons.security;
      default:
        return Icons.lock;
    }
  }

  String _getScreenDescription() {
    switch (_currentScreen) {
      case 0:
        return 'Create a passcode to secure your app';
      case 1:
        return 'Re-enter your passcode to confirm';
      case 2:
        return 'Enter your passcode to continue';
      case 3:
        return 'Set up a security question to recover your passcode';
      case 4:
        return 'Answer your security question to reset your passcode';
      default:
        return '';
    }
  }

  String _getActionButtonText() {
    switch (_currentScreen) {
      case 0:
        return 'Set Passcode';
      case 1:
        return 'Confirm Passcode';
      case 2:
        return 'Verify';
      case 3:
        return 'Set Security Question';
      case 4:
        return 'Verify Answer';
      default:
        return 'Continue';
    }
  }
}
