import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Text(
            authProv.currentUser?.userEmail ?? 'Unknowen User',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: .center,
            children: [
              Text('User Role:', style: Theme.of(context).textTheme.bodyMedium,),
              SizedBox(width: 2,),
              Text(
                  authProv.role.name,
                  style: Theme.of(context).textTheme.bodyMedium
              )
            ],
          )
        ],
      ),
    );
  }
}
