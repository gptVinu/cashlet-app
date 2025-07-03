import 'package:flutter/material.dart';

enum PasscodeEntryMode { create, verify, confirm }

class PasscodeEntry extends StatefulWidget {
  final PasscodeEntryMode mode;
  final Function(String) onComplete;
  final String? title;
  final String? subtitle;
  final VoidCallback? onForgotPasscode;

  const PasscodeEntry({
    Key? key,
    required this.mode,
    required this.onComplete,
    this.title,
    this.subtitle,
    this.onForgotPasscode,
  }) : super(key: key);

  @override
  State<PasscodeEntry> createState() => PasscodeEntryState();
}

class PasscodeEntryState extends State<PasscodeEntry> {
  String _passcode = '';
  final int _passcodeLength = 4;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    String title = widget.title ?? _getDefaultTitle();
    String subtitle = widget.subtitle ?? _getDefaultSubtitle();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildPasscodeDots(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 40),
          _buildNumPad(),
          if (widget.mode == PasscodeEntryMode.verify &&
              widget.onForgotPasscode != null)
            TextButton(
              onPressed: widget.onForgotPasscode,
              child: const Text('Forgot Passcode?'),
            ),
        ],
      ),
    );
  }

  String _getDefaultTitle() {
    switch (widget.mode) {
      case PasscodeEntryMode.create:
        return 'Create Passcode';
      case PasscodeEntryMode.verify:
        return 'Enter Passcode';
      case PasscodeEntryMode.confirm:
        return 'Confirm Passcode';
    }
  }

  String _getDefaultSubtitle() {
    switch (widget.mode) {
      case PasscodeEntryMode.create:
        return 'Please create a 4-digit passcode';
      case PasscodeEntryMode.verify:
        return 'Enter your 4-digit passcode';
      case PasscodeEntryMode.confirm:
        return 'Please confirm your passcode';
    }
  }

  Widget _buildPasscodeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_passcodeLength, (index) {
        bool isActive = index < _passcode.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  Widget _buildNumPad() {
    return Column(
      children: [
        _buildNumPadRow([1, 2, 3]),
        const SizedBox(height: 16),
        _buildNumPadRow([4, 5, 6]),
        const SizedBox(height: 16),
        _buildNumPadRow([7, 8, 9]),
        const SizedBox(height: 16),
        _buildNumPadRow([null, 0, -1]), // -1 represents delete
      ],
    );
  }

  Widget _buildNumPadRow(List<int?> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((number) {
        if (number == null) {
          // Empty space
          return _buildNumPadButton(null, null);
        } else if (number == -1) {
          // Delete button
          return _buildNumPadButton(
            const Icon(Icons.backspace_outlined),
            () => _onDelete(),
          );
        } else {
          // Number button
          return _buildNumPadButton(
            Text(
              number.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            () => _onNumberPressed(number.toString()),
          );
        }
      }).toList(),
    );
  }

  Widget _buildNumPadButton(Widget? child, VoidCallback? onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 70,
      height: 70,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: child != null
              ? Center(child: child)
              : const SizedBox(), // Empty space
        ),
      ),
    );
  }

  void _onNumberPressed(String number) {
    if (_passcode.length < _passcodeLength) {
      setState(() {
        _passcode += number;
        _errorMessage = null;
      });

      if (_passcode.length == _passcodeLength) {
        widget.onComplete(_passcode);
      }
    }
  }

  void _onDelete() {
    if (_passcode.isNotEmpty) {
      setState(() {
        _passcode = _passcode.substring(0, _passcode.length - 1);
        _errorMessage = null;
      });
    }
  }

  void showError(String message) {
    setState(() {
      _errorMessage = message;
      _passcode = '';
    });
  }

  void clearPasscode() {
    setState(() {
      _passcode = '';
      _errorMessage = null;
    });
  }
}
