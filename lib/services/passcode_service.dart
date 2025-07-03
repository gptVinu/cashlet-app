import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PasscodeService {
  static const String _passcodeKey = 'app_passcode';
  static const String _passcodeEnabledKey = 'passcode_enabled';
  static const String _securityQuestionKey = 'security_question';
  static const String _securityAnswerKey = 'security_answer';

  // Check if passcode is enabled
  Future<bool> isPasscodeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_passcodeEnabledKey) ?? false;
  }

  // Set a new passcode
  Future<void> setPasscode(String passcode) async {
    final prefs = await SharedPreferences.getInstance();
    final hashedPasscode = _hashString(passcode);
    await prefs.setString(_passcodeKey, hashedPasscode);
    await prefs.setBool(_passcodeEnabledKey, true);
  }

  // Verify entered passcode
  Future<bool> verifyPasscode(String passcode) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_passcodeKey) ?? '';
    final enteredHash = _hashString(passcode);
    return storedHash == enteredHash;
  }

  // Disable passcode protection
  Future<void> disablePasscode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_passcodeEnabledKey, false);
  }

  // Hash string for secure storage
  String _hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Set security question and answer
  Future<void> setSecurityQuestion(String question, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_securityQuestionKey, question);
    await prefs.setString(
        _securityAnswerKey, _hashString(answer.toLowerCase().trim()));
  }

  // Get stored security question
  Future<String> getSecurityQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_securityQuestionKey) ?? '';
  }

  // Verify security question answer
  Future<bool> verifySecurityAnswer(String answer) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_securityAnswerKey) ?? '';
    final enteredHash = _hashString(answer.toLowerCase().trim());
    return storedHash == enteredHash;
  }
}
