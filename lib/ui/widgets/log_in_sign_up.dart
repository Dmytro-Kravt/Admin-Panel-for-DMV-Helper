import 'package:dmv_admin/core/utils/utils.dart';
import 'package:dmv_admin/ui/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class LogInSignUp extends StatefulWidget {
  final AuthProvider authProv;
  final Function(String generatedPass) onDataSent;
  const LogInSignUp({
    super.key,
    required this.authProv,
    required this.onDataSent
  });

  @override
  State<LogInSignUp> createState() => _LogInSignUpState();
}

class _LogInSignUpState extends State<LogInSignUp> {


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        if (!widget.authProv.isLogIn) {
          widget.authProv.toggleSignInLogIn();
          widget.onDataSent('');
        } else {
          widget.authProv.toggleSignInLogIn();
          final newPass = widget.authProv.safePass;
          if (newPass == null) return;
          widget.onDataSent(newPass);
        }
      },
      child: Container(
        width: 250,
        height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
                curve: Curves.easeInOut,
                alignment: widget.authProv.isLogIn == true
                    ? .centerLeft
                    : .centerRight,
                duration: Duration(milliseconds: 300),
              child: Container(
                width: 125,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    color: Theme.of(context).colorScheme.onSecondaryContainer
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: Center(
                      child: Text(
                        'Log In',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.bodyMedium,),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
