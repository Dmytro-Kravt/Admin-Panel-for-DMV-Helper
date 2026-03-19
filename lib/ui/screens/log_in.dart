import 'package:dmv_admin/ui/widgets/log_in_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passControler = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _passControler.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    return SizedBox(
      width: double.infinity,
      child: AutofillGroup(
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
        
            Text(
              'Welcome to Admin Panel',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
        
            // ---- Email ----
            Column(
              crossAxisAlignment: .start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'Email',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                SizedBox(height: 2),
                SizedBox(
                  width: 350,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      errorText: authProv.error
                    ),
                    keyboardType: .emailAddress,
                    autofillHints: const [AutofillHints.email],
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
        
            // ---- Password ----
            Row(
              mainAxisAlignment: .center,
              children: [
                if (!authProv.isLogIn)
                    SizedBox(width: 45,),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        'Password',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    SizedBox(height: 2),
                    SizedBox(
                      width: 350,
                      child: TextField(
                        decoration: InputDecoration(
                          errorText: authProv.error
                        ),
                        keyboardType: .visiblePassword,
                        autofillHints: const [AutofillHints.password],
                        obscureText: true,
                        controller: _passControler,
                        readOnly: !authProv.isLogIn,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 2),
                    if (!authProv.isLogIn)
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          'We only accept generated password please save this one\nor generate a new one.',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
                if (!authProv.isLogIn)
                  Padding(
                    padding: EdgeInsets.only(bottom: authProv.error != null
                        ? 35
                        : 15,
                        left: 5),
                    child: SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          onPressed: () {
                              authProv.generationPass();
                              if (authProv.safePass == null) return;
                              _passControler.text = authProv.safePass!;
                          },
                          icon: Icon(Icons.restart_alt_outlined,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        )
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
        
            // ---- Toggle SignIn LogIn ----
            LogInSignUp(
                authProv: authProv,
              onDataSent: (String receivedPass) {
                  _passControler.text = receivedPass;
              },
            ),
            SizedBox(height: 50,),
        
            // ---- Submit ----
            ElevatedButton(
                onPressed: () {
                  if (authProv.isLogIn) {
                    authProv.logIn(
                        _emailController.text,
                        _passControler.text
                    );
                  } else {
                    authProv.createUser(_emailController.text);
                  }
                },
                child: authProv.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      )
                    : Text(
                  authProv.isLogIn
                      ? 'Log In'
                      : 'Sign Up',
                )
            )
        
          ],
        ),
      ),
    );
  }
}
