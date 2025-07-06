import 'dart:io';


import 'package:dirgebeya/Pages/SheetPages/BankInfoScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/MyshopScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/ProductListScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/ProfileScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/TransactionScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/WalletPage.dart';
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


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
void main() {
   HttpOverrides.global = MyHttpOverrides();
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
      home:  SplashScreen(),
      routes: {
        '/profile': (context) =>  MyProfileScreen(),
        '/my-shop': (context) =>  MyShopScreen(),
        '/products': (context) =>  ProductListScreen(),
        // '/settings': (context) => const SettingsPage(),
        '/wallet': (context) =>  WalletScreen(),
        '/transaction':(context)=>TransactionsScreen(),
        '/loan':(context)=>TransactionsScreen(),
        // '/messages': (context) => const MessagesPage(),
        '/bank-info': (context) =>  BankInfoScreen(),
        // '/terms': (context) => const TermsPage(),
        // '/about': (context) => const AboutUsPage(),
        // '/loan-policy': (context) => const LoanPolicyPage(),
        // '/logout': (context) => const LogoutPage(),
      },
    );
  }
}
