import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
    // Add cases for other platforms if needed
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBhr4YYmVAUk9G04MVnTpNSWJvarJ5_ty0',
    appId: '1:945144307616:web:131abeae88719b68848ec5',
    messagingSenderId: '945144307616',
    projectId: 'calee-7c212',
    authDomain: 'calee-7c212.firebaseapp.com',
    storageBucket: 'calee-7c212.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqvR9vgZHpODYCO1zgOE9xU2cVq0h2458',
    appId: '1:855817454004:android:b7fa3fbb7728164ab5f2e1',
    messagingSenderId: '855817454004',
    projectId: 'calee-app-e7e4f',
    storageBucket: 'calee-app-e7e4f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD3GQt2kaGr2YKX5f1lGrgZ-KYhF30vnW4',
    appId: '1:945144307616:ios:0f6d177e9fa0307f848ec5',
    messagingSenderId: '945144307616',
    projectId: 'calee-7c212',
    storageBucket: 'calee-7c212.appspot.com',
    iosBundleId: 'com.iitropar.calee',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD3GQt2kaGr2YKX5f1lGrgZ-KYhF30vnW4',
    appId: '1:945144307616:ios:0f6d177e9fa0307f848ec5',
    messagingSenderId: '945144307616',
    projectId: 'calee-7c212',
    storageBucket: 'calee-7c212.appspot.com',
    iosBundleId: 'com.iitropar.calee',
  );
}
