import 'dart:io';

import 'package:dirgebeya/Pages/LoginPage.dart';
import 'package:dirgebeya/Pages/RefundPage.dart';
import 'package:dirgebeya/Pages/SheetPages/BankInfoScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/LoanPolicyScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/LoanScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/MessagesScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/MyshopScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/ProductListScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/ProfileScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/RequestPage.dart';
import 'package:dirgebeya/Pages/SheetPages/SettingsPage.dart';
import 'package:dirgebeya/Pages/SheetPages/TermsAndConditionsScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/TransactionScreen.dart';
import 'package:dirgebeya/Pages/SheetPages/WalletPage.dart';
import 'package:dirgebeya/Pages/SplashScreen.dart';
import 'package:dirgebeya/Provider/RequestProvider.dart';

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
import 'package:dirgebeya/Provider/theme_provider.dart';
import 'package:dirgebeya/Provider/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
    final Telephony telephony = Telephony.instance;

  final prefs = await SharedPreferences.getInstance();
  final String? localeCode = prefs.getString('locale');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BankingProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = DashboardProvider();
            provider.fetchOverview(); // this triggers API call
            return provider;
          },
        ),

        ChangeNotifierProvider(create: (_) => DispatchProvider()),
      
        ChangeNotifierProvider(create: (_) => LoanProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => MyShopProvider()),
        ChangeNotifierProvider(create: (_) => OrderDetailProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        // reuest provider
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Your App',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => LoginScreen(),
            '/profile': (context) => MyProfileScreen(),
            '/my-shop': (context) => MyShopScreen(),
            '/products': (context) => ProductListScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/wallet': (context) => WalletScreen(),
            '/transaction': (context) => TransactionsScreen(),
            '/loan': (context) => LoanScreen(),
            '/messages': (context) => MessagesScreen(),
            '/bank-info': (context) => BankInfoScreen(),
            '/terms': (context) => TermsAndConditionsScreen(),
            '/loan-policy': (context) => LoanPolicyScreen(),
            '/request': (context) => RequestPage(),
          },
        );
      },
    );
  }
}

