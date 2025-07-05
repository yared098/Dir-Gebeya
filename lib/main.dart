
import 'package:dirgebeya/Pages/SplashScreen.dart';
import 'package:dirgebeya/Provider/auth_provider.dart';
import 'package:dirgebeya/Provider/banking_provider.dart';
import 'package:dirgebeya/Provider/dashboard_provider.dart';
import 'package:dirgebeya/Provider/dispatch_provider.dart';
import 'package:dirgebeya/Provider/loan_provider.dart';
import 'package:dirgebeya/Provider/login_provider.dart';
import 'package:dirgebeya/Provider/myshop_provider.dart';
import 'package:dirgebeya/Provider/order_detail_provider.dart';
import 'package:dirgebeya/Provider/order_provider.dart.dart';
import 'package:dirgebeya/Provider/products_provider.dart';
import 'package:dirgebeya/Provider/profile_provider.dart';
import 'package:dirgebeya/Provider/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BankingProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => DispatchProvider()),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => MyShopProvider()),
        ChangeNotifierProvider(create: (_) => OrderDetailProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),

        // Add other providers here if you have them, e.g.
        // ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home:  ProductsListSection()
      home: Scaffold(body: SplashScreen()),
    );
  }
}
