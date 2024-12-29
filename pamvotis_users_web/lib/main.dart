import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Models
import 'models/user_model.dart';
import 'models/operation.dart';

// Core
import 'core/network_info.dart';
import 'core/result.dart';

// Services
import 'services/storage/storage_service.dart';
import 'services/storage/storage_service_factory.dart';
import 'services/secure_storage.dart';
import 'services/session_service.dart';

// Repositories
import 'repositories/user_repository.dart';
import 'repositories/auth_repository.dart';

// State Management
import 'assistantMethods/address_changer.dart';
import 'assistantMethods/cart_item_counter.dart';
import 'assistantMethods/total_amount.dart';

// Screens
import 'authentication/auth_screen.dart';
import 'splashScreen/splash_screen.dart';

// Global
import 'global/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "",
            authDomain: "",
            projectId: "",
            storageBucket: "",
            messagingSenderId: "",
            appId: "",
            measurementId: ""));

    // Initialize Services
    final storageService = await StorageServiceFactory.create();
    final secureStorage = SecureStorage();
    final networkInfo = NetworkInfo();
    final sessionService = SessionService(
      secureStorage: secureStorage,
      sessionTimeout: const Duration(minutes: 30),
    );

    // Initialize Repositories with storage service
    final userRepository = UserRepository(
      storageService: storageService,
      networkInfo: networkInfo,
    );

    final authRepository = AuthRepository(
      storageService: storageService,
      secureStorage: secureStorage,
      networkInfo: networkInfo,
    );

    runApp(MyApp(
      storageService: storageService,
      secureStorage: secureStorage,
      networkInfo: networkInfo,
      sessionService: sessionService,
      userRepository: userRepository,
      authRepository: authRepository,
    ));
  } catch (e) {
    print('Initialization error: $e');
  }
}

class MyApp extends StatefulWidget {
  final StorageService storageService;
  final SecureStorage secureStorage;
  final NetworkInfo networkInfo;
  final SessionService sessionService;
  final UserRepository userRepository;
  final AuthRepository authRepository;

  const MyApp({
    super.key,
    required this.storageService,
    required this.secureStorage,
    required this.networkInfo,
    required this.sessionService,
    required this.userRepository,
    required this.authRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    widget.sessionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<StorageService>.value(value: widget.storageService),
        Provider<SecureStorage>.value(value: widget.secureStorage),
        Provider<NetworkInfo>.value(value: widget.networkInfo),
        Provider<SessionService>.value(value: widget.sessionService),

        // Repositories
        Provider<UserRepository>.value(value: widget.userRepository),
        Provider<AuthRepository>.value(value: widget.authRepository),

        // State Management
        ChangeNotifierProvider(create: (_) => CartItemCounter()),
        ChangeNotifierProvider(create: (_) => TotalAmount()),
        ChangeNotifierProvider(create: (_) => AddressChanger()),
      ],
      child: MaterialApp(
        title: 'Pamvotis',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('el'),
        ],
        locale: const Locale('el'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: FutureBuilder<bool>(
          future: widget.sessionService.isSessionValid(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MySplashScreen();
            }
            return snapshot.data == true
                ? const MySplashScreen()
                : const AuthScreen();
          },
        ),
      ),
    );
  }
}
