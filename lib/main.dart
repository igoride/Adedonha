import 'package:adedonha/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'Stop',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF3F37C9),
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[50],

            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.indigo,
              accentColor: Colors.amber,
            ),

            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF3F37C9),
              foregroundColor: Colors.white,
              elevation: 4,
            ),

            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F37C9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            textTheme: TextTheme(
              headlineSmall: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF3F37C9),
              ),
              headlineMedium: TextStyle(
                  fontSize: 24, fontWeight: 
                  FontWeight.bold, color: 
                  Colors.black87
              ),
              bodySmall: TextStyle(
                  fontSize: 16, 
                  color: Colors.black87
              ),
              bodyMedium: TextStyle(
                  fontSize: 14, 
                  color: Colors.grey[800]
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),

            cardTheme: CardThemeData(
              color: Colors.black,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.indigo[200],

            colorScheme: ColorScheme.dark(
              primary: Colors.indigo[200]!,
              secondary: Colors.amber[300]!,
            ),
            scaffoldBackgroundColor: Colors.grey[900],

            appBarTheme: AppBarTheme(
              backgroundColor: Colors.indigo[200],
              foregroundColor: Colors.black87,
              elevation: 4,
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[200]!,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.amber[300],
              foregroundColor: Colors.black87,
            ),

            textTheme: TextTheme(
              headlineSmall: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo[200]),
              headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              bodySmall: TextStyle(fontSize: 16, color: Colors.white),
              bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[300]),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),

            cardTheme: CardThemeData(
              color: Colors.grey[850],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

          ),

          themeMode: currentMode,
          home: const WelcomePage(),
        );
      },
    );
  }

}






