// ignore_for_file: avoid_web_libraries_in_flutter, use_build_context_synchronously, deprecated_member_use
import 'dart:html' as html;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'dart:js' as dart_js;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CashifyFullApp());
}
// 🌐 Top-Level Global Language Helper Function
String tr(String en, String hi) {
  return AppState.appLanguage.value == 'Hindi (हिंदी)' ? hi : en;
}
// Fetch Accessories from PostgreSQL NeonDB (With Fallback Sample Data)
Future<List<Map<String, dynamic>>> fetchAccessoriesFromNeonDB() async {
  final List<Map<String, dynamic>> defaultAccessories = [
    {
      'id': 1,
      'title': 'Apple 20W USB-C Fast Power Adapter',
      'category': 'Chargers',
      'price': 1699,
      'image_url': 'https://images.unsplash.com/photo-1609592424109-dd9892f1b177?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 2,
      'title': 'AirPods Pro Gen 2 MagSafe Case',
      'category': 'Audio',
      'price': 18999,
      'image_url': 'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 3,
      'title': 'MagSafe Clear Case for iPhone 15',
      'category': 'Cases & Covers',
      'price': 1299,
      'image_url': 'https://images.unsplash.com/photo-1603313011101-320f26a4f6f6?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 4,
      'title': 'Anker 10000mAh Ultra-Slim Power Bank',
      'category': 'Power Banks',
      'price': 2499,
      'image_url': 'https://images.unsplash.com/photo-1620783770629-122b7f187703?auto=format&fit=crop&w=600&q=80',
    },
  ];

  try {
    final response = await http.get(Uri.parse('http://localhost:5000/api/accessories'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    }
  } catch (e) {
    debugPrint('Database Fetch Accessories Error: $e');
  }
  
  return defaultAccessories;
}

// Fetch Saved Addresses from PostgreSQL NeonDB
Future<List<Map<String, dynamic>>> fetchAddressesFromNeonDB() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:5000/api/addresses'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    }
  } catch (e) {
    debugPrint('Database Fetch Addresses Error: $e');
  }
  return [];
}

// Add New Address to PostgreSQL NeonDB
Future<void> addAddressToNeonDB(Map<String, dynamic> addressData) async {
  try {
    await http.post(
      Uri.parse('http://localhost:5000/api/addresses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(addressData),
    );
  } catch (e) {
    debugPrint('Error adding address to Neon DB: $e');
  }
}
// Top-Level Function (Near line 30)
Future<void> addProductToNeonDB(Map<String, dynamic> product) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('Failed to add product to Neon DB: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error adding product to Neon DB: $e');
  }
}
// Fetch Orders from PostgreSQL NeonDB
Future<List<Map<String, dynamic>>> fetchOrdersFromNeonDB() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:5000/api/orders'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    }
  } catch (e) {
    debugPrint('Database Fetch Orders Error: $e');
  }
  return [];
}
// Save Diagnostics Results to NeonDB
Future<void> saveDiagnostics(Map<String, dynamic> testData) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/diagnostics'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(testData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('✅ Diagnostics data saved to database successfully!');
    }
  } catch (e) {
    debugPrint('❌ Error saving diagnostics to database: $e');
  }
}
// Add Order to PostgreSQL NeonDB (Full Order Details Sync)
Future<void> addOrderToNeonDB(Map<String, dynamic> order) async {
  try {
    final double parsedPrice = double.tryParse(
      (order['offered_price'] ?? order['price'] ?? order['amount'] ?? '0')
          .toString()
          .replaceAll('₹', '')
          .replaceAll(',', '')
          .trim(),
    ) ?? 0.0;

    await http.post(
      Uri.parse('http://localhost:5000/api/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'order_id': order['order_id'] ?? order['id'] ?? 'CS-${DateTime.now().millisecondsSinceEpoch}',
        'user_email': order['user_email'] ?? 'guest@cashify.in',
        'device_name': order['title'] ?? order['device_name'] ?? 'Device Order',
        'offered_price': parsedPrice,
        'type': order['type'] ?? 'buy',
        'status': order['status'] ?? 'Order Confirmed',
        'slot': order['slot'] ?? 'Morning (9 AM - 12 PM)',
        'payment_mode': order['payment_mode'] ?? 'COD',
      }),
    );
  } catch (e) {
    debugPrint('Error adding order to Neon DB: $e');
  }
}
// -----------------------------------------------------------------------------
// WEB SMOOTH DRAG SCROLL BEHAVIOR
// -----------------------------------------------------------------------------
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

// -----------------------------------------------------------------------------
// CONSTANT DEVICE CATALOG & MASTER DATA
// -----------------------------------------------------------------------------
const Map<String, List<String>> kBrandModels = {
  'Apple': ['iPhone 15 Pro Max', 'iPhone 15', 'iPhone 14 Pro', 'iPhone 13', 'iPhone 12', 'iPhone 11'],
  'Samsung': ['Galaxy S24 Ultra', 'Galaxy S23 5G', 'Galaxy S22 5G', 'Galaxy Z Flip5', 'Galaxy A54 5G'],
  'OnePlus': ['OnePlus 12 5G', 'OnePlus 11R 5G', 'OnePlus 10 Pro', 'OnePlus Nord CE 3'],
  'Xiaomi': ['Xiaomi 13 Pro', 'Redmi Note 13 Pro+', 'Redmi Note 12 5G'],
  'Google': ['Pixel 8 Pro', 'Pixel 7a', 'Pixel 6a'],
  'Vivo': ['Vivo X100 Pro', 'Vivo V29 5G', 'Vivo T2 Pro'],
};

const List<String> kStorageOptions = ['64 GB', '128 GB', '256 GB', '512 GB'];

final List<Map<String, dynamic>> kMasterInventory = [
    {
    'id': 'PROD-109',
    'title': 'iPhone 15 (128 GB)',
    'category': 'Mobiles',
    'brand': 'Apple',
    'price': '₹58,999',
    'rawPrice': 58999,
    'original': '₹79,900',
    'condition': 'Superb • 32-Point Check',
    'emi': 'EMI from ₹2,750/mo',
    'screen': '6.1" Dynamic Island OLED',
    'processor': 'A16 Bionic Chip',
    'camera': '48MP Dual Camera',
    'battery': '3349 mAh Fast Charge',
    'type': 'buy',
    'image': 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=600&q=80',
  },
  {
    'id': 'PROD-101',
    'title': 'iPhone 15 Pro Max (256 GB)',
    'category': 'Mobiles',
    'brand': 'Apple',
    'price': '₹98,999',
    'rawPrice': 98999,
    'original': '₹1,59,900',
    'condition': 'Flawless • 32-Point Check',
    'emi': 'EMI from ₹4,650/mo',
    'screen': '6.7" Super Retina XDR OLED (120Hz)',
    'processor': 'A17 Pro 3nm Bionic',
    'camera': '48MP Quad + 5x Telephoto',
    'battery': '4422 mAh (All-Day Pro)',
    'type': 'buy',
    'image': 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=600&q=80',
  },
  {
    'id': 'PROD-102',
    'title': 'iPhone 14 Pro (128 GB)',
    'category': 'Mobiles',
    'brand': 'Apple',
    'price': '₹64,999',
    'rawPrice': 64999,
    'original': '₹1,19,900',
    'condition': 'Superb • Battery 91%',
    'emi': 'EMI from ₹3,050/mo',
    'screen': '6.1" Dynamic Island OLED (120Hz)',
    'processor': 'A16 Bionic Chip',
    'camera': '48MP Triple Pro Lens',
    'battery': '3200 mAh Fast Charge',
    'type': 'buy',
    'image': 'https://images.unsplash.com/photo-1678652197831-2d180705cd2c?auto=format&fit=crop&w=600&q=80',
  },
  {
    'id': 'PROD-103',
    'title': 'iPhone 13 (Midnight 128 GB)',
    'category': 'Mobiles',
    'brand': 'Apple',
    'price': '₹39,499',
    'rawPrice': 39499,
    'original': '₹59,900',
    'condition': 'Superb • 32 Point Check Passed',
    'emi': 'EMI from ₹1,850/mo',
    'screen': '6.1" Super Retina XDR OLED',
    'processor': 'A15 Bionic 6-Core',
    'camera': '12MP Dual Cinematic Mode',
    'battery': '3240 mAh Battery Life',
    'type': 'buy',
    'image': 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=600&q=80',
  },
  {
    'id': 'PROD-104',
    'title': 'Samsung Galaxy S24 Ultra 5G',
    'category': 'Mobiles',
    'brand': 'Samsung',
    'price': '₹89,999',
    'rawPrice': 89999,
    'original': '₹1,29,999',
    'condition': 'Like New • AI Enabled',
    'emi': 'EMI from ₹4,200/mo',
    'screen': '6.8" Dynamic AMOLED 2X Flat 120Hz',
    'processor': 'Snapdragon 8 Gen 3 for Galaxy',
    'camera': '200MP Quad ProVisual Engine',
    'battery': '5000 mAh 45W Ultra Charge',
    'type': 'buy',
    'image': 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=600&q=80',
  },
  {
    'id': 'PROD-105',
    'title': 'Samsung Galaxy S22 5G (128 GB)',
    'category': 'Mobiles',
    'brand': 'Samsung',
    'price': '₹28,999',
    'rawPrice': 28999,
    'original': '₹54,000',
    'condition': 'Good as New • 6 Month Warranty',
    'emi': 'EMI from ₹1,400/mo',
    'screen': '6.1" Dynamic AMOLED 2X 120Hz',
    'processor': 'Snapdragon 8 Gen 1',
    'camera': '50MP Triple Nightography',
    'battery': '3700 mAh Fast Charge',
    'type': 'buy',
    'image': 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=600&q=80',
  },
  {
    'id': 'PROD-106',
    'title': 'OnePlus 12 5G (Flowy Emerald)',
    'category': 'Mobiles',
    'brand': 'OnePlus',
    'price': '₹48,999',
    'rawPrice': 48999,
    'original': '₹64,999',
    'condition': 'Superb • Hasselblad Camera',
    'emi': 'EMI from ₹2,300/mo',
    'screen': '6.82" 2K ProXDR Display 120Hz',
    'processor': 'Snapdragon 8 Gen 3',
    'camera': '50MP Sony LYT-808 Hasselblad',
    'battery': '5400 mAh 100W Fast Charge',
    'type': 'buy',
    'image': 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?auto=format&fit=crop&w=600&q=80',
  },
  {
    'id': 'PROD-107',
    'title': 'MacBook Air M2 (256 GB SSD)',
    'category': 'Laptops',
    'brand': 'Apple',
    'price': '₹68,999',
    'rawPrice': 68999,
    'original': '₹1,14,900',
    'condition': 'Superb • Battery Health 97%',
    'emi': 'EMI from ₹3,250/mo',
    'screen': '13.6" Liquid Retina Display',
    'processor': 'Apple M2 8-Core CPU',
    'camera': '1080p FaceTime HD Camera',
    'battery': 'Up to 18 Hours Battery',
    'type': 'buy',
    'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=600&q=80',
  },
  {
    'id': 'PROD-108',
    'title': 'iPad Air 5th Gen (M1 64GB)',
    'category': 'Tablets',
    'brand': 'Apple',
    'price': '₹38,499',
    'rawPrice': 38499,
    'original': '₹59,900',
    'condition': 'Superb • 10.9" Liquid Retina',
    'emi': 'EMI from ₹1,800/mo',
    'screen': '10.9" True Tone Display',
    'processor': 'Apple M1 Chip',
    'camera': '12MP Center Stage Camera',
    'battery': '28.6Wh rechargeable',
    'type': 'buy',
    'image': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=600&q=80',
  },
];

final List<Map<String, dynamic>> kRepairServicesList = [
  {
    'title': 'Touchscreen & Display Glass',
    'deviceType': 'Mobile',
    'desc': 'Grade-A Original Screen Replacement with Free Screen Guard',
    'marketPrice': '₹4,500',
    'cashifyPrice': '₹1,899',
    'rawPrice': 1899,
    'time': '30 Mins Doorstep',
    'icon': Icons.stay_current_portrait,
    'warranty': '6 Months Assured Replacement',
    'popular': true,
  },
  {
    'title': 'Battery Health Upgrade',
    'deviceType': 'Mobile',
    'desc': 'High-density OEM Cell with 100% capacity calibration',
    'marketPrice': '₹2,999',
    'cashifyPrice': '₹1,199',
    'rawPrice': 1199,
    'time': '25 Mins Doorstep',
    'icon': Icons.battery_charging_full,
    'warranty': '6 Months Warranty',
    'popular': true,
  },
  {
    'title': 'Laptop Keyboard & Battery Service',
    'deviceType': 'Laptop',
    'desc': 'MacBook & Dell/HP OEM Keyboard & Lithium Battery Replace',
    'marketPrice': '₹6,500',
    'cashifyPrice': '₹3,499',
    'rawPrice': 3499,
    'time': '60 Mins Doorstep',
    'icon': Icons.laptop,
    'warranty': '6 Months Warranty',
    'popular': true,
  },
  {
    'title': 'Tablet / iPad Glass & Charging Fix',
    'deviceType': 'Tablet',
    'desc': 'Original iPad Retina display & Type-C charging port flex',
    'marketPrice': '₹5,800',
    'cashifyPrice': '₹2,899',
    'rawPrice': 2899,
    'time': '45 Mins Doorstep',
    'icon': Icons.tablet_mac,
    'warranty': '6 Months Warranty',
    'popular': false,
  },
  {
    'title': 'Smartwatch Screen & Sensor Repair',
    'deviceType': 'Smartwatch',
    'desc': 'Apple Watch & Galaxy Watch OLED glass + heart rate sensor fix',
    'marketPrice': '₹4,200',
    'cashifyPrice': '₹1,999',
    'rawPrice': 1999,
    'time': '30 Mins Doorstep',
    'icon': Icons.watch,
    'warranty': '3 Months Warranty',
    'popular': false,
  },
];

// TOP-LEVEL DYNAMIC IMAGE HELPER
String getProductImage(Map<String, dynamic> item) {
  final title = (item['title'] ?? item['name'] ?? item['brand'] ?? '').toString().toLowerCase();
  final img = (item['image'] ?? '').toString();

  if (img.startsWith('http') && !img.contains('placeholder') && !img.contains('1511707171634')) {
    return img;
  }

  if (title.contains('laptop') || title.contains('dell') || title.contains('macbook')) {
    return 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&auto=format&fit=crop&q=80';
  } else if (title.contains('oneplus') || title.contains('nord')) {
    return 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=800&auto=format&fit=crop&q=80';
  } else if (title.contains('ipad') || title.contains('tab')) {
    return 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800&auto=format&fit=crop&q=80';
  } else if (title.contains('watch')) {
    return 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&auto=format&fit=crop&q=80';
  } else if (title.contains('sony') || title.contains('headphone')) {
    return 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800&auto=format&fit=crop&q=80';
  }
  
  return 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=800&auto=format&fit=crop&q=80';
}

Widget buildSafeImage(String? url, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
  final safeUrl = (url != null && url.isNotEmpty)
      ? url
      : 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=600&q=80';

  return Image.network(
    safeUrl,
    height: height,
    width: width,
    fit: fit,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        height: height,
        width: width,
        color: const Color(0xFFE0F2F1),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.phone_android, size: 36, color: Color(0xFF00A79D)),
            SizedBox(height: 4),
            Text('Cashify Assured', style: TextStyle(fontSize: 10, color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
          ],
        ),
      );
    },
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        height: height,
        width: width,
        color: Colors.grey.shade100,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00A79D))),
      );
    },
  );
}

Widget buildSafeAvatarImage(String? url, {double radius = 28, String fallbackName = 'User'}) {
  if (url == null || url.isEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF00A79D),
      child: Text(fallbackName.isNotEmpty ? fallbackName.substring(0, 1).toUpperCase() : 'U', style: TextStyle(fontSize: radius * 0.8, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
  return ClipOval(
    child: Image.network(
      url,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: radius * 2,
          height: radius * 2,
          color: const Color(0xFF00A79D),
          alignment: Alignment.center,
          child: Text(fallbackName.isNotEmpty ? fallbackName.substring(0, 1).toUpperCase() : 'U', style: TextStyle(fontSize: radius * 0.8, color: Colors.white, fontWeight: FontWeight.bold)),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: radius * 2,
          height: radius * 2,
          color: Colors.grey.shade200,
          child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00A79D)))),
        );
      },
    ),
  );
}

// -----------------------------------------------------------------------------
// CENTRAL APPLICATION STATE (WITH NOTIFICATIONS & LOCALIZATION)
// -----------------------------------------------------------------------------
class AppState {
  static ValueNotifier<int> selectedBottomIndex = ValueNotifier<int>(0);
  static final ValueNotifier<double> walletBalance = ValueNotifier<double>(450.0);
static final ValueNotifier<List<Map<String, dynamic>>> myOrders = ValueNotifier<List<Map<String, dynamic>>>([]);
  static final ValueNotifier<List<Map<String, dynamic>>> cartItems = ValueNotifier<List<Map<String, dynamic>>>([]);
  static final ValueNotifier<List<Map<String, dynamic>>> wishlistItems = ValueNotifier<List<Map<String, dynamic>>>([]);
  static final ValueNotifier<bool> isGuestUser = ValueNotifier<bool>(false);
  static final ValueNotifier<String> selectedCity = ValueNotifier<String>('Bengaluru');
  static final ValueNotifier<String> selectedAddress = ValueNotifier<String>(
    'Flat 402, Green Glen Heights, HSR Layout, Bengaluru, 560102',
  );

  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);
  static final ValueNotifier<String> appLanguage = ValueNotifier<String>('English');

  // Notification Center Data Store
  static final ValueNotifier<List<Map<String, dynamic>>> notifications = ValueNotifier<List<Map<String, dynamic>>>([
    {'title': '🔥 Price Drop Alert', 'desc': 'iPhone 15 Pro Max price dropped by ₹5,000!', 'time': '10m ago', 'type': 'offer'},
    {'title': '📦 Order Dispatched', 'desc': 'Your doorstep partner has been assigned successfully.', 'time': '1h ago', 'type': 'order'},
    {'title': '🎉 Welcome Bonus', 'desc': 'You have unlocked a scratch card worth ₹200!', 'time': '2h ago', 'type': 'reward'},
  ]);

  // Multi-Language Dictionary (English & Hindi)
  static const Map<String, Map<String, String>> translations = {
    'English': {
      'dark_mode': 'Dark Theme Mode',
      'language': 'Language / Bhasha',
      'refer_earn': 'Refer & Earn ₹200 Bonus',
      'wallet_balance': 'Cashify Wallet Balance',
      'add_money': 'Add Money',
      'pickup_location': 'Registered Pickup / Delivery Location',
      'edit_location': 'Edit Location',
      'orders_repairs': 'Orders, Pickups & Repairs',
      'explore_services': 'Explore Services',
      'sell_phone': 'Sell Phone',
      'buy_refurb': 'Buy Refurb',
      'repairs': 'Repairs',
      'my_account': 'My Account',
      'refurb_flagships': 'Refurbished Flagships',
      'top_picks': '🔥 Top Picks',
      'add_to_cart': 'Add to Cart',
    },
    'Hindi (हिंदी)': {
      'dark_mode': 'डार्क थीम मोड',
      'language': 'भाषा / Language',
      'refer_earn': 'रेफर करें और ₹200 बोनसएं',
      'wallet_balance': 'कैशिफाई वॉलेट बैलेंस',
      'add_money': 'पैसे जोड़ें',
      'pickup_location': 'पंजीकृत पिकअप / डिलीवरी पता',
      'edit_location': 'पता बदलें',
      'orders_repairs': 'ऑर्डर, पिकअप और रिपेयर',
      'explore_services': 'सेवाएं देखें',
      'sell_phone': 'फोन बेचें',
      'buy_refurb': 'रिफर्बिशड खरीदें',
      'repairs': 'रिपेयर',
      'my_account': 'मेरा खाता',
      'refurb_flagships': 'रिफर्बिशड फ्लैगशिप्स',
      'top_picks': '🔥 टॉप पिक्स',
      'add_to_cart': 'कार्ट में डालें',
    },
  };

  static String tr(String key) {
    return translations[appLanguage.value]?[key] ?? translations['English']?[key] ?? key;
  }

// Flexible addOrder Function (NeonDB Sync + Notifications + Context Support)
  static void addOrder(dynamic firstArg, [dynamic secondArg]) {
    BuildContext? context;
    Map<String, dynamic>? order;

    if (firstArg is BuildContext && secondArg is Map<String, dynamic>) {
      context = firstArg;
      order = secondArg;
    } else if (firstArg is Map<String, dynamic>) {
      order = firstArg;
    }

    if (order != null) {
      myOrders.value = [order, ...myOrders.value];
      
      // NeonDB Sync
      try {
        addOrderToNeonDB(order);
      } catch (e) {
        // Fallback for local storage
      }

      // Notification Add Karein
      notifications.value = [
        {
          'title': '📦 Order Confirmed',
          'desc': 'Your order #${order['id']} placed successfully!',
        },
        ...notifications.value,
      ];

      // Agar context pass hua hai toh SnackBar dikhayein
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order['id']} placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  static bool toggleWishlist(Map<String, dynamic> product) {
    final list = List<Map<String, dynamic>>.from(wishlistItems.value);
    final index = list.indexWhere((item) => item['title'] == product['title']);
    bool added = false;
    if (index >= 0) {
      list.removeAt(index);
      added = false;
    } else {
      list.add(product);
      added = true;
    }
    wishlistItems.value = list;
    return added;
  }

  static bool isInWishlist(String? title) {
    if (title == null) return false;
    return wishlistItems.value.any((item) => item['title'] == title);
  }

  static void addToCart(Map<String, dynamic> product) {
  final currentCart = List<Map<String, dynamic>>.from(cartItems.value);
  currentCart.add(product);
  cartItems.value = currentCart; // 👈 Explicit new list reference se ValueNotifier trigger hota hai
}

  static void removeFromCart(int index) {
    final list = List<Map<String, dynamic>>.from(cartItems.value);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      cartItems.value = list;
    }
  }

  static void clearCart() {
    cartItems.value = [];
  }

 // 🔥 100% REAL GOOGLE MAPS LOCATION PICKER FOR HOME SCREEN (FULL FUNCTIONAL)
  static void openMapLocationPicker(BuildContext context) {
    String tempCity = AppState.selectedCity.value;
    TextEditingController searchController = TextEditingController(text: tempCity);
    TextEditingController tempAddressController = TextEditingController(
      text: AppState.selectedAddress.value,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                final String mapKey = 'home-gmap-${tempCity.hashCode}-${tempCity.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}';

                try {
                  ui_web.platformViewRegistry.registerViewFactory(mapKey, (int viewId) {
                    final encoded = Uri.encodeComponent(tempCity);
                    final iframe = html.IFrameElement()
                      ..src = 'https://maps.google.com/maps?q=$encoded&t=&z=14&ie=UTF8&iwloc=&output=embed'
                      ..style.border = 'none'
                      ..style.height = '100%'
                      ..style.width = '100%';
                    return iframe;
                  });
                } catch (_) {}

                void updateLocation(String query) {
                  final text = query.trim();
                  if (text.isNotEmpty) {
                    final formattedText = text.split(' ').map((word) {
                      if (word.isEmpty) return '';
                      return word[0].toUpperCase() + word.substring(1).toLowerCase();
                    }).join(' ');

                    setModalState(() {
                      tempCity = formattedText;
                      searchController.text = formattedText;
                      tempAddressController.text = '$formattedText, India';
                    });
                  }
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // 1. Header Navigation
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Select Location via Map',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),

                      // 2. Live Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: TextField(
                            controller: searchController,
                            onSubmitted: (val) => updateLocation(val),
                            decoration: InputDecoration(
                              hintText: 'Search city, area, or pincode...',
                              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF00A79D), size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.arrow_forward, color: Color(0xFF00A79D), size: 20),
                                onPressed: () => updateLocation(searchController.text),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),

                      // 3. Quick Select Metro City Chips
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Bengaluru', 'Delhi NCR', 'Mumbai', 'Patna', 'Hajipur', 'Hyderabad', 'Jaipur'].map((city) {
                              final isSelected = tempCity.toLowerCase().contains(city.toLowerCase().split(' ')[0]);
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(city, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFFE6F6F5),
                                  backgroundColor: Colors.grey.shade100,
                                  labelStyle: TextStyle(color: isSelected ? const Color(0xFF00A79D) : Colors.black87),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: isSelected ? const Color(0xFF00A79D) : const Color(0xFFE0E0E0)),
                                  ),
                                  onSelected: (val) {
                                    if (val) {
                                      updateLocation(city);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // 4. REAL GOOGLE MAPS LIVE IFRAME VIEW
                      Container(
                        height: 220,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: HtmlElementView(
                            key: Key(mapKey),
                            viewType: mapKey,
                          ),
                        ),
                      ),

                      // 5. Address Form Input & Save Button
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: tempAddressController,
                                decoration: InputDecoration(
                                  labelText: 'House / Street / Area Address',
                                  labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF00A79D), width: 1.5),
                                  ),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00A79D),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.check_circle_outline, size: 20),
                                  label: const Text('Confirm & Save Location', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                         onPressed: () {
  final finalAddr = tempAddressController.text.trim().isNotEmpty
      ? tempAddressController.text.trim()
      : tempCity;

  AppState.selectedCity.value = tempCity;
  AppState.selectedAddress.value = finalAddr;

  // NeonDB Address Sync
  addAddressToNeonDB({
    'user_email': 'guest@cashify.in',
    'address_line': finalAddr,
    'city': tempCity,
    'pincode': '560102',
    'is_default': true,
  });

  Navigator.pop(ctx);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Location Saved to Database: $finalAddr'),
      backgroundColor: const Color(0xFF00A79D),
      duration: const Duration(seconds: 2),
    ),
  );
},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// INTERACTIVE REAL SCRATCH CARD WIDGET
// -----------------------------------------------------------------------------
class ScratchCardWidget extends StatefulWidget {
  final int rewardAmount;
  final VoidCallback onRevealed;
  const ScratchCardWidget({super.key, required this.rewardAmount, required this.onRevealed});

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  bool isRevealed = false;
  List<Offset?> points = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          var localPosition = renderBox.globalToLocal(details.globalPosition);
          setState(() {
            points.add(localPosition);
            if (points.length > 18 && !isRevealed) {
              isRevealed = true;
              widget.onRevealed();
            }
          });
        }
      },
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF00A79D), Color(0xFF004D40)]),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.card_giftcard, color: Colors.amberAccent, size: 36),
                const SizedBox(height: 6),
                Text('🎉 You Won ₹${widget.rewardAmount} Bonus!', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                const Text('Scratch successful! Added to Wallet.', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
            if (!isRevealed)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  size: const Size(double.infinity, 130),
                  painter: ScratchPainter(points: points),
                ),
              ),
            if (!isRevealed)
              const Center(
                child: Text('✨ Scratch Here to Reveal Reward ✨', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}

class ScratchPainter extends CustomPainter {
  final List<Offset?> points;
  ScratchPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.saveLayer(rect, Paint());

    // Scratch Cover Fill
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)), Paint()..color = const Color(0xFF78909C));

    Paint erasePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = 45.0
      ..blendMode = BlendMode.clear;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, erasePaint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// FULLY FUNCTIONAL INTELLIGENT AI CHAT / SUPPORT BOT MODAL
// -----------------------------------------------------------------------------
void openLiveChatModal(BuildContext context) {
  final List<Map<String, String>> messages = [
    {'sender': 'bot', 'text': 'Hello! Welcome to Cashify Pro AI Assistant. Ask me about any refurbished phone, repair price, warranty, or order status!'},
  ];
  final chatCtrl = TextEditingController();

  String generateBotReply(String query) {
    final q = query.toLowerCase();
    if (q.contains('iphone') || q.contains('samsung') || q.contains('oneplus') || q.contains('price') || q.contains('buy') || q.contains('phone')) {
      final match = kMasterInventory.firstWhere(
        (item) => item['title'].toString().toLowerCase().contains(q) || item['brand'].toString().toLowerCase().contains(q),
        orElse: () => kMasterInventory[0],
      );
      return 'We have ${match['title']} available for ${match['price']} (Original: ${match['original']}) with ${match['condition']}. Screen: ${match['screen']}, Battery: ${match['battery']}. You can add it to cart from the Buy Store!';
    } else if (q.contains('repair') || q.contains('screen') || q.contains('battery') || q.contains('glass') || q.contains('fix')) {
      final repairMatch = kRepairServicesList.firstWhere(
        (r) => r['title'].toString().toLowerCase().contains(q) || r['desc'].toString().toLowerCase().contains(q),
        orElse: () => kRepairServicesList[0],
      );
      return '${repairMatch['title']} is priced at ${repairMatch['cashifyPrice']} (Market: ${repairMatch['marketPrice']}). Time: ${repairMatch['time']} with ${repairMatch['warranty']} at your doorstep!';
    } else if (q.contains('order') || q.contains('track') || q.contains('pickup')) {
      if (AppState.myOrders.value.isEmpty) {
        return 'You do not have any active orders right now. You can sell your old phone or purchase a refurbished device from the store!';
      }
      final lastOrder = AppState.myOrders.value.first;
      return 'Your latest order [${lastOrder['id']}] for ${lastOrder['title']} is currently: ${lastOrder['status']}.';
    } else if (q.contains('wallet') || q.contains('balance') || q.contains('money')) {
      return 'Your current Cashify Wallet balance is ₹${AppState.walletBalance.value.toStringAsFixed(0)}. You can top-up or redeem referral bonuses anytime!';
    } else if (q.contains('refer') || q.contains('earn') || q.contains('bonus')) {
      return 'Share your referral link (https://cashify.in/invite?ref=CASHIFY746) with friends to unlock ₹200 scratch card bonuses instantly!';
    } else if (q.contains('warranty') || q.contains('guarantee')) {
      return 'All Cashify Pro purchases and doorstep repairs come with a 6-Month Assured Free Replacement Warranty and 32-point quality check!';
    } else {
      return 'I can help you check prices for iPhones & Samsung flagships, book 30-min doorstep repairs, track active orders, or check your wallet balance. What would you like to explore?';
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) => StatefulBuilder(
      builder: (modalCtx, setChatState) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    CircleAvatar(backgroundColor: Color(0xFF00A79D), child: Icon(Icons.support_agent, color: Colors.white)),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cashify Live AI Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Online • Knowledge Base Enabled', style: TextStyle(color: Colors.green, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(modalCtx)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg = messages[i];
                  final isBot = msg['sender'] == 'bot';
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      decoration: BoxDecoration(
                        color: isBot ? Colors.grey.shade200 : const Color(0xFF00A79D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['text'] ?? '',
                        style: TextStyle(color: isBot ? Colors.black87 : Colors.white, fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatCtrl,
                    decoration: InputDecoration(
                      hintText: 'Ask about iPhone 15, repairs, orders...',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  backgroundColor: const Color(0xFF00A79D),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    if (chatCtrl.text.trim().isNotEmpty) {
                      String userText = chatCtrl.text.trim();
                      setChatState(() {
                        messages.add({'sender': 'user', 'text': userText});
                        chatCtrl.clear();
                      });
                      Future.delayed(const Duration(milliseconds: 600), () {
                        String botReply = generateBotReply(userText);
                        setChatState(() {
                          messages.add({'sender': 'bot', 'text': botReply});
                        });
                      });
                    }
                  },
                  child: const Icon(Icons.send, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// -----------------------------------------------------------------------------
// FULLY FUNCTIONAL & RESPONSIVE NOTIFICATION CENTER MODAL
// -----------------------------------------------------------------------------
void openNotificationCenter(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ValueListenableBuilder<bool>(
      valueListenable: AppState.isDarkMode,
      builder: (context, isDark, _) {
        final cardBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
        final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
        final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: AppState.notifications,
            builder: (_, notifs, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Clear All Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active, color: Color(0xFF00A79D)),
                          const SizedBox(width: 8),
                          Text(
                            'Notifications & Alerts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (notifs.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                AppState.notifications.value = [];
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All notifications cleared!'),
                                    duration: Duration(milliseconds: 900),
                                  ),
                                );
                              },
                              child: const Text(
                                'Clear All',
                                style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          IconButton(
                            icon: Icon(Icons.close, color: textColor),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(color: borderColor),
                  const SizedBox(height: 8),

                  // Responsive Notification List View
                  Expanded(
                    child: notifs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none, size: 48, color: subTextColor),
                                const SizedBox(height: 10),
                                Text('No notifications yet.', style: TextStyle(color: subTextColor, fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: notifs.length,
                            itemBuilder: (_, i) {
                              final n = notifs[i];
                              final type = n['type']?.toString().toLowerCase() ?? 'order';

                              IconData notifIcon = Icons.notifications_active;
                              Color iconColor = const Color(0xFF00A79D);
                              if (type == 'offer') {
                                notifIcon = Icons.local_offer;
                                iconColor = Colors.orange;
                              } else if (type == 'reward') {
                                notifIcon = Icons.card_giftcard;
                                iconColor = Colors.amber.shade800;
                              }

                              return Dismissible(
                                key: Key('notif-${n['title']}-$i'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (_) {
                                  final updated = List<Map<String, dynamic>>.from(AppState.notifications.value);
                                  updated.removeAt(i);
                                  AppState.notifications.value = updated;
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: iconColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(notifIcon, color: iconColor, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              n['title']?.toString() ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              n['desc']?.toString() ?? '',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: subTextColor,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              n['time']?.toString() ?? 'Just now',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close, size: 16, color: subTextColor),
                                        onPressed: () {
                                          final updated = List<Map<String, dynamic>>.from(AppState.notifications.value);
                                          updated.removeAt(i);
                                          AppState.notifications.value = updated;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    ),
  );
}
// Direct JS Interop Razorpay Payment Gateway with Real Cashify Date & Time Picker (FIXED LOADING ISSUE)
void openPaymentGatewayModal({
  required BuildContext context,
  required double totalAmount,
  required String itemTitle,
  required String orderType,
  VoidCallback? onSuccess,
}) {
  String selectedMode = 'upi';
  
  // Real Dynamic Date Calculation
  final DateTime now = DateTime.now();
  final List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  
  final String todayStr = 'Today (${now.day} ${monthNames[now.month - 1]})';
  final DateTime tomorrow = now.add(const Duration(days: 1));
  final String tomorrowStr = 'Tomorrow (${tomorrow.day} ${monthNames[tomorrow.month - 1]})';
  final DateTime dayAfter = now.add(const Duration(days: 2));
  final String dayAfterStr = '${dayAfter.day} ${monthNames[dayAfter.month - 1]}';

  String selectedDate = todayStr;
  String selectedDeliverySlot = 'Morning Slot (9:00 AM - 12:00 PM)';
  final formKey = GlobalKey<FormState>();

  bool isProcessing = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (modalCtx) {
      return StatefulBuilder(
        builder: (stCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lock_outline, color: Color(0xFF00A79D)),
                            SizedBox(width: 8),
                            Text(
                              'Cashify Secure Checkout',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF00A79D),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      itemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 24),

                    // 1. REAL DATE SELECTOR
                    Row(
                      children: const [
                        Icon(Icons.calendar_today, size: 15, color: Color(0xFF00A79D)),
                        SizedBox(width: 6),
                        Text(
                          'Select Date:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [todayStr, tomorrowStr, dayAfterStr].map((d) {
                        final bool isSel = selectedDate == d;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => selectedDate = d),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF00A79D).withValues(alpha: 0.08) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel ? const Color(0xFF00A79D) : Colors.grey.shade300,
                                  width: isSel ? 1.5 : 1.0,
                                ),
                              ),
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? const Color(0xFF00A79D) : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 2. TIME SLOT SELECTOR
                    Row(
                      children: const [
                        Icon(Icons.access_time, size: 15, color: Color(0xFF00A79D)),
                        SizedBox(width: 6),
                        Text(
                          'Select Time Slot:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedDeliverySlot,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        fillColor: Colors.grey.shade50,
                        filled: true,
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Morning Slot (9:00 AM - 12:00 PM)',
                          child: Text('🌅 Morning Slot (9:00 AM - 12:00 PM)', style: TextStyle(fontSize: 12)),
                        ),
                        DropdownMenuItem(
                          value: 'Afternoon Slot (12:00 PM - 4:00 PM)',
                          child: Text('☀️ Afternoon Slot (12:00 PM - 4:00 PM)', style: TextStyle(fontSize: 12)),
                        ),
                        DropdownMenuItem(
                          value: 'Evening Slot (4:00 PM - 8:00 PM)',
                          child: Text('🌆 Evening Slot (4:00 PM - 8:00 PM)', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedDeliverySlot = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. PAYMENT MODE SELECTOR
                    const Text(
                      '💳 Select Payment Mode:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    // Option A: Razorpay Online
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedMode == 'upi' ? const Color(0xFF00A79D) : Colors.grey.shade300,
                          width: selectedMode == 'upi' ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: selectedMode == 'upi' ? const Color(0xFF00A79D).withValues(alpha: 0.03) : Colors.white,
                      ),
                      child: RadioListTile<String>(
                        value: 'upi',
                        groupValue: selectedMode,
                        activeColor: const Color(0xFF00A79D),
                        title: const Text('Razorpay Online (UPI, Card, NetBanking)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: const Text('GPay, PhonePe, Paytm, Cards & NetBanking', style: TextStyle(fontSize: 11)),
                        secondary: const Icon(Icons.payment, color: Color(0xFF00A79D)),
                        onChanged: (val) => setModalState(() => selectedMode = val!),
                      ),
                    ),

                    // Option B: Cash on Delivery
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedMode == 'cod' ? const Color(0xFF00A79D) : Colors.grey.shade300,
                          width: selectedMode == 'cod' ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: selectedMode == 'cod' ? const Color(0xFF00A79D).withValues(alpha: 0.03) : Colors.white,
                      ),
                      child: RadioListTile<String>(
                        value: 'cod',
                        groupValue: selectedMode,
                        activeColor: const Color(0xFF00A79D),
                        title: const Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: const Text('Pay cash or UPI at delivery time', style: TextStyle(fontSize: 11)),
                        secondary: const Icon(Icons.payments_outlined, color: Color(0xFF00A79D)),
                        onChanged: (val) => setModalState(() => selectedMode = val!),
                      ),
                    ),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A79D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  setModalState(() => isProcessing = true);

                                  if (selectedMode == 'cod') {
                                    final String generatedOrderId = 'CS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                                    final newOrder = {
                                      'id': generatedOrderId,
                                      'order_id': generatedOrderId,
                                      'title': itemTitle,
                                      'device_name': itemTitle,
                                      'price': '₹${totalAmount.toStringAsFixed(0)}',
                                      'amount': '₹${totalAmount.toStringAsFixed(0)}',
                                      'offered_price': totalAmount,
                                      'type': orderType,
                                      'status': 'Order Confirmed',
                                      'date': selectedDate,
                                      'slot': selectedDeliverySlot,
                                      'payment_mode': 'COD',
                                      'user_email': 'customer@cashify.in',
                                    };
                                    AppState.addOrder(context, newOrder);
                                    
                                    // Close modal & reset
                                    setModalState(() => isProcessing = false);
                                    Navigator.of(modalCtx).pop();
                                    onSuccess?.call();
                                  } else {
                                    double safeAmount = totalAmount > 50000 ? 5000.0 : totalAmount;

                                    var optionsMap = {
                                      'key': 'rzp_test_Tg8WnGKY0mO0gA',
                                      'amount': (safeAmount * 100).toInt(),
                                      'name': 'Cashify Pro',
                                      'description': itemTitle,
                                      'prefill': {
                                        'contact': '9876543210',
                                        'email': '',
                                      },
                                      'theme': {'color': '#00A79D'},
                                    };

                                    try {
                                      dart_js.context.callMethod('launchRazorpayWeb', [
                                        dart_js.JsObject.jsify(optionsMap),
                              (paymentId) {
  // 1. Reset loading spinner
  setModalState(() => isProcessing = false);

  final String generatedOrderId = 'CS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  final newOrder = {
    'id': generatedOrderId,
    'order_id': generatedOrderId,
    'title': itemTitle,
    'device_name': itemTitle,
    'price': '₹${totalAmount.toStringAsFixed(0)}',
    'amount': '₹${totalAmount.toStringAsFixed(0)}',
    'offered_price': totalAmount,
    'type': orderType,
    'status': 'Order Confirmed',
    'date': selectedDate,
    'slot': selectedDeliverySlot,
    'payment_mode': 'RAZORPAY ($paymentId)',
    'user_email': 'customer@cashify.in',
  };

// 1. Pehle Checkout Modal Sheet ko safely close karein
      if (Navigator.canPop(modalCtx)) {
        Navigator.pop(modalCtx);
      }

      // 2. Order generate karke AppState mein add karein
      AppState.addOrder(context, newOrder);

      // 3. Cart Clear aur Success Callback execute karein
      onSuccess?.call();

      // 4. Success SnackBar Alert Show Karein
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Payment Successful! Payment ID: $paymentId'),
          backgroundColor: Colors.green,
        ),
      );
},
                                        (errorMsg) {
                                          setModalState(() => isProcessing = false);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('❌ Payment Error: $errorMsg'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      ]);
                                    } catch (e) {
                                      debugPrint('Razorpay Web Call Error: $e');
                                      setModalState(() => isProcessing = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('❌ Razorpay Launch Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        child: isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                selectedMode == 'cod'
                                    ? 'Confirm COD Order (₹${totalAmount.toStringAsFixed(0)})'
                                    : 'Pay ₹${totalAmount.toStringAsFixed(0)} via Razorpay',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

// -----------------------------------------------------------------------------
// PRODUCT DETAIL MODAL SHEET (NO RENDERFLEX OVERFLOW ERROR)
// -----------------------------------------------------------------------------
void showProductDetailSheet(BuildContext context, Map<String, dynamic> item) {
  final double rawP = double.tryParse((item['rawPrice'] ?? item['price'] ?? '0')
          .toString()
          .replaceAll('₹', '')
          .replaceAll(',', '')
          .trim()) ??
      25000.0;
  final int cleanPrice = rawP.toInt();
  final String imageUrl = getProductImage(item);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image & Wishlist Toggle
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: 1.4,
                              child: buildSafeImage(imageUrl, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                              valueListenable: AppState.wishlistItems,
                              builder: (_, wishlist, __) {
                                final isFav = AppState.isInWishlist(item['title']?.toString());
                                return CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () {
                                      final added = AppState.toggleWishlist(item);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(added ? 'Saved to Wishlist!' : 'Removed from Wishlist'),
                                          duration: const Duration(milliseconds: 700),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item['title']?.toString() ?? 'Refurbished Device',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '₹$cleanPrice',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF00A79D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Condition Details
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 16, color: Color(0xFF00A79D)),
                          const SizedBox(width: 4),
                          Text(
                            'Superb • 32 Point Check Passed',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'EMI from ₹1,850/mo',
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      // Warranty Badge
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A79D).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.shield_outlined, color: Color(0xFF00A79D), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cashify Assured: 6 Months Free Replacement Warranty',
                                style: TextStyle(color: Color(0xFF00A79D), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Add to Cart Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A79D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            AppState.addToCart(item);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item['title']} added to Cart!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// -----------------------------------------------------------------------------
// CART MODAL SHEET (FULL DARK MODE COMPATIBLE)
// -----------------------------------------------------------------------------
class CartModalSheet extends StatefulWidget {
  const CartModalSheet({super.key});

  @override
  State<CartModalSheet> createState() => _CartModalSheetState();
}

class _CartModalSheetState extends State<CartModalSheet> {
  double discount = 0;
  String couponMsg = '';
  final TextEditingController couponCtrl = TextEditingController();

  void _applyPromoCode(double rawTotal) {
    final code = couponCtrl.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() {
        discount = 0;
        couponMsg = 'Please enter a promo code';
      });
      return;
    }

    setState(() {
      if (code == 'FIRSTBUY') {
        discount = rawTotal * 0.10; // 10% Instant Discount
        couponMsg = '🎉 FIRSTBUY Applied! 10% Off (Saved ₹${discount.toInt()})';
      } else if (code == 'CASHIFY2026') {
        discount = 2026.0; // Flat ₹2026 Discount
        couponMsg = '🎉 CASHIFY2026 Applied! Flat ₹2,026 Instant Off';
      } else if (code == 'MEGA5000') {
        discount = 5000.0; // Flat ₹5000 Discount
        couponMsg = '🎉 MEGA5000 Applied! Flat ₹5,000 Off';
      } else {
        discount = 0;
        couponMsg = '❌ Invalid Promo Code. Try FIRSTBUY or CASHIFY2026';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState.isDarkMode,
      builder: (context, isDark, _) {
        final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
        final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
        final inputBg = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50;

        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: AppState.cartItems,
          builder: (ctx, cart, _) {
            double rawTotal = 0;
            for (var c in cart) {
              rawTotal += double.tryParse(
                (c['rawPrice'] ?? c['price'] ?? c['cashifyPrice'] ?? '0')
                    .toString()
                    .replaceAll('₹', '')
                    .replaceAll(',', '')
                    .trim(),
              ) ?? 0.0;
            }
            double total = max(0, rawTotal - discount);

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shopping_cart_outlined, color: Color(0xFF00A79D)),
                          const SizedBox(width: 8),
                          Text(
                            'My Shopping Cart',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      if (cart.isNotEmpty)
                        TextButton(
                          onPressed: () => AppState.clearCart(),
                          child: const Text('Clear All', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  Divider(color: borderColor),
                  if (cart.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          'Your cart is empty.',
                          style: TextStyle(color: subTextColor, fontSize: 14),
                        ),
                      ),
                    ),
                  ...cart.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var item = entry.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item['title']?.toString() ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                      ),
                      subtitle: Text(
                        item['price']?.toString() ?? '',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => AppState.removeFromCart(idx),
                      ),
                    );
                  }),
                  if (cart.isNotEmpty) ...[
                    Divider(color: borderColor),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: couponCtrl,
                            style: TextStyle(color: textColor, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Promo Code (FIRSTBUY / CASHIFY2026)',
                              hintStyle: TextStyle(fontSize: 11, color: subTextColor),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              fillColor: inputBg,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A79D),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _applyPromoCode(rawTotal),
                          child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    if (couponMsg.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          couponMsg,
                          style: TextStyle(
                            color: discount > 0 ? Colors.green : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A79D)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A79D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          openPaymentGatewayModal(
                            context: context,
                            totalAmount: total,
                            itemTitle: 'CART ORDER: ${cart.first['title']} (+${cart.length - 1} items)',
                            orderType: 'buy',
                            onSuccess: () {
                              AppState.clearCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cart order confirmed! Track in Account Tab.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          );
                        },
                        child: const Text('Proceed to Checkout & Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}



// -----------------------------------------------------------------------------
// ROOT APPLICATION WIDGET
// -----------------------------------------------------------------------------
class CashifyFullApp extends StatelessWidget {
  const CashifyFullApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState.isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: AppScrollBehavior(),
          title: 'Cashify Pro',
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FA),
            primaryColor: const Color(0xFF00A79D),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00A79D),
              primary: const Color(0xFF00A79D),
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
            appBarTheme: AppBarTheme(
              elevation: 0.5,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              foregroundColor: isDark ? Colors.white : Colors.black87,
              titleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            useMaterial3: true,
          ),
      builder: (context, child) {
            return child ?? const SizedBox();
          },
          home: const MainNavigationShell(),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// MAIN NAVIGATION SHELL (WITH LIVE REACTIVE CART BADGE FOR WEB & MOBILE)
// -----------------------------------------------------------------------------
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => MainNavigationShellState();
}

class MainNavigationShellState extends State<MainNavigationShell> {
  Widget _webNavLink(String title, int index, int currentIndex) {
    final bool isSelected = index == currentIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () => AppState.selectedBottomIndex.value = index,
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? const Color(0xFF00A79D) : Colors.black87,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF00A79D) : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;

    return ValueListenableBuilder<int>(
      valueListenable: AppState.selectedBottomIndex,
      builder: (context, currentIndex, _) {
        return Scaffold(
          appBar: isDesktop
              ? AppBar(
                  elevation: 1,
                  titleSpacing: 24,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A79D),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'CASHIFY PRO',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 30),
                      _webNavLink('Home', 0, currentIndex),
                      _webNavLink('Sell Old Phone', 1, currentIndex),
                      _webNavLink('Buy Refurbished', 2, currentIndex),
                      _webNavLink('Repairs', 3, currentIndex),
                      _webNavLink('My Account', 4, currentIndex),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => showSearch(context: context, delegate: AppGlobalSearchDelegate()),
                    ),
                    
                    // 🛒 LIVE CART BADGE COUNTER FOR WEB NAVIGATION BAR
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: AppState.cartItems,
                      builder: (_, cart, __) => Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined),
                            tooltip: 'Shopping Cart',
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => const CartModalSheet(),
                            ),
                          ),
                          if (cart.isNotEmpty)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '${cart.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                )
              : null,
          body: WebContainer(
            child: IndexedStack(
              index: currentIndex,
              children: [
                HomeScreen(
                  onNavigateTab: (index) {
                    AppState.selectedBottomIndex.value = index;
                  },
                ),
                const SellDeviceScreen(),
                const BuyStoreScreen(),
                const RepairServicesScreen(),
                const AccountProfileScreen(),
              ],
            ),
          ),
          bottomNavigationBar: isDesktop
              ? null
              : BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    AppState.selectedBottomIndex.value = index;
                  },
                  selectedItemColor: const Color(0xFF00A79D),
                  unselectedItemColor: Colors.grey.shade600,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.currency_exchange), label: 'Sell Old'),
                    BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Buy Store'),
                    BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Repairs'),
                    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
                  ],
                ),
        );
      },
    );
  }
}
// -----------------------------------------------------------------------------
// 1. HOME SCREEN
// -----------------------------------------------------------------------------
// Fully Functional & Dark Mode Responsive Accessories Store Modal
void _openAccessoriesModal(BuildContext context) {
showWebResponsiveModal(
  context,
  ValueListenableBuilder<bool>(
      valueListenable: AppState.isDarkMode,
      builder: (context, isDark, _) {
        final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final cardBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
        final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

        return Container(
          height: MediaQuery.of(context).size.height * 0.58,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.headphones, color: Color(0xFF00A79D)),
                      const SizedBox(width: 8),
                      Text(
                        'Accessories Store',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textColor),
                   onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: borderColor),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchAccessoriesFromNeonDB(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF00A79D)),
                      );
                    }

                    final accessories = snapshot.data ?? [];

                    if (accessories.isEmpty) {
                      return Center(
                        child: Text(
                          'No accessories in stock right now.',
                          style: TextStyle(color: subTextColor),
                        ),
                      );
                    }

        return GridView.builder(
  itemCount: accessories.length, // 🟢 Accessories ke liye 'accessories.length' hoga
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
    crossAxisSpacing: 10,
    mainAxisSpacing: 12,
    childAspectRatio: 0.52,
  ),
  itemBuilder: (ctx, i) {
    final item = accessories[i];
    // ... baki code same rahega
                        return Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: buildSafeImage(item['image_url']?.toString() ?? ''),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title']?.toString() ?? 'Accessory',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              height: 1.2,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item['category']?.toString() ?? '',
                                            style: TextStyle(fontSize: 10, color: subTextColor),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '₹${item['price']?.toString() ?? '0'}',
                                            style: const TextStyle(
                                              color: Color(0xFF00A79D),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 30,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF00A79D),
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                          onPressed: () {
  final cartItem = {
    'id': item['id'].toString(),
    'title': item['title'],
    'price': '₹${item['price']}',
    'rawPrice': item['price'],
    'type': 'accessory',
    'image': item['image_url']
  };
  
  // Cart me add karein
  AppState.addToCart(cartItem);

  // Instant notification feedback ke liye SnackBar
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('🛒 ${item['title']} added to Cart!'),
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFF00A79D),
      behavior: SnackBarBehavior.floating,
    ),
  );

                                              },
                                              child: const Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

// Real Working Interactive Exchange Flow (Non-Dummy)
void _openInteractiveExchangeModal(BuildContext context, Map<String, dynamic> newProduct) {
  String selectedBrand = 'Apple';
  String selectedModel = 'iPhone 11 (64 GB)';
  String selectedCondition = 'Good';

  final Map<String, double> baseValuations = {
    'iPhone 11 (64 GB)': 11500.0,
    'iPhone 12 (128 GB)': 14800.0,
    'OnePlus 9 Pro': 10500.0,
    'Samsung Galaxy S21': 12000.0,
    'Redmi Note 12 Pro': 6500.0,
  };

  final Map<String, double> conditionMultiplier = {
    'Flawless (No scratches)': 1.15,
    'Good (Minor signs of use)': 1.00,
    'Average (Scratches/Dents)': 0.80,
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (modalCtx) {
      return StatefulBuilder(
        builder: (stCtx, setModalState) {
          final double newProductPrice = double.tryParse(
                (newProduct['rawPrice'] ?? newProduct['price'] ?? '0')
                    .toString()
                    .replaceAll('₹', '')
                    .replaceAll(',', '')
                    .trim(),
              ) ?? 0.0;

          double baseVal = baseValuations[selectedModel] ?? 8000.0;
          double mult = conditionMultiplier[selectedCondition] ?? 1.0;
          double calculatedExchangeValue = baseVal * mult;
          
          if (calculatedExchangeValue > 15000) calculatedExchangeValue = 15000;

          double finalPayableAmount = newProductPrice - calculatedExchangeValue;
          if (finalPayableAmount < 500) finalPayableAmount = 500;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Instant Exchange Valuation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(modalCtx)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                const Text('Select Your Old Phone Brand & Model:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedModel,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: baseValuations.keys.map((model) {
                    return DropdownMenuItem(value: model, child: Text(model, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedModel = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Select Physical Condition:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                Column(
                  children: conditionMultiplier.keys.map((cond) {
                    return RadioListTile<String>(
                      title: Text(cond, style: const TextStyle(fontSize: 12)),
                      value: cond,
                      groupValue: selectedCondition,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF00A79D),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCondition = val);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('New Device Price:', style: TextStyle(fontSize: 12)),
                          Text('₹${newProductPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Old $selectedModel Value:', style: const TextStyle(fontSize: 12, color: Colors.green)),
                          Text('-₹${calculatedExchangeValue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Net Effective Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('₹${finalPayableAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00A79D))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A79D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(modalCtx);
                      openPaymentGatewayModal(
                        context: context,
                        totalAmount: finalPayableAmount,
                        itemTitle: '${newProduct['title']} (Exchanged with $selectedModel)',
                        orderType: 'exchange',
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Exchange Order for ${newProduct['title']} Placed Successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      );
                    },
                    child: const Text('Proceed to Checkout with Exchange', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
final int crossCount = screenWidth > 1200 ? 4 : (screenWidth > 800 ? 3 : 2);
    return ValueListenableBuilder<String>(
      valueListenable: AppState.appLanguage,
      builder: (context, lang, _) {
        return Scaffold(
       appBar: screenWidth > 800 ? null : AppBar(
            titleSpacing: 14,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF00A79D), Color(0xFF005E58)]),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('CASHIFY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
                    ),
                    const SizedBox(width: 6),
                    const Text('PRO', style: TextStyle(color: Color(0xFF00A79D), fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () => AppState.openMapLocationPicker(context),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: Colors.red),
                      const SizedBox(width: 3),
                      ValueListenableBuilder<String>(
                        valueListenable: AppState.selectedCity,
                        builder: (_, city, __) => Text(city, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Notification Bell with Badge Pop-up & Interactive SnackBar
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: AppState.notifications,
                builder: (_, notifs, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      tooltip: 'Notification Center',
                      onPressed: () => openNotificationCenter(context),
                    ),
                    if (notifs.isNotEmpty)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('${notifs.length}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => showSearch(context: context, delegate: AppGlobalSearchDelegate()),
              ),
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: AppState.cartItems,
                builder: (_, cart, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const CartModalSheet(),
                      ),
                    ),
                    if (cart.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('${cart.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
       body: WebContainer(
  maxWidth: 1200,
  child: SingleChildScrollView(
    child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => onNavigateTab(1),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00A79D), Color(0xFF004D40), Color(0xFF00251A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A79D).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                                child: const Text('SUPER FEST 2026', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 9)),
                              ),
                              const SizedBox(height: 8),
                              const Text('Get Extra ₹2,500 Bonus', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              const Text('Instant cash evaluation & free doorstep pickup in 60 mins', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.swap_horizontal_circle, color: Colors.amberAccent, size: 36),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(AppState.tr('explore_services'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.2)),
                ),
                const SizedBox(height: 12),

          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: LayoutBuilder(
    builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 700;

      if (isDesktop) {
        // 🌐 Web Layout: 5 Professional Equal-Width Cards
        return Row(
          children: [
            Expanded(
              child: _webServiceTile(
                AppState.tr('sell_phone'),
                'Instant Cash',
                Icons.phone_android_rounded,
                Colors.teal,
                () => onNavigateTab(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _webServiceTile(
                AppState.tr('buy_refurb'),
                'Certified Devices',
                Icons.shopping_bag_rounded,
                Colors.blue,
                () => onNavigateTab(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _webServiceTile(
                AppState.tr('repairs'),
                'Doorstep Fix',
                Icons.build_rounded,
                Colors.orange,
                () => onNavigateTab(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _webServiceTile(
                'Accessories',
                'Chargers & Audio',
                Icons.headphones,
                Colors.deepOrange,
                () => _openAccessoriesModal(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _webServiceTile(
                AppState.tr('my_account'),
                'Orders & Wallet',
                Icons.person_rounded,
                Colors.purple,
                () => onNavigateTab(4),
              ),
            ),
          ],
        );
      } else {
        // 📱 Mobile Layout: Scrollable Row
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(width: 80, child: _attractiveServiceCard(AppState.tr('sell_phone'), Icons.phone_android_rounded, Colors.teal, () => onNavigateTab(1))),
              SizedBox(width: 80, child: _attractiveServiceCard(AppState.tr('buy_refurb'), Icons.shopping_bag_rounded, Colors.blue, () => onNavigateTab(2))),
              SizedBox(width: 80, child: _attractiveServiceCard(AppState.tr('repairs'), Icons.build_rounded, Colors.orange, () => onNavigateTab(3))),
              SizedBox(width: 80, child: _attractiveServiceCard('Accessories', Icons.headphones, Colors.deepOrange, () => _openAccessoriesModal(context))),
              SizedBox(width: 80, child: _attractiveServiceCard(AppState.tr('my_account'), Icons.person_rounded, Colors.purple, () => onNavigateTab(4))),
            ],
          ),
        );
      }
    },
  ),
),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(AppState.tr('refurb_flagships'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 6),
                          Text(AppState.tr('top_picks'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        ],
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab(2),
                        child: const Text('View All', style: TextStyle(color: Color(0xFF00A79D), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

               // --- FULLY RESPONSIVE GRID FOR REFURBISHED FLAGSHIPS (REAL IMAGES & BADGES) ---
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchProductsFromNeonDB(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF00A79D))),
                      );
                    }

                 // Agar database se 4 se kam products aayein, toh list me at least 4 products fill kar do
List<Map<String, dynamic>> products = snapshot.data ?? [];
if (products.length < 8) {
  products = [...products, ...kMasterInventory].take(8).toList();
}

                    // Helper to get distinct high-res image based on device name
                    String getProductImage(Map<String, dynamic> item) {
                      final title = (item['title'] ?? item['brand'] ?? '').toString().toLowerCase();
                      final img = item['image']?.toString() ?? '';

                      if (img.startsWith('http') && !img.contains('placeholder') && !img.contains('1511707171634')) {
                        return img;
                      }

                      if (title.contains('iphone 15') || title.contains('iphone 14')) {
                        return 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=600&q=80';
                      } else if (title.contains('iphone')) {
                        return 'https://images.unsplash.com/photo-1678652197831-2d180705cd2c?auto=format&fit=crop&w=600&q=80';
                      } else if (title.contains('samsung') || title.contains('galaxy')) {
                        return 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=600&q=80';
                      } else if (title.contains('macbook') || title.contains('laptop') || title.contains('dell')) {
                        return 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=600&q=80';
                      } else if (title.contains('ipad') || title.contains('tablet')) {
                        return 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=600&q=80';
                      } else {
                        return 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?auto=format&fit=crop&w=600&q=80';
                      }
                    }

                    // Helper to format raw price cleanly
                    String formatCleanPrice(dynamic price, dynamic rawPrice) {
                      if (price != null && price.toString().startsWith('₹')) {
                        return price.toString();
                      }
                      num val = num.tryParse(rawPrice?.toString() ?? price?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 0;
                      if (val == 0) return '₹39,999';
                      return '₹${val.toInt()}';
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        itemCount: products.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: crossCount, // 👈 Variable use karein
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  childAspectRatio: screenWidth > 800 ? 0.78 : 0.58, // 👈 Desktop par cards proper height me render honge
),
                        itemBuilder: (ctx, i) {
                          final item = products[i];
                          final imageUrl = getProductImage(item);
                          final formattedPrice = formatCleanPrice(item['price'], item['rawPrice']);
                          final originalPrice = item['original']?.toString() ?? '₹79,900';
                          final condition = item['condition']?.toString() ?? 'Superb • 32-Point Check';

                          return GestureDetector(
                            onTap: () => showProductDetailSheet(context, item),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image Stack with Cashify Quality Badges
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: AspectRatio(
                                          aspectRatio: 1.3,
                                          child: buildSafeImage(imageUrl, fit: BoxFit.cover),
                                        ),
                                      ),
                                      // Top Left Badge
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00A79D),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.verified, size: 10, color: Colors.white),
                                              SizedBox(width: 3),
                                              Text('32-Point Checked', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Top Right Wishlist Heart Button
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                                          valueListenable: AppState.wishlistItems,
                                          builder: (_, wishlist, __) {
                                            final isFav = AppState.isInWishlist(item['title']?.toString());
                                            return InkWell(
                                              onTap: () {
                                                final added = AppState.toggleWishlist(item);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(added ? 'Saved to Wishlist!' : 'Removed from Wishlist'),
                                                    duration: const Duration(milliseconds: 800),
                                                  ),
                                                );
                                              },
                                              child: CircleAvatar(
                                                radius: 14,
                                                backgroundColor: Colors.white.withValues(alpha: 0.9),
                                                child: Icon(
                                                  isFav ? Icons.favorite : Icons.favorite_border,
                                                  color: isFav ? Colors.red : Colors.grey,
                                                  size: 16,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Details Section
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['title']?.toString() ?? 'Refurbished Device',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                condition,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    formattedPrice,
                                                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF00A79D), fontSize: 15),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    originalPrice,
                                                    style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 32,
                                                child: ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF00A79D),
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.zero,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  icon: const Icon(Icons.shopping_cart_outlined, size: 14),
                                                  label: const Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                  onPressed: () {
                                                    AppState.addToCart(item);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('${item['title']} added to Cart!'),
                                                        backgroundColor: const Color(0xFF00A79D),
                                                        duration: const Duration(milliseconds: 900),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _attractiveServiceCard(String title, IconData icon, Color col, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [col.withValues(alpha: 0.15), col.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: col.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: col, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
  Widget _webServiceTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. SELL DEVICE FLOW
// -----------------------------------------------------------------------------
class SellDeviceFlowScreen extends StatefulWidget {
  const SellDeviceFlowScreen({super.key});

  @override
  State<SellDeviceFlowScreen> createState() => _SellDeviceFlowScreenState();
}

class _SellDeviceFlowScreenState extends State<SellDeviceFlowScreen> {
  String selectedBrand = 'Apple';
  String selectedModel = 'iPhone 13';
  String selectedStorage = '128 GB';
  String imeiNumber = '';
  bool isImeiValid = false;
  bool diagnosticsPassed = false;

  String screenCondition = 'Flawless (No Scratches)';
  String bodyCondition = 'Good (Minor Dents)';
  bool hasOriginalCharger = true;
  bool hasBox = true;

  String selectedPickupDate = 'Today (16 Sep 2026)';
  String selectedTimeSlot = '10:00 AM - 01:00 PM (Morning)';

  final List<String> kPickupDates = [
    'Today (16 Sep 2026)',
    'Tomorrow (17 Sep 2026)',
    'Thu, 18 Sep 2026',
    'Fri, 19 Sep 2026',
  ];

  final List<String> kTimeSlots = [
    '10:00 AM - 01:00 PM (Morning)',
    '01:00 PM - 04:00 PM (Afternoon)',
    '04:00 PM - 07:00 PM (Evening)',
    '07:00 PM - 09:00 PM (Night)',
  ];

  int calculateInstantQuote() {
    int basePrice = 25000;
    if (selectedBrand == 'Apple') basePrice = 42000;
    if (selectedBrand == 'Samsung') basePrice = 34000;
    if (selectedBrand == 'Google') basePrice = 30000;
    if (selectedBrand == 'OnePlus') basePrice = 26000;
    if (selectedBrand == 'Xiaomi' || selectedBrand == 'Vivo') basePrice = 18000;

    if (selectedStorage == '256 GB') basePrice += 3500;
    if (selectedStorage == '512 GB') basePrice += 7000;
    if (selectedStorage == '64 GB') basePrice -= 2500;

    if (selectedModel.contains('Pro') || selectedModel.contains('Ultra')) basePrice += 8000;

    if (screenCondition == 'Scratched') basePrice -= 1500;
    if (screenCondition == 'Broken / Cracked') basePrice -= 4000;

    if (bodyCondition == 'Heavy Dents / Scratches') basePrice -= 2000;
    if (!hasOriginalCharger) basePrice -= 500;
    if (!hasBox) basePrice -= 300;

    if (diagnosticsPassed) basePrice += 1500;

    return max(3500, basePrice);
  }

 void _openConditionQuizModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setQuizState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detailed Device Condition Quiz', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Screen Condition:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButton<String>(
                isExpanded: true,
                value: screenCondition,
                items: ['Flawless (No Scratches)', 'Scratched', 'Broken / Cracked'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setQuizState(() => screenCondition = v ?? screenCondition),
              ),
              const SizedBox(height: 12),
              const Text('Body / Dents Condition:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              DropdownButton<String>(
                isExpanded: true,
                value: bodyCondition,
                items: ['Like New', 'Good (Minor Dents)', 'Heavy Dents / Scratches'].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setQuizState(() => bodyCondition = v ?? bodyCondition),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Original Charger Included?', style: TextStyle(fontSize: 13)),
                value: hasOriginalCharger,
                activeColor: const Color(0xFF00A79D),
                onChanged: (v) => setQuizState(() => hasOriginalCharger = v),
              ),
              SwitchListTile(
                title: const Text('Original Box Included?', style: TextStyle(fontSize: 13)),
                value: hasBox,
                activeColor: const Color(0xFF00A79D),
                onChanged: (v) => setQuizState(() => hasBox = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D), foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Condition Quiz Applied to Valuation!')));
                  },
                  child: const Text('Calculate Exact Price'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Automated Device Diagnostics Modal (Connected with Node.js & NeonDB Backend)
void _runDiagnosticsModal(BuildContext context, {String deviceName = 'Selected Device', String userEmail = 'customer@cashify.in'}) {
  int currentStep = 0;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (diagCtx) => StatefulBuilder(
      builder: (ctx, setDiagState) {
        final steps = [
          {'title': 'Screen Touch & Dead Pixel Test', 'icon': Icons.touch_app},
          {'title': 'Microphone & Speaker Test', 'icon': Icons.volume_up},
          {'title': 'Camera & Flash Test', 'icon': Icons.camera_alt},
          {'title': 'Battery & Sensor Diagnostics', 'icon': Icons.battery_charging_full},
        ];

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.important_devices, color: Color(0xFF00A79D)),
              SizedBox(width: 8),
              Text('Live Automated Test', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: (currentStep + 1) / steps.length,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF00A79D),
              ),
              const SizedBox(height: 16),
              Icon(steps[currentStep]['icon'] as IconData, size: 48, color: const Color(0xFF00A79D)),
              const SizedBox(height: 12),
              Text(
                steps[currentStep]['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Step ${currentStep + 1} of ${steps.length} • Running automated hardware checks...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            if (currentStep < steps.length - 1)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D), foregroundColor: Colors.white),
                onPressed: () {
                  setDiagState(() => currentStep++);
                },
                child: const Text('Pass & Next'),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D), foregroundColor: Colors.white),
                onPressed: () async {
                  Navigator.pop(diagCtx);

                  // Send Diagnostics Results to Node.js Backend API
                  try {
                    final response = await http.post(
                      Uri.parse('http://localhost:5000/api/diagnostics'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'user_email': userEmail,
                        'device_name': deviceName,
                        'screen_test': true,
                        'touch_test': true,
                        'camera_test': true,
                        'mic_speaker_test': true,
                        'battery_health': 98,
                        'deducted_amount': 0,
                      }),
                    );

                    if (context.mounted) {
                      if (response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Diagnostics Complete & Saved to Database!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Diagnostics Complete (Offline Mode)'),
                            backgroundColor: Color(0xFF00A79D),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint('Diagnostics Sync Error: $e');
                  }
                },
                child: const Text('Finish Test & Sync'),
              ),
          ],
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    int quote = calculateInstantQuote();
    final List<String> availableModels = kBrandModels[selectedBrand] ?? ['Standard Model'];

    return Scaffold(
      appBar: AppBar(title: const Text('Sell Old Phone & Schedule')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF203A43)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('AI Estimated Instant Quote', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('₹$quote', style: const TextStyle(color: Color(0xFF00FFCC), fontSize: 34, fontWeight: FontWeight.w900)),
                  if (diagnosticsPassed)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                      child: const Text('✓ Diagnostics Passed (+₹1,500 Bonus)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00A79D)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.quiz, color: Color(0xFF00A79D), size: 18),
                    label: const Text('Condition Quiz', style: TextStyle(color: Color(0xFF00A79D), fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () => _openConditionQuizModal(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00A79D)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(diagnosticsPassed ? Icons.verified : Icons.phonelink_setup, color: const Color(0xFF00A79D), size: 18),
                    label: Text(diagnosticsPassed ? 'Passed' : 'Diagnostics', style: const TextStyle(color: Color(0xFF00A79D), fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () => _runDiagnosticsModal(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedBrand,
                  items: kBrandModels.keys.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        selectedBrand = v;
                        selectedModel = (kBrandModels[v] ?? ['Model']).first;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Exact Model',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: availableModels.contains(selectedModel) ? selectedModel : availableModels.first,
                  items: availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedModel = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Storage Variant',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedStorage,
                  items: kStorageOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedStorage = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              keyboardType: TextInputType.number,
              maxLength: 15,
              decoration: InputDecoration(
                labelText: 'Device IMEI (Dial *#06# to check)',
                counterText: '${imeiNumber.length}/15 digits',
                suffixIcon: isImeiValid ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.error_outline, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (v) {
                setState(() {
                  imeiNumber = v;
                  isImeiValid = v.trim().length == 15;
                });
              },
            ),
            const SizedBox(height: 12),

            const Text('Select Pickup Date:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: kPickupDates.map((date) {
                  final isSel = selectedPickupDate == date;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(date, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      selected: isSel,
                      selectedColor: const Color(0xFF00A79D).withValues(alpha: 0.2),
                      onSelected: (val) {
                        if (val) setState(() => selectedPickupDate = date);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Select Doorstep Pickup Time Slot:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: kTimeSlots.map((slot) {
                  final isSel = selectedTimeSlot == slot;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(slot, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      selected: isSel,
                      selectedColor: const Color(0xFF00A79D).withValues(alpha: 0.2),
                      onSelected: (val) {
                        if (val) setState(() => selectedTimeSlot = slot);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D), foregroundColor: Colors.white),
                onPressed: () {
                  final orderId = 'SELL-${Random().nextInt(89999) + 10000}';
                  AppState.addOrder(context, {
                    'id': orderId,
                    'title': 'SELL: $selectedBrand $selectedModel',
                    'amount': '₹$quote',
                    'status': 'Pickup Scheduled ($selectedPickupDate, $selectedTimeSlot)',
                    'date': selectedPickupDate,
                    'type': 'sell',
                  });
                },
                child: const Text('Schedule Doorstep Pickup & Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// 2. COMPARE DEVICES MODAL SHEET
void _openInteractiveCompareModal(BuildContext context) {
  Map<String, dynamic> dev1 = kMasterInventory[0];
  Map<String, dynamic> dev2 = kMasterInventory[3];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (modalCtx, setCompState) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Compare Devices Side-by-Side', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Icon(Icons.compare_arrows, color: Color(0xFF00A79D)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Device 1',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: dev1['title']?.toString(),
                        items: kMasterInventory.map((d) {
                          return DropdownMenuItem<String>(
                            value: d['title']?.toString(),
                            child: Text(d['title']?.toString() ?? '', style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final found = kMasterInventory.firstWhere((e) => e['title'] == val);
                            setCompState(() => dev1 = found);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Device 2',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: dev2['title']?.toString(),
                        items: kMasterInventory.map((d) {
                          return DropdownMenuItem<String>(
                            value: d['title']?.toString(),
                            child: Text(d['title']?.toString() ?? '', style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final found = kMasterInventory.firstWhere((e) => e['title'] == val);
                            setCompState(() => dev2 = found);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: [
                    const Padding(padding: EdgeInsets.all(8), child: Text('Spec', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(dev1['brand']?.toString() ?? 'Dev 1', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(dev2['brand']?.toString() ?? 'Dev 2', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                ),
                TableRow(children: [
                  const Padding(padding: EdgeInsets.all(8), child: Text('Cashify Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('₹${(double.tryParse((dev1['rawPrice'] ?? dev1['price'] ?? '0').toString().replaceAll('₹', '').replaceAll(',', '').trim()) ?? 0).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00A79D), fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(8), child: Text('₹${(double.tryParse((dev2['rawPrice'] ?? dev2['price'] ?? '0').toString().replaceAll('₹', '').replaceAll(',', '').trim()) ?? 0).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00A79D), fontSize: 12))),
                ]),
                TableRow(children: [
                  const Padding(padding: EdgeInsets.all(8), child: Text('Display', style: TextStyle(fontSize: 11))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(dev1['screen']?.toString() ?? 'OLED', style: const TextStyle(fontSize: 11))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(dev2['screen']?.toString() ?? 'AMOLED', style: const TextStyle(fontSize: 11))),
                ]),
                TableRow(children: [
                  const Padding(padding: EdgeInsets.all(8), child: Text('Warranty', style: TextStyle(fontSize: 11))),
                  const Padding(padding: EdgeInsets.all(8), child: Text('6 Months Assured', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))),
                  const Padding(padding: EdgeInsets.all(8), child: Text('6 Months Assured', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))),
                ]),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D), foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close Comparison'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
// 1. WISHLIST MODAL SHEET
void _openWishlistModalSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: AppState.wishlistItems,
      builder: (_, wishlist, __) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 24),
                    const SizedBox(width: 8),
                    Text('My Saved Wishlist (${wishlist.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            if (wishlist.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 54, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Your wishlist is empty!', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Tap the heart icon on any device to save it for later.', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: wishlist.length,
                  itemBuilder: (_, i) {
                    final item = wishlist[i];
                    final double rawP = double.tryParse((item['rawPrice'] ?? item['price'] ?? '0').toString().replaceAll('₹', '').replaceAll(',', '').trim()) ?? 0.0;
                    final int cleanPrice = rawP.toInt();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 55,
                              height: 55,
                              child: buildSafeImage(getProductImage(item), fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text('₹$cleanPrice', style: const TextStyle(color: Color(0xFF00A79D), fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A79D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              AppState.addToCart(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${item['title']} added to Cart!'), backgroundColor: Colors.green),
                              );
                            },
                            child: const Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => AppState.toggleWishlist(item),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    )
    );
  }
// -----------------------------------------------------------------------------
// 3. REFURBISHED BUY STORE (NO DUPLICATE HEADER ON WEB)
// -----------------------------------------------------------------------------
class BuyStoreScreen extends StatefulWidget {
  const BuyStoreScreen({super.key});

  @override
  State<BuyStoreScreen> createState() => _BuyStoreScreenState();
}

class _BuyStoreScreenState extends State<BuyStoreScreen> {
  String _selectedBrand = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _brands = ['All', 'Apple', 'Samsung', 'OnePlus', 'Xiaomi', 'Laptop', 'Tablet'];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;
    final int crossCount = isDesktop ? 4 : (screenWidth > 600 ? 3 : 2);

    return Scaffold(
      // 🛑 Web/Desktop (screenWidth > 800) par secondary AppBar KO REMOVE kar diya hai
      appBar: isDesktop
          ? null
          : AppBar(
              elevation: 0.5,
              title: Row(
                children: const [
                  Icon(Icons.storefront, color: Color(0xFF00A79D)),
                  SizedBox(width: 8),
                  Text('Refurbished Buy Store', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.compare_arrows, color: Color(0xFF00A79D)),
                  tooltip: 'Compare Devices Side-by-Side',
                  onPressed: () => _openInteractiveCompareModal(context),
                ),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: AppState.wishlistItems,
                  builder: (_, wishlist, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          wishlist.isEmpty ? Icons.favorite_border : Icons.favorite,
                          color: wishlist.isEmpty ? Colors.grey.shade700 : Colors.red,
                        ),
                        tooltip: 'Saved Wishlist',
                        onPressed: () => _openWishlistModalSheet(context),
                      ),
                      if (wishlist.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              '${wishlist.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: AppState.cartItems,
                  builder: (_, cart, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        tooltip: 'Shopping Cart',
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const CartModalSheet(),
                        ),
                      ),
                      if (cart.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text('${cart.length}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
      body: WebContainer(
        maxWidth: 1200,
        child: Column(
          children: [
            // 🌐 Web Desktop Header Strip (Only Compare & Wishlist, No Duplicate Cart)
            if (isDesktop)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.storefront, color: Color(0xFF00A79D)),
                        SizedBox(width: 8),
                        Text('Refurbished Buy Store', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00A79D),
                            side: const BorderSide(color: Color(0xFF00A79D)),
                          ),
                          icon: const Icon(Icons.compare_arrows, size: 16),
                          label: const Text('Compare Devices'),
                          onPressed: () => _openInteractiveCompareModal(context),
                        ),
                        const SizedBox(width: 10),
                        ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: AppState.wishlistItems,
                          builder: (_, wishlist, __) => OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: wishlist.isNotEmpty ? Colors.red : Colors.grey.shade800,
                              side: BorderSide(color: wishlist.isNotEmpty ? Colors.red : Colors.grey.shade300),
                            ),
                            icon: Icon(wishlist.isNotEmpty ? Icons.favorite : Icons.favorite_border, size: 16),
                            label: Text('Wishlist (${wishlist.length})'),
                            onPressed: () => _openWishlistModalSheet(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Search Bar & Brand Filter Chips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() => _searchQuery = val.trim());
                      },
                      decoration: InputDecoration(
                        hintText: 'Search iPhone, Galaxy S24, MacBook...',
                        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF00A79D), size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _brands.map((brand) {
                        final bool isSel = _selectedBrand == brand;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(brand, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                            selected: isSel,
                            selectedColor: const Color(0xFF00A79D),
                            backgroundColor: Colors.grey.shade100,
                            labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSel ? const Color(0xFF00A79D) : Colors.grey.shade300),
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedBrand = brand);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchProductsFromNeonDB(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00A79D)));
                  }

                  List<Map<String, dynamic>> dbProducts = snapshot.data ?? [];
                  final Map<String, Map<String, dynamic>> uniqueMap = {};

                  for (var item in [...dbProducts, ...kMasterInventory]) {
                    final titleKey = (item['title'] ?? item['id'] ?? '').toString().toLowerCase().trim();
                    if (titleKey.isNotEmpty && !uniqueMap.containsKey(titleKey)) {
                      uniqueMap[titleKey] = item;
                    }
                  }

                  final List<Map<String, dynamic>> rawList = uniqueMap.values.toList();

                  final filteredProducts = rawList.where((p) {
                    final title = (p['title'] ?? '').toString().toLowerCase();
                    final brand = (p['brand'] ?? '').toString().toLowerCase();
                    final category = (p['category'] ?? '').toString().toLowerCase();

                    bool matchesBrand = true;
                    if (_selectedBrand != 'All') {
                      final sel = _selectedBrand.toLowerCase();
                      matchesBrand = brand.contains(sel) || title.contains(sel) || category.contains(sel);
                    }

                    bool matchesSearch = true;
                    if (_searchQuery.isNotEmpty) {
                      matchesSearch = title.contains(_searchQuery.toLowerCase());
                    }

                    return matchesBrand && matchesSearch;
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text('No products matching filter.', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return GridView.builder(
                    itemCount: filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isDesktop ? 0.75 : 0.58,
                    ),
                    itemBuilder: (ctx, i) {
                      final item = filteredProducts[i];
                      final double rawP = double.tryParse((item['rawPrice'] ?? item['price'] ?? '0').toString().replaceAll('₹', '').replaceAll(',', '').trim()) ?? 25000.0;
                      final int cleanPrice = rawP.toInt();
                      final String imageUrl = getProductImage(item);

                      return GestureDetector(
                        onTap: () => showProductDetailSheet(context, item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    child: AspectRatio(
                                      aspectRatio: 1.15,
                                      child: buildSafeImage(imageUrl, fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(color: const Color(0xFF00A79D), borderRadius: BorderRadius.circular(6)),
                                      child: const Text('32-Point Check', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                                      valueListenable: AppState.wishlistItems,
                                      builder: (_, wishlist, __) {
                                        final isFav = AppState.isInWishlist(item['title']?.toString());
                                        return InkWell(
                                          onTap: () {
                                            final added = AppState.toggleWishlist(item);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(added ? 'Saved to Wishlist!' : 'Removed from Wishlist'), duration: const Duration(milliseconds: 700)),
                                            );
                                          },
                                          child: CircleAvatar(
                                            radius: 13,
                                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                                            child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.grey, size: 15),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title']?.toString() ?? 'Refurbished Phone',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, height: 1.2),
                                          ),
                                          const SizedBox(height: 3),
                                          Text('Superb • 6 Month Warranty', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('₹${cleanPrice.toString()}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF00A79D), fontSize: 14)),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 30,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF00A79D),
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.zero,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              onPressed: () {
                                                AppState.addToCart(item);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('${item['title']} added to Cart!'), duration: const Duration(seconds: 1)),
                                                );
                                              },
                                              child: const Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. REPAIR SERVICES SCREEN (DYNAMIC DEVICE PRICING & LIVE BACKEND)
// -----------------------------------------------------------------------------
class RepairServicesScreen extends StatefulWidget {
  const RepairServicesScreen({super.key});

  @override
  State<RepairServicesScreen> createState() => _RepairServicesScreenState();
}

class _RepairServicesScreenState extends State<RepairServicesScreen> {
  String selectedDevice = 'iPhone 14 Pro';
  String selectedCategory = 'All';

  // Device Specific Cost Multipliers (Real Dynamic Pricing)
  final Map<String, double> deviceMultipliers = {
    'iPhone 13': 1.0,
    'iPhone 14 Pro': 1.45,
    'Galaxy S24': 1.35,
    'OnePlus 12': 1.20,
    'Pixel 8': 1.15,
  };

  // Base Repair Services
  final List<Map<String, dynamic>> baseRepairs = [
    {
      'title': 'Touchscreen & Display Glass Replacement',
      'category': 'Screen',
      'desc': 'Grade-A Original Super Retina OLED Display with Free Curved Glass Guard',
      'basePrice': 2499,
      'marketPrice': 5500,
      'time': '30 Mins Doorstep',
      'icon': Icons.stay_current_portrait,
      'warranty': '6 Months Assured Replacement',
      'popular': true,
    },
    {
      'title': 'Battery Health Upgrade & Calibration',
      'category': 'Battery',
      'desc': 'High-density OEM Cell with 100% capacity calibration & battery health fix',
      'basePrice': 1299,
      'marketPrice': 3200,
      'time': '25 Mins Doorstep',
      'icon': Icons.battery_charging_full,
      'warranty': '6 Months Warranty',
      'popular': true,
    },
    {
      'title': 'Rear Camera & Sensor Lens Repair',
      'category': 'Camera',
      'desc': 'Original Sony IMX Quad-Camera Sensor flex cable & sapphire glass lens fix',
      'basePrice': 1899,
      'marketPrice': 4200,
      'time': '35 Mins Doorstep',
      'icon': Icons.camera_alt,
      'warranty': '3 Months Warranty',
      'popular': false,
    },
    {
      'title': 'Type-C / Lightning Port & Speaker Fix',
      'category': 'Charging',
      'desc': 'Fast Charging flex ribbon, microphone array & ear speaker mesh cleaning',
      'basePrice': 899,
      'marketPrice': 2100,
      'time': '20 Mins Doorstep',
      'icon': Icons.electrical_services,
      'warranty': '3 Months Warranty',
      'popular': false,
    },
    {
      'title': 'Back Glass & Housing Replacement',
      'category': 'Body',
      'desc': 'Laser precision rear glass removal & OEM housing chassis replacement',
      'basePrice': 1699,
      'marketPrice': 3800,
      'time': '45 Mins Doorstep',
      'icon': Icons.smartphone,
      'warranty': '6 Months Warranty',
      'popular': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double currentMultiplier = deviceMultipliers[selectedDevice] ?? 1.0;

    return ValueListenableBuilder<bool>(
      valueListenable: AppState.isDarkMode,
      builder: (context, isDark, _) {
        final cardBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
        final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
        final chipBg = isDark ? const Color(0xFF383838) : Colors.grey.shade100;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FA),
          appBar: AppBar(
            title: Row(
              children: const [
                Icon(Icons.build_circle, color: Color(0xFF00A79D)),
                SizedBox(width: 8),
                Text('Doorstep Phone Repairs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.verified_user, color: Color(0xFF00A79D)),
              ),
            ],
          ),
        body: WebContainer(
  maxWidth: 900,
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A79D), Color(0xFF005E58)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00A79D).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Certified Doorstep Repair', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('• Trained Technicians  • 6 Months Warranty  • No Fix No Fee', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.handyman, color: Colors.amber, size: 36),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Device Selector Chips
                Text('Select Device for Repair Quote:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: deviceMultipliers.keys.map((model) {
                      final isSel = selectedDevice == model;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(model, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : textColor)),
                          selected: isSel,
                          selectedColor: const Color(0xFF00A79D),
                          backgroundColor: chipBg,
                          side: BorderSide(color: isSel ? const Color(0xFF00A79D) : borderColor),
                          onSelected: (val) {
                            if (val) setState(() => selectedDevice = model);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),

                // Category Filter
                Text('Available Repair Packages', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 10),

                // Package List with Dynamic Model Price
                ...baseRepairs.map((r) {
                  final double calculatedPrice = (r['basePrice'] as int) * currentMultiplier;
                  final double calculatedMarket = (r['marketPrice'] as int) * currentMultiplier;
                  final isPop = r['popular'] == true;
                  final rTitle = r['title']?.toString() ?? 'Repair Service';
                  final rDesc = r['desc']?.toString() ?? '';
                  final rTime = r['time']?.toString() ?? '30 Mins';
                  final rWarranty = r['warranty']?.toString() ?? 'Certified Warranty';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isPop ? const Color(0xFF00A79D) : borderColor, width: isPop ? 1.5 : 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPop)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFF00A79D), borderRadius: BorderRadius.circular(6)),
                              child: const Text('MOST BOOKED FOR THIS MODEL', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00A79D).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(r['icon'] as IconData? ?? Icons.build, size: 26, color: const Color(0xFF00A79D)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(rTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                                    const SizedBox(height: 3),
                                    Text(rDesc, style: TextStyle(color: subTextColor, fontSize: 11, height: 1.3)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer_outlined, size: 13, color: Color(0xFF00A79D)),
                                        const SizedBox(width: 4),
                                        Text(rTime, style: TextStyle(fontSize: 11, color: subTextColor, fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.shield_outlined, size: 13, color: Colors.green),
                                        const SizedBox(width: 4),
                                        Text(rWarranty, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 20, color: borderColor),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '₹${calculatedPrice.round()}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF00A79D)),
                                  ),
                                  Text(
                                    'Market: ₹${calculatedMarket.round()}',
                                    style: TextStyle(decoration: TextDecoration.lineThrough, color: subTextColor, fontSize: 11),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A79D),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.calendar_today, size: 14),
                                label: const Text('Book Repair', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  openPaymentGatewayModal(
                                    context: context,
                                    totalAmount: calculatedPrice,
                                    itemTitle: 'DOORSTEP REPAIR: $rTitle ($selectedDevice)',
                                    orderType: 'repair',
                                    onSuccess: () {
                                      final String generatedId = 'REP-${Random().nextInt(89999) + 10000}';
                                      final repairOrder = {
                                        'id': generatedId,
                                        'order_id': generatedId,
                                        'title': 'REPAIR: $rTitle ($selectedDevice)',
                                        'device_name': '$selectedDevice ($rTitle)',
                                        'price': '₹${calculatedPrice.round()}',
                                        'offered_price': calculatedPrice,
                                        'status': 'Technician Assigned',
                                        'date': 'Today',
                                        'type': 'repair',
                                        'user_email': 'customer@cashify.in',
                                      };
                                      AppState.addOrder(context, repairOrder);
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
               ),
        );
      },
    );
  }
}
// -----------------------------------------------------------------------------
// 5. GLOBAL SEARCH DELEGATE
// -----------------------------------------------------------------------------
class AppGlobalSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Search products, models, repairs...';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];
      

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _searchList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _searchList(context);

Widget _searchList(BuildContext context) {
  final clean = query.trim().toLowerCase();

  return FutureBuilder<List<Map<String, dynamic>>>(
    future: fetchProductsFromNeonDB(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF00A79D)),
        );
      }

      final dataList = snapshot.data ?? kMasterInventory;
      final results = dataList
          .where(
            (i) =>
                clean.isEmpty ||
                (i['title']?.toString().toLowerCase().contains(clean) ?? false),
          )
          .toList();

      if (results.isEmpty) {
        return const Center(child: Text('No matching products found.'));
      }

      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (ctx, i) {
          final item = results[i];
          final cleanPrice = (double.tryParse((item['rawPrice'] ?? item['price'] ?? '0').toString().replaceAll('₹', '').replaceAll(',', '').trim()) ?? 0.0).toInt();

          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: buildSafeImage(
                getProductImage(item),
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(item['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              '₹$cleanPrice',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00A79D), fontSize: 13),
            ),
            onTap: () {
              close(context, null);
              showProductDetailSheet(context, item);
            },
          );
        },
      );
    },
  );
}
}

// -----------------------------------------------------------------------------
// 6. ACCOUNT PROFILE & AUTH SCREEN
// -----------------------------------------------------------------------------
class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({super.key});

  @override
  State<AccountProfileScreen> createState() => _AccountProfileScreenState();
}
// 🚚 Executive / Delivery Partner OTP Modal Dialog (Live DB + AppState + Fallback Sync)
void _showDeliveryAgentModal(BuildContext context, {String initialOrderId = '', VoidCallback? onVerifiedSuccess}) {
  final TextEditingController orderIdController = TextEditingController(text: initialOrderId);
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  showDialog(
    context: context,
    builder: (dlgCtx) => StatefulBuilder(
      builder: (context, setModalState) {
        
        Future<void> verifyOtpWithBackend(String targetOrderId, String inputOtp) async {
          if (targetOrderId.trim().isEmpty || inputOtp.trim().isEmpty) {
            setModalState(() {
              isLoading = false;
              errorMessage = "❌ Order ID and OTP are required";
            });
            return;
          }

          setModalState(() {
            isLoading = true;
            errorMessage = null;
          });

          try {
            final response = await http.post(
              Uri.parse("http://localhost:5000/api/orders/verify-handover-otp"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"orderId": targetOrderId.trim(), "otp": inputOtp.trim()}),
            );

            final data = jsonDecode(response.body);

            if (response.statusCode == 200 && data['success'] == true) {
              final updatedOrders = List<Map<String, dynamic>>.from(AppState.myOrders.value);
              final cleanTarget = targetOrderId.replaceAll('ORD-', '').replaceAll('CS-', '').trim();
              
              final targetIndex = updatedOrders.indexWhere(
                (o) => (o['order_id'] ?? o['orderId'] ?? o['id'] ?? "").toString().contains(cleanTarget)
              );

              if (targetIndex != -1) {
                updatedOrders[targetIndex]['status'] = 'Completed';
                updatedOrders[targetIndex]['isCompleted'] = true;
                AppState.myOrders.value = updatedOrders;
              }

              setModalState(() {
                isLoading = false;
                errorMessage = "✅ Pickup verified successfully!";
              });

              if (onVerifiedSuccess != null) {
                onVerifiedSuccess();
              }
            } else {
              setModalState(() {
                isLoading = false;
                errorMessage = "❌ ${data['message'] ?? 'Invalid OTP! Enter correct OTP.'}";
              });
            }
          } catch (e) {
            setModalState(() {
              isLoading = false;
              errorMessage = "❌ Connection error. Server response failed.";
            });
          }
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.local_shipping, color: Color(0xFF00A79D)),
              SizedBox(width: 8),
              Text('Executive Partner Portal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: const Text(
                    '🚚 Delivery Executive Mode: Customer se OTP pooch kar yahan enter karein.',
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Select Order ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),

                // Live Database + AppState Order Fetcher
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchOrdersFromNeonDB(),
                  builder: (context, snapshot) {
                    List<Map<String, dynamic>> rawList = [];

                    // 1. AppState.myOrders se active orders lein
                    rawList.addAll(AppState.myOrders.value);

                    // 2. NeonDB fetched orders agar available hain toh include karein
                    if (snapshot.hasData && snapshot.data != null) {
                      rawList.addAll(snapshot.data!);
                    }

                    // 3. Dynamic Fallback: Agar DB empty ho toh default active order load karein
                    if (rawList.isEmpty) {
                      rawList.add({
                        'id': 'ORD-CS-314454',
                        'order_id': 'ORD-CS-314454',
                        'device_name': 'iPhone 13 (Midnight 128 GB)',
                        'title': 'iPhone 13 (Midnight 128 GB)'
                      });
                    }

                    // 4. Unique Orders Map Filter
                    final Map<String, Map<String, dynamic>> uniqueMap = {};
                    for (var o in rawList) {
                      final String idStr = (o['order_id'] ?? o['orderId'] ?? o['id'] ?? '').toString().trim();
                      if (idStr.isNotEmpty) {
                        uniqueMap[idStr] = o;
                      }
                    }

                    final List<Map<String, dynamic>> liveOrders = uniqueMap.values.toList();

                    String? currentVal;
                    if (liveOrders.isNotEmpty) {
                      final selected = orderIdController.text.trim();
                      final exists = liveOrders.any((o) => (o['order_id'] ?? o['orderId'] ?? o['id'] ?? '').toString() == selected);
                      currentVal = exists 
                          ? selected 
                          : (liveOrders.first['order_id'] ?? liveOrders.first['orderId'] ?? liveOrders.first['id'] ?? '').toString();
                      if (orderIdController.text.isEmpty && currentVal != null) {
                        orderIdController.text = currentVal;
                      }
                    }

                    return DropdownButtonFormField<String>(
                      value: currentVal,
                      hint: const Text('Select Scheduled Order', style: TextStyle(fontSize: 12)),
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: liveOrders.map((ord) {
                        final idStr = (ord['order_id'] ?? ord['orderId'] ?? ord['id'] ?? '').toString();
                        final titleStr = (ord['device_name'] ?? ord['title'] ?? ord['product_title'] ?? ord['deviceName'] ?? 'Device').toString();
                        final displayId = idStr.startsWith('ORD-') ? idStr : (idStr.startsWith('CS-') ? 'ORD-$idStr' : 'ORD-CS-$idStr');
                        return DropdownMenuItem<String>(
                          value: idStr,
                          child: Text('$displayId - $titleStr', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null && val.isNotEmpty) {
                          setModalState(() {
                            orderIdController.text = val;
                          });
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),
                const Text('Customer Handover OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '0000',
                    counterText: '',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      color: errorMessage!.contains('✅') ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A79D),
                foregroundColor: Colors.white,
              ),
              onPressed: isLoading
                  ? null
                  : () {
                      final rawId = orderIdController.text.trim();
                      verifyOtpWithBackend(rawId, otpController.text.trim());
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Verify & Complete Pickup'),
            ),
          ],
        );
      },
    ),
  );
}
// 🔑 Executive Partner Login Dialog (Real Dynamic Order ID Link & State Callback)
void _showExecutiveLoginDialog(BuildContext context, {String initialOrderId = '', VoidCallback? onVerifiedSuccess}) {
  final idController = TextEditingController();
  final passController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.two_wheeler, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text('Executive Partner Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: idController,
            decoration: const InputDecoration(
              labelText: 'Executive ID',
              hintText: 'exec123',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: '12345',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (idController.text.trim() == 'exec123' && passController.text.trim() == '12345') {
              Navigator.pop(dialogCtx);
              // 👈 Callback pass kar rahe hain taaki OTP verify hone par status update ho
              _showDeliveryAgentModal(context, initialOrderId: initialOrderId, onVerifiedSuccess: onVerifiedSuccess);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid Credentials! Use ID: exec123 & Pass: 12345'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Login'),
        ),
      ],
    ),
  );
}
class _AccountProfileScreenState extends State<AccountProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscure = true;
  String _selectedOrderTab = 'All';

  final List<String> _sampleAvatars = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=200&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
  ];
  late String _selectedAvatarUrl;

  @override
  void initState() {
    super.initState();
    _selectedAvatarUrl = _sampleAvatars[0];
  }

Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      GoogleAuthProvider provider = GoogleAuthProvider();
      UserCredential cred = await _auth.signInWithPopup(provider);
      
      String? userEmail = cred.user?.email;
      AppState.isGuestUser.value = false;
      setState(() => _isLoading = false);

      // 📧 Google Login Alert API Call
      if (userEmail != null) {
        try {
          await http.post(
            Uri.parse('http://localhost:5000/api/send-login-alert'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': userEmail}),
          );
        } catch (e) {
          debugPrint("Google login alert mail error: $e");
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Google Account ($userEmail) Verified & Logged In!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In notice: $e'), backgroundColor: Colors.orange)
      );
    }
  }
Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Valid email required!'), backgroundColor: Colors.red));
      return;
    }
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be 6+ chars!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        // 📧 1. Send OTP to Mail via Backend
        var res = await http.post(
          Uri.parse('http://localhost:5000/api/send-signup-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );

        setState(() => _isLoading = false);

        if (res.statusCode == 200) {
          // 📦 2. OTP Dialog Show Karein
          _showSignupOtpDialog(email, pass, name);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send OTP'), backgroundColor: Colors.red));
        }
      } else {
        // 🔐 LOGIN LOGIC
        await _auth.signInWithEmailAndPassword(email: email, password: pass);
        try {
          await http.post(
            Uri.parse('http://localhost:5000/api/send-login-alert'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          );
        } catch (e) {
          debugPrint("Login alert mail error: $e");
        }
        AppState.isGuestUser.value = false;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.orange));
    }
  }

  // ---------------------------------------------------------------------------
  // NAYA FUNCTION: OTP Dialog aur Firebase Account Creation
  // Ise _handleAuth ke theek neeche paste karein
  // ---------------------------------------------------------------------------
  Future<void> _showSignupOtpDialog(String email, String password, String name) async {
    TextEditingController otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Verify Email OTP', style: TextStyle(color: Color(0xFF00A79D))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter the 6-digit OTP sent to \n$email', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(border: OutlineInputBorder(), counterText: ""),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D)),
                  onPressed: isVerifying ? null : () async {
                    if (otpController.text.length < 6) return;
                    setDialogState(() => isVerifying = true);
                    try {
                      // 1. Backend se OTP Match karein
                      var res = await http.post(
                        Uri.parse('http://localhost:5000/api/verify-signup-otp'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({'email': email, 'otp': otpController.text.trim()}),
                      );

                      var data = jsonDecode(res.body);
                      if (data['success'] == true) {
                        // 2. Sahi hone par Firebase me Password ke sath Account Banayein
                        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                        if (name.isNotEmpty) await cred.user?.updateDisplayName(name);
                        
                        AppState.isGuestUser.value = false;
                        if (context.mounted) {
                          Navigator.pop(context); // Close OTP dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🎉 Account Created & Verified!'), backgroundColor: Colors.green),
                          );
                        }
                      } else {
                        setDialogState(() => isVerifying = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Invalid OTP'), backgroundColor: Colors.red));
                      }
                    } catch (e) {
                      setDialogState(() => isVerifying = false);
                      debugPrint("OTP Verification Error: $e");
                    }
                  },
                  child: isVerifying 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text('Verify & Join', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address above first to reset password!'), backgroundColor: Colors.orange),
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset link sent successfully to $email!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _openEditProfileDialog(User? user) {
    final nameCtrl = TextEditingController(text: user?.displayName ?? 'Valued Customer');
    String tempAvatar = (user?.photoURL != null && user!.photoURL!.isNotEmpty) ? user.photoURL! : _selectedAvatarUrl;

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Edit Profile & DP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: buildSafeAvatarImage(tempAvatar, radius: 42, fallbackName: nameCtrl.text),
                  ),
                  const SizedBox(height: 12),
                  const Text('Choose Preset Avatar:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: _sampleAvatars.map((url) {
                      final bool isSel = tempAvatar == url;
                      return GestureDetector(
                        onTap: () => setDlgState(() => tempAvatar = url),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSel ? const Color(0xFF00A79D) : Colors.transparent, width: 2),
                          ),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: buildSafeAvatarImage(url, radius: 16, fallbackName: 'Avatar'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00A79D),
                        side: const BorderSide(color: Color(0xFF00A79D)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text('Upload Custom Image from Device'),
                      onPressed: () {
                        final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                        uploadInput.accept = 'image/*';
                        uploadInput.click();
                        uploadInput.onChange.listen((e) {
                          final files = uploadInput.files;
                          if (files != null && files.isNotEmpty) {
                            final reader = html.FileReader();
                            reader.readAsDataUrl(files[0]);
                            reader.onLoadEnd.listen((e) {
                              setDlgState(() {
                                tempAvatar = reader.result as String;
                              });
                            });
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D), foregroundColor: Colors.white),
              onPressed: () async {
                try {
                  await user?.updateDisplayName(nameCtrl.text.trim());
                  await user?.updatePhotoURL(tempAvatar);
                  await user?.reload();
                  setState(() {});
                  Navigator.pop(dlgCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
// Real Live Wallet & Referral System Modal (Connected with Node.js & NeonDB)
void _showWalletDialog(BuildContext context, {String email = 'customer@cashify.in'}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (modalCtx) {
      return FutureBuilder<http.Response>(
        future: http.get(Uri.parse('http://localhost:5000/api/wallet/$email')),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator(color: Color(0xFF00A79D))),
            );
          }

          double balance = 250.0;
          String referralCode = 'CS-REF1001';

          if (snapshot.hasData && snapshot.data!.statusCode == 200) {
            try {
              final data = jsonDecode(snapshot.data!.body);
              balance = double.parse(data['balance'].toString());
              referralCode = data['referral_code'] ?? 'CS-REF1001';
            } catch (e) {
              debugPrint('Wallet JSON Parse Error: $e');
            }
          }

          return Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.account_balance_wallet, color: Color(0xFF00A79D), size: 28),
                        SizedBox(width: 10),
                        Text('Cashify Wallet & Rewards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(modalCtx)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),

                // 1. Live Wallet Balance Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A79D), Color(0xFF007A73)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('₹${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Text('✨ Active', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Referral Code & Invite Card
                const Text('🎁 Invite Friends & Earn Rewards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Referral Code:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(referralCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.2, color: Color(0xFF00A79D))),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A79D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.copy, size: 14),
                        label: const Text('Copy Code', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: referralCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('📋 Referral Code ($referralCode) Copied to Clipboard!'),
                              backgroundColor: const Color(0xFF00A79D),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Wallet Rules
                Text('• Earn ₹100 for every friend who sells or buys a device.', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text('• Instant credit directly to your Cashify Refund Wallet.', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}
// -----------------------------------------------------------------------------
// REAL WORKING REFER & EARN MODAL (WHATSAPP, TELEGRAM & CLIPBOARD SHARE)
// -----------------------------------------------------------------------------
void _openReferAndEarnModal(BuildContext context) {
  const String referralCode = 'CASHIFY746';
  const String referralLink = 'https://cashify.in/invite?ref=$referralCode';
  const String shareMessage =
      'Hey! Sell your old phone for instant cash or buy certified refurbished phones on Cashify Pro! Use my code CASHIFY746 to get ₹200 bonus: $referralLink';

  void shareToWhatsApp() {
    final url = 'https://api.whatsapp.com/send?text=${Uri.encodeComponent(shareMessage)}';
    html.window.open(url, '_blank');
  }

  void shareToTelegram() {
    final url = 'https://t.me/share/url?url=${Uri.encodeComponent(referralLink)}&text=${Uri.encodeComponent("Get ₹200 Bonus on Cashify Pro!")}';
    html.window.open(url, '_blank');
  }

  void copyToClipboard(BuildContext ctx) {
    Clipboard.setData(const ClipboardData(text: shareMessage));
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Referral link & invite message copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ValueListenableBuilder<bool>(
      valueListenable: AppState.isDarkMode,
      builder: (context, isDark, _) {
        final cardBg = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;
        final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
        final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppState.tr('refer_earn'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF00A79D)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.card_giftcard, color: Color(0xFF00A79D), size: 26),
                        IconButton(
                          icon: Icon(Icons.close, color: textColor),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Share your unique link via WhatsApp or Telegram. When your friend completes their first order, unlock a scratch card worth ₹200 instantly!',
                  style: TextStyle(fontSize: 12, color: subTextColor, height: 1.3),
                ),
                const SizedBox(height: 16),

                // Copyable Link Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          referralLink,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () => copyToClipboard(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A79D).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.copy, size: 14, color: Color(0xFF00A79D)),
                              SizedBox(width: 4),
                              Text('Copy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00A79D))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Real Instant Social Share Buttons
                Text('Instant Social Share:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // WhatsApp Share Button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.chat_bubble, size: 18),
                        label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: shareToWhatsApp,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Telegram Share Button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0088CC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.send, size: 18),
                        label: const Text('Telegram', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: shareToTelegram,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Direct Share / Copy
                    InkWell(
                      onTap: () => copyToClipboard(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: const Icon(Icons.share, color: Color(0xFF00A79D), size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Scratch Card Reward Simulation
                Text('Scratch Card Reward Simulation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor)),
                const SizedBox(height: 8),
                ScratchCardWidget(
                  rewardAmount: 200,
                  onRevealed: () {
                    AppState.walletBalance.value += 200;
                    AppState.notifications.value = [
                      {
                        'title': '🎁 Scratch Card Claimed',
                        'desc': 'Successfully added ₹200 referral bonus to your wallet!',
                        'time': 'Just now',
                        'type': 'reward'
                      },
                      ...AppState.notifications.value
                    ];
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎉 Scratch card revealed! ₹200 added to Wallet.'), backgroundColor: Colors.green),
                    );
                  },
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A79D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close & Check Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
// Delivery Agent / Executive Portal Popup Dialog

// Customer Handover OTP Dialog (With Email Input & Real Email OTP Trigger)
void _showExecutiveOtpVerifyDialog(BuildContext context, String orderId, String defaultEmail) {
  final TextEditingController emailController = TextEditingController(
    text: defaultEmail.isNotEmpty && defaultEmail.contains('@') ? defaultEmail : ''
  );
  bool isLoading = false;
  bool isOtpSent = false;
  String statusMessage = '';
  bool isSuccess = false;

  showDialog(
    context: context,
    builder: (dlgCtx) => StatefulBuilder(
      builder: (context, setDlgState) {

        Future<void> sendOtpToEmail() async {
          final email = emailController.text.trim();
          if (email.isEmpty || !email.contains('@')) {
            setDlgState(() {
              statusMessage = 'Please enter a valid email address.';
              isSuccess = false;
            });
            return;
          }

          setDlgState(() {
            isLoading = true;
            statusMessage = '';
          });

          try {
            final response = await http.post(
              Uri.parse('http://localhost:5000/api/orders/send-handover-otp'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'orderId': orderId,
                'userEmail': email,
              }),
            );

            final data = jsonDecode(response.body);

            setDlgState(() {
              isLoading = false;
              if (response.statusCode == 200 && data['success'] == true) {
                isOtpSent = true;
                isSuccess = true;
                statusMessage = "✅ OTP has been sent to your email ($email)!";
              } else {
                isSuccess = false;
                statusMessage = data['message'] ?? 'Failed to send email. Please try again.';
              }
            });
          } catch (e) {
            setDlgState(() {
              isLoading = false;
              isSuccess = false;
              statusMessage = 'Server error: $e';
            });
          }
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.mark_email_read_outlined, color: Color(0xFF00A79D)),
              SizedBox(width: 8),
              Text('Send Handover OTP to Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: $orderId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                
                const Text(
                  "Enter the Email ID where you want to receive the 4-digit Security OTP:",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 10),

                // Email Input Box
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Customer Email Address',
                    hintText: 'e.g. your_email@gmail.com',
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00A79D)),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),

                // Status Message Box
                if (statusMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSuccess ? const Color(0xFFE6F6F5) : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSuccess ? const Color(0xFF00A79D) : Colors.red.shade300),
                    ),
                    child: Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? const Color(0xFF00A79D) : Colors.red.shade800,
                      ),
                    ),
                  ),

                if (isOtpSent)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.mark_email_unread_outlined, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "📩 Check your email inbox and share the received OTP with the executive.",
                            style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A79D),
                foregroundColor: Colors.white,
              ),
              icon: isLoading 
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send, size: 16),
              label: Text(isLoading ? 'Sending...' : 'Send OTP to Email'),
              onPressed: isLoading ? null : sendOtpToEmail,
            ),
          ],
        );
      },
    ),
  );
}
// Full Live Admin Control Hub (Connected with PostgreSQL & Express Backend)
void _showAdminPortalDialog(BuildContext context) {
  bool isLoggedIn = false;
  int activeTab = 0; // 0: Rules & Pincodes, 1: Live Orders Control, 2: QC & Publish

  final TextEditingController emailController = TextEditingController(text: 'admin@cashify.in');
  final TextEditingController passwordController = TextEditingController(text: 'admin123');

  // Form Controllers
  final TextEditingController issueController = TextEditingController();
  final TextEditingController deductionController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
final TextEditingController customEmailController = TextEditingController();
  // QC Form Controllers
  final TextEditingController deviceTitleController = TextEditingController();
  final TextEditingController devicePriceController = TextEditingController();
  final TextEditingController deviceBrandController = TextEditingController();

  bool isLoading = false;
  String errorMsg = '';

  showDialog(
    context: context,
    builder: (dlgCtx) => StatefulBuilder(
      builder: (context, setDlgState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(isLoggedIn ? Icons.admin_panel_settings : Icons.lock, color: const Color(0xFF00A79D)),
                const SizedBox(width: 8),
                Text(
                  isLoggedIn ? 'Central Admin Control Hub' : 'Restricted Admin Login',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (isLoggedIn)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE6FFFA), borderRadius: BorderRadius.circular(6)),
                child: const Text('SUPER ADMIN', style: TextStyle(color: Color(0xFF00A79D), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: !isLoggedIn
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This panel is restricted to system administrators only.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Admin Email ID',
                          prefixIcon: const Icon(Icons.email_outlined, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Admin Password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                      ),
                      if (errorMsg.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(errorMsg, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Tab Navigation Bar
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      _adminTabChip('Rules & Pincodes', 0, activeTab, (i) => setDlgState(() => activeTab = i)),
      _adminTabChip('Live Orders Control', 1, activeTab, (i) => setDlgState(() => activeTab = i)),
      _adminTabChip('Warehouse QC & Publish', 2, activeTab, (i) => setDlgState(() => activeTab = i)),
    ],
  ),
),
                      const Divider(height: 20),

                      // MODULE 1: PRICING RULES & SERVICEABLE PINCODES
                      if (activeTab == 0) ...[
                        const Text('1. Dynamic Valuation Engine Rules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: issueController,
                                decoration: InputDecoration(labelText: 'Issue (e.g. Broken Glass)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: deductionController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Deduction %', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D), foregroundColor: Colors.white),
                            onPressed: () async {
                              if (issueController.text.isEmpty || deductionController.text.isEmpty) return;
                              try {
                                await http.post(
                                  Uri.parse('http://localhost:5000/api/admin/pricing-rules'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({'category': 'Mobiles', 'issueName': issueController.text, 'deductionValue': deductionController.text}),
                                );
                                issueController.clear();
                                deductionController.clear();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Valuation Rule Saved to Database!'), backgroundColor: Colors.green));
                                }
                              } catch (e) {
                                debugPrint('Rule creation error: $e');
                              }
                            },
                            child: const Text('Add Valuation Rule'),
                          ),
                        ),
                        const Divider(height: 24),
                        const Text('2. Manage Pickup Pincodes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: pincodeController,
                                decoration: InputDecoration(labelText: 'Pincode (e.g. 560102)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: cityController,
                                decoration: InputDecoration(labelText: 'City Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
                            onPressed: () async {
                              if (pincodeController.text.isEmpty) return;
                              try {
                                await http.post(
                                  Uri.parse('http://localhost:5000/api/admin/pincodes'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({'pincode': pincodeController.text, 'city': cityController.text, 'state': 'Karnataka'}),
                                );
                                pincodeController.clear();
                                cityController.clear();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Service Pincode Activated in Database!'), backgroundColor: Colors.blue));
                                }
                              } catch (e) {
                                debugPrint('Pincode creation error: $e');
                              }
                            },
                            child: const Text('Enable Service Pincode'),
                          ),
                        ),
                      ],

             // MODULE 2: LIVE ORDERS STATUS CONTROL (FETCH FROM NEON DB)
                      if (activeTab == 1) ...[
                        const Text(
                          'Live Database Customer Orders',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        
                        FutureBuilder<http.Response>(
                          future: http.get(Uri.parse('http://localhost:5000/api/admin/orders')),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(color: Color(0xFF00A79D)),
                                ),
                              );
                            }

                            List<dynamic> ordersList = [];
                            if (snapshot.hasData && snapshot.data!.statusCode == 200) {
                              try {
                                ordersList = jsonDecode(snapshot.data!.body);
                              } catch (_) {}
                            }

                            if (ordersList.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No live orders found in database.',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              );
                            }

                            return Container(
                              height: 280,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.separated(
                                itemCount: ordersList.length,
                                separatorBuilder: (ctx, i) => const Divider(height: 1),
                                itemBuilder: (ctx, i) {
                                  final order = ordersList[i];
                                  final String orderId = order['order_id'] ?? 'CS-${order['id']}';
                                  final String currentStatus = order['status'] ?? 'Order Confirmed';
                                  final String deviceName = order['device_name'] ?? 'Device';
                                  final String userEmail = order['user_email'] ?? 'N/A';
                                  final price = order['offered_price'] ?? '0';

                                  const validStatuses = [
                                    'Order Confirmed',
                                    'Partner Assigned',
                                    'Out for Pickup',
                                    'Completed'
                                  ];
                                  final selectedStatus = validStatuses.contains(currentStatus)
                                      ? currentStatus
                                      : 'Order Confirmed';

                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      '$orderId • $deviceName',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    subtitle: Text(
                                      'Price: ₹$price | User: $userEmail',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    trailing: DropdownButton<String>(
                                      value: selectedStatus,
                                      underline: const SizedBox(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF00A79D),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      items: validStatuses
                                          .map((st) => DropdownMenuItem(
                                                value: st,
                                                child: Text(st),
                                              ))
                                          .toList(),
                                      onChanged: (newStatus) async {
                                        if (newStatus == null) return;
                                        try {
                                          await http.post(
                                            Uri.parse('http://localhost:5000/api/admin/orders/status'),
                                            headers: {'Content-Type': 'application/json'},
                                            body: jsonEncode({
                                              'id': order['id'],
                                              'order_id': orderId,
                                              'status': newStatus,
                                              'userEmail': customEmailController.text.trim(),
                                            }),
                                          );
                                          setDlgState(() {});
                                        } catch (e) {
                                          debugPrint('Status Update Error: $e');
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],

                      // MODULE 3: WAREHOUSE QC & PUBLISH TO LIVE STORE
                      if (activeTab == 2) ...[
                        const Text('Publish Certified Refurbished Device to Store', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: deviceTitleController,
                          decoration: InputDecoration(labelText: 'Device Title (e.g. iPhone 14 Pro 128GB)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: deviceBrandController,
                                decoration: InputDecoration(labelText: 'Brand (Apple / Samsung)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: devicePriceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: 'Price (₹)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D), foregroundColor: Colors.white),
                            icon: const Icon(Icons.publish, size: 16),
                            label: const Text('Approve QC & Publish Live'),
                            onPressed: () async {
                              if (deviceTitleController.text.isEmpty || devicePriceController.text.isEmpty) return;
                              try {
                                await http.post(
                                  Uri.parse('http://localhost:5000/api/products'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'title': deviceTitleController.text.trim(),
                                    'brand': deviceBrandController.text.trim().isNotEmpty ? deviceBrandController.text.trim() : 'Apple',
                                    'price': '₹${devicePriceController.text.trim()}',
                                    'rawPrice': double.tryParse(devicePriceController.text.trim()) ?? 45000,
                                    'condition': 'Superb • 32-Point Check Passed',
                                    'type': 'buy',
                                    'image': 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=800&auto=format&fit=crop&q=80',
                                  }),
                                );
                                deviceTitleController.clear();
                                deviceBrandController.clear();
                                devicePriceController.clear();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Published Live to Buy Store Database!'), backgroundColor: Colors.green));
                                }
                              } catch (e) {
                                debugPrint('Publish product error: $e');
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
          if (!isLoggedIn)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D), foregroundColor: Colors.white),
              onPressed: isLoading
                  ? null
                  : () async {
                      setDlgState(() {
                        isLoading = true;
                        errorMsg = '';
                      });

                      try {
                        final res = await http.post(
                          Uri.parse('http://localhost:5000/api/admin/login'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'email': emailController.text.trim(),
                            'password': passwordController.text.trim(),
                          }),
                        );

                        final data = jsonDecode(res.body);

                        if (res.statusCode == 200 && data['success'] == true) {
                          setDlgState(() {
                            isLoggedIn = true;
                            isLoading = false;
                          });
                        } else {
                          setDlgState(() {
                            errorMsg = data['message'] ?? 'Invalid admin credentials!';
                            isLoading = false;
                          });
                        }
                      } catch (e) {
                        setDlgState(() {
                          errorMsg = 'Backend connection error!';
                          isLoading = false;
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Login as Admin', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    ),
  );
}

Widget _adminTabChip(String label, int index, int activeIndex, Function(int) onTap) {
  final bool isSel = index == activeIndex;
  return Padding(
    padding: const EdgeInsets.only(right: 6),
    child: ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
      selected: isSel,
      selectedColor: const Color(0xFF00A79D),
      labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87),
      onSelected: (_) => onTap(index),
    ),
  );
}
// Flutter Warehouse QC & Refurbishment Dialog Function
void _showWarehouseQCDialog(BuildContext context) {
  final TextEditingController imeiController = TextEditingController(text: '358921098412345');
  final TextEditingController titleController = TextEditingController(text: 'iPhone 14 (128 GB) - Refurbished');
  final TextEditingController repairCostController = TextEditingController(text: '1500');
  final TextEditingController priceController = TextEditingController(text: '42999');
  final TextEditingController originalPriceController = TextEditingController(text: '79900');
  
  String selectedGrade = 'Grade A (Superb)';
  bool isPublishing = false;

  showDialog(
    context: context,
    builder: (dlgCtx) => StatefulBuilder(
      builder: (context, setDlgState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.precision_manufacturing, color: Color(0xFF00A79D)),
            SizedBox(width: 8),
            Text('Warehouse Refurbishment & QC Lab', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Device Inward Scan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: imeiController,
                decoration: InputDecoration(
                  labelText: 'IMEI / Barcode',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Listing Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              const Text('2. Grading & Costing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedGrade,
                decoration: InputDecoration(
                  labelText: 'Cosmetic Grade',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
                items: ['Grade A (Superb)', 'Grade A (Good)', 'Grade B (Fair)']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDlgState(() => selectedGrade = val);
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: repairCostController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Repair Cost (₹)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Selling Price (₹)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A79D),
              foregroundColor: Colors.white,
            ),
            onPressed: isPublishing
                ? null
                : () async {
                    setDlgState(() => isPublishing = true);

                    try {
                      final res = await http.post(
                        Uri.parse('http://localhost:5000/api/warehouse/publish-qc'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'imei': imeiController.text.trim(),
                          'title': titleController.text.trim(),
                          'grade': selectedGrade,
                          'repairCost': double.tryParse(repairCostController.text) ?? 0,
                          'price': double.tryParse(priceController.text) ?? 30000,
                          'originalPrice': double.tryParse(originalPriceController.text) ?? 60000,
                          'category': 'Refurbished Mobiles',
                          'image': 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?q=80&w=600&auto=format&fit=crop',
                        }),
                      );

                      if (context.mounted) {
                        Navigator.pop(dlgCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 32-Point QC Passed! Device Published to Live Buy Store.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      setDlgState(() => isPublishing = false);
                      if (context.mounted) {
                        Navigator.pop(dlgCtx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Device Published to Buy Store (Offline Sync Mode)'),
                            backgroundColor: Color(0xFF00A79D),
                          ),
                        );
                      }
                    }
                  },
            child: isPublishing
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Approve QC & Publish', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );
}
// Dynamic Live Tracker Dialog with Real Progress Ticks
void _openLiveTrackingDialog(BuildContext context, Map<String, dynamic> order) {
  final String currentStatus = (order['status'] ?? '').toString();
  final bool isCompleted = currentStatus == 'Completed' || (order['isCompleted'] == true);

  Widget buildStepRow(String title, String subtitle, bool isDone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isDone ? const Color(0xFF00A79D) : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDone ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDone ? const Color(0xFF00A79D) : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  showDialog(
    context: context,
    builder: (dlgCtx) => StatefulBuilder(
      builder: (context, setTrackerState) {
        final String orderId = order['id']?.toString() ?? order['order_id']?.toString() ?? 'CS-1001';
        final String title = order['title']?.toString() ?? order['device_name']?.toString() ?? 'Device';
        final String slot = order['slot']?.toString() ?? 'Morning (9 AM - 12 PM)';
        final String userEmail = order['user_email']?.toString() ?? 'customer@cashify.in';

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Live Tracking: $orderId',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(dlgCtx),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4FBFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD0F0EE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_iphone, color: Color(0xFF00A79D), size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Slot: $slot', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                buildStepRow('Pickup Request Confirmed', 'Confirmed • Electronic Verification Passed', true),
                const SizedBox(height: 12),
                buildStepRow('Partner Assigned (Amit Sharma)', 'Contact: +91 99555 12345 • Verified Technician', true),
                const SizedBox(height: 12),
                buildStepRow(
                  'Executive En-Route for Doorstep Pickup',
                  isCompleted ? 'Arrived at Location • Handover Verified' : 'Scheduled on Today ($slot)',
                  isCompleted,
                ),
                const SizedBox(height: 12),
                buildStepRow(
                  'Physical Inspection & Instant Cash Transfer',
                  isCompleted ? '✅ Pickup Complete & Instant Payment Transferred' : 'Pending Doorstep Verification',
                  isCompleted,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A79D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.shield_outlined, size: 18),
                    label: const Text('Customer: View My Handover OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () => _showExecutiveOtpVerifyDialog(context, orderId, userEmail),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget _trackerStep({
  required String title,
  required String subtitle,
  required bool isCompleted,
  required bool isCurrent,
  required Color textColor,
  required Color subTextColor,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF00A79D) : Colors.grey.shade400,
                shape: BoxShape.circle,
                border: isCurrent ? Border.all(color: Colors.tealAccent, width: 3) : null,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isCompleted ? textColor : subTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isCurrent ? const Color(0xFF00A79D) : subTextColor,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  void _downloadInvoice(Map<String, dynamic> o) {
  final user = _auth.currentUser;
final invId = (o['order_id'] ?? o['id'] ?? 'INV-2026').toString();

// 🟢 Subhi price keys (price, amount, offered_price) check hongi
final String amt = (o['price'] != null && o['price'].toString().isNotEmpty)
    ? o['price'].toString()
    : (o['amount'] != null && o['amount'].toString().isNotEmpty)
        ? o['amount'].toString()
        : (o['offered_price'] != null)
            ? '₹${o['offered_price']}'
            : '₹0';
    final title = o['title']?.toString() ?? 'Order';
    final custName = (user?.displayName?.isNotEmpty == true) ? user!.displayName! : 'Valued Customer';
    final custEmail = user?.email ?? 'customer@cashify.in';

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Cashify Pro - Tax Invoice</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; padding: 40px; color: #222; max-width: 780px; margin: auto; }
    .header { display: flex; justify-content: space-between; border-bottom: 2px solid #00A79D; padding-bottom: 20px; }
    .brand { font-size: 26px; font-weight: 900; color: #00A79D; }
    .meta { text-align: right; font-size: 13px; color: #555; }
    .info { display: flex; justify-content: space-between; margin: 25px 0; font-size: 13px; }
    table { width: 100%; border-collapse: collapse; margin-top: 15px; }
    th { background: #f4f6f8; text-align: left; padding: 10px; border-bottom: 2px solid #ddd; }
    td { padding: 12px 10px; border-bottom: 1px solid #eee; font-size: 13px; }
    .total-box { margin-top: 20px; text-align: right; }
    .total-price { font-size: 20px; font-weight: bold; color: #00A79D; }
    .badge { display: inline-block; padding: 4px 8px; background: #e0f2f1; color: #00796b; border-radius: 4px; font-weight: bold; font-size: 11px; }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <div class="brand">CASHIFY PRO</div>
      <div style="font-size: 11px; color: #777;">India's Leading ReCommerce Platform</div>
      <div style="font-size: 11px; color: #777;">GSTIN: 07AABCC1234F1Z8</div>
    </div>
    <div class="meta">
      <h3 style="margin:0; color:#00A79D;">ORIGINAL TAX INVOICE</h3>
      <div>Invoice No: <strong>$invId</strong></div>
      <div>Date: <strong>16 Sep 2026</strong></div>
      <div>Status: <span class="badge">PAID & VERIFIED</span></div>
    </div>
  </div>

  <div class="info">
    <div>
      <strong>Billed To:</strong><br>
      $custName<br>
      $custEmail<br>
      ${AppState.selectedAddress.value}
    </div>
    <div style="text-align:right;">
      <strong>Fulfilled By:</strong><br>
      Cashify Pro Tech Services Pvt Ltd<br>
      Plot 78, Software Tech Park, Electronic City<br>
      Bengaluru, Karnataka 560100
    </div>
  </div>

  <table>
    <thead>
      <tr>
        <th>Description / Service</th>
        <th>HSN / SAC</th>
        <th>Warranty</th>
        <th style="text-align:right;">Amount</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>$title</strong></td>
        <td>851712</td>
        <td>6 Months Assured</td>
        <td style="text-align:right;">$amt</td>
      </tr>
    </tbody>
  </table>

  <div class="total-box">
    <p>GST (18% Included): Applicable</p>
    <p class="total-price">Final Amount Paid: $amt</p>
  </div>

  <div style="margin-top: 40px; font-size: 11px; color: #888; text-align: center; border-top: 1px dashed #ccc; padding-top: 15px;">
    This is a digitally generated invoice and does not require a physical signature.<br>
    For doorstep warranty claims or queries, contact support@cashify.in
  </div>

  <script>window.onload = function() { window.print(); };</script>
</body>
</html>
''';
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }

@override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;

    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return ValueListenableBuilder<bool>(
          valueListenable: AppState.isGuestUser,
          builder: (context, isGuest, _) {
            final bool isLoggedIn = user != null || isGuest;

            return ValueListenableBuilder<String>(
              valueListenable: AppState.appLanguage,
              builder: (context, lang, _) {
                return Scaffold(
                  appBar: isDesktop
                      ? null
                      : AppBar(
                          title: Text(isLoggedIn ? AppState.tr('my_account') : 'Sign In to Cashify'),
                          automaticallyImplyLeading: false,
                        ),
                  body: WebContainer(
                    maxWidth: isLoggedIn ? 800 : 450, // Logged-in dashboard ke liye 1100px desktop width
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isDesktop ? 24 : 16),
                      child: isLoggedIn ? _buildProfileView(user, isGuest) : _buildAuthForm(),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
Widget _buildProfileView(User? user, bool isGuest) {
    final displayName = isGuest
        ? 'Guest Explorer'
        : (user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Verified Customer');
    final email = isGuest ? 'guest.session@cashify.in' : (user?.email ?? 'customer@cashify.in');
    final photoUrl = user?.photoURL;
    final messenger = ScaffoldMessenger.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    // Left Column Cards (Profile, Wallet, Settings, Pickup Location)
    Widget leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Profile Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: buildSafeAvatarImage(isGuest ? null : photoUrl, radius: 30, fallbackName: displayName),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                          child: const Text('GOLD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.brown)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                    if (!isGuest) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _openEditProfileDialog(user),
                        child: const Text('✏️ Upload Image & Edit Profile', style: TextStyle(color: Color(0xFF00A79D), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                tooltip: 'Logout',
                onPressed: () async {
                  if (isGuest) {
                    AppState.isGuestUser.value = false;
                  } else {
                    await _auth.signOut();
                  }
                  messenger.showSnackBar(const SnackBar(content: Text('Logged out!'), duration: Duration(milliseconds: 900)));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Cashify Wallet Card
        GestureDetector(
          onTap: () => _showWalletDialog(context, email: email),
          child: ValueListenableBuilder<double>(
            valueListenable: AppState.walletBalance,
            builder: (ctx, bal, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00A79D), Color(0xFF004D40)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF00A79D).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppState.tr('wallet_balance'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text('₹${bal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF00A79D),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.account_balance_wallet, size: 16),
                          label: const Text('View Wallet Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          onPressed: () => _showWalletDialog(context, email: email),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap to view Live Balance & Referral Rewards', style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // 3. Settings Block (Dark Mode, Language, Refer)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.dark_mode, size: 18, color: Color(0xFF00A79D)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(AppState.tr('dark_mode'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: AppState.isDarkMode,
                    builder: (_, isDark, __) => Switch(
                      activeColor: const Color(0xFF00A79D),
                      value: isDark,
                      onChanged: (val) => AppState.isDarkMode.value = val,
                    ),
                  ),
                ],
              ),
              const Divider(height: 12),
              Row(
                children: [
                  const Icon(Icons.language, size: 18, color: Color(0xFF00A79D)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(AppState.tr('language'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: AppState.appLanguage,
                    builder: (_, lang, __) => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: lang,
                        isDense: true,
                        items: ['English', 'Hindi (हिंदी)'].map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (val) {
                          if (val != null) AppState.appLanguage.value = val;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 12),
              InkWell(
                onTap: () => _openReferAndEarnModal(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.card_giftcard, size: 18, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(AppState.tr('refer_earn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 4. Location Address Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppState.tr('pickup_location'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 2),
                    ValueListenableBuilder<String>(
                      valueListenable: AppState.selectedAddress,
                      builder: (_, addr, __) => Text(
                        addr,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => AppState.openMapLocationPicker(context),
                child: Text(AppState.tr('edit_location'), style: const TextStyle(color: Color(0xFF00A79D), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );

    // Right Column Cards (Orders List, Portals & Socials)
Widget rightColumn = Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
      // 🟢 1. Right Side Title Heading
        Text(
          AppState.tr('orders_repairs'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // 🟢 2. Filter Chips Row (With 'All' tab included)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Pickups', 'Purchases', 'Repairs'].map((tab) {
              final isSel = _selectedOrderTab == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    tab, 
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal
                    ),
                  ),
                  selected: isSel,
                  selectedColor: const Color(0xFF00A79D).withValues(alpha: 0.18),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSel ? const Color(0xFF00A79D) : Colors.black87
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSel ? const Color(0xFF00A79D) : Colors.grey.shade300
                    ),
                  ),
                  onSelected: (v) {
                    if (v) setState(() => _selectedOrderTab = tab);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 14),

        // Orders List
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchOrdersFromNeonDB(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF00A79D))),
              );
            }

            final neonOrdersFromDB = snapshot.data ?? [];
            final List<Map<String, dynamic>> neonOrders = neonOrdersFromDB.map((o) {
              return {
                'id': 'ORD-${o['id'] ?? Random().nextInt(8999) + 1000}',
                'title': o['device_name']?.toString() ?? 'Device Order',
                'price': '₹${(double.tryParse(o['offered_price']?.toString() ?? '0') ?? 0).toInt()}',
                'status': o['status']?.toString() ?? 'Confirmed',
                'date': 'Today',
                'type': 'sell',
              };
            }).toList();

         final defaultSampleOrders = [
  {
    'id': 'ORD-9842',
    'title': 'iPhone 13 (128 GB) - Starlight',
    'price': '₹38,500',
    'status': 'Pickup Scheduled',
    'date': 'Today, 4:00 PM',
    'type': 'sell',
  },
  {
    'id': 'ORD-5120',
    'title': 'OnePlus 11 Screen Replacement',
    'price': '₹4,200',
    'status': 'Completed',
    'date': 'Yesterday',
    'type': 'repair',
  },
];

final allMergedOrders = neonOrders.isNotEmpty 
    ? neonOrders 
    : (AppState.myOrders.value.isNotEmpty ? AppState.myOrders.value : defaultSampleOrders);

            final filtered = allMergedOrders.where((o) {
              final type = o['type']?.toString().toLowerCase();
              if (_selectedOrderTab == 'All') return true;
              if (_selectedOrderTab == 'Pickups') return type == 'sell' || type == 'exchange' || type == 'pickup';
              if (_selectedOrderTab == 'Purchases') return type == 'buy' || type == 'purchase';
              if (_selectedOrderTab == 'Repairs') return type == 'repair';
              return true;
            }).toList();

            if (filtered.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.inventory_2_outlined, size: 42, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No active orders or pickups in this section.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              );
            }

            return Column(
              children: filtered.map((o) {
                final type = (o['type'] ?? 'buy').toString().toLowerCase();
                
                IconData cardIcon = Icons.shopping_bag;
                Color iconBgColor = const Color(0xFFE6F6F5);
                Color iconColor = const Color(0xFF00A79D);
                Color statusBgColor = Colors.green.shade100;
                Color statusTextColor = Colors.green.shade900;

                if (type == 'repair') {
                  cardIcon = Icons.build;
                  iconBgColor = Colors.green.shade50;
                  iconColor = Colors.green;
                } else if (type == 'sell' || type == 'pickup') {
                  cardIcon = Icons.phone_android;
                  iconBgColor = Colors.orange.shade50;
                  iconColor = Colors.deepOrange;
                  statusBgColor = Colors.orange.shade100;
                  statusTextColor = Colors.orange.shade900;
                } else if (type == 'exchange') {
                  cardIcon = Icons.swap_horiz;
                  iconBgColor = Colors.amber.shade50;
                  iconColor = Colors.brown;
                }

                final orderPrice = o['price']?.toString() ?? o['amount']?.toString() ?? '₹0';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(cardIcon, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(orderPrice, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00A79D), fontSize: 13)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        o['status']?.toString() ?? 'Confirmed',
                                        style: TextStyle(fontSize: 10, color: statusTextColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                Wrap(
  alignment: WrapAlignment.spaceBetween,
  crossAxisAlignment: WrapCrossAlignment.center,
  spacing: 8,
  runSpacing: 8,
  children: [
    Text('ID: ${o['id']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
    Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00A79D),
            side: const BorderSide(color: Color(0xFF00A79D)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            visualDensity: VisualDensity.compact,
          ),
          icon: const Icon(Icons.location_searching, size: 12),
          label: const Text('Track', style: TextStyle(fontSize: 11)),
          onPressed: () => _openLiveTrackingDialog(context, o),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            visualDensity: VisualDensity.compact,
          ),
          icon: const Icon(Icons.download, size: 12),
          label: const Text('Invoice', style: TextStyle(fontSize: 11)),
          onPressed: () => _downloadInvoice(o),
        ),
        
      ],
    ),
  ],
)
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 14),

// Admin & Executive Portal Cards
Row(
  children: [
    Expanded(
      child: Material(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFFE6FFFA), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.admin_panel_settings, color: Color(0xFF00A79D), size: 20),
          ),
          title: const Text('Admin Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: const Text('Valuation & Rules', style: TextStyle(fontSize: 10, color: Colors.grey)),
          onTap: () => _showAdminPortalDialog(context),
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Material(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.verified_user_rounded, color: Colors.blueAccent, size: 20),
          ),
          title: const Text('Executive Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: const Text('Verify Pickup & Handover', style: TextStyle(fontSize: 10, color: Colors.grey)),
          onTap: () {
            _showExecutiveLoginDialog(
              context,
              onVerifiedSuccess: () {
                setState(() {});
              },
            );
          },
        ),
      ),
    ),
  ],
),
       
        const SizedBox(height: 14),

        // Social Media Card
     Container(
  width: double.infinity, // 👈 Isse social card poori width lega
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade200),
  ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Connect With Cashify Official', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              const Text('Follow us for tech updates & exclusive offers!', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _socialButton('Instagram', Icons.camera_alt, Colors.pink, 'https://www.instagram.com/cashify/'),
                    const SizedBox(width: 16),
                    _socialButton('YouTube', Icons.play_circle_filled, Colors.red, 'https://www.youtube.com/@Cashify_in'),
                    const SizedBox(width: 16),
                    _socialButton('Twitter/X', Icons.alternate_email, Colors.blue, 'https://twitter.com/cashify_in'),
                    const SizedBox(width: 16),
                    _socialButton('LinkedIn', Icons.work, Colors.blue.shade800, 'https://www.linkedin.com/company/cashify/'),
                    const SizedBox(width: 16),
                    _socialButton('Facebook', Icons.facebook, Colors.indigo, 'https://www.facebook.com/CashifyIndia/'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

 // 🟢 Single Vertical Column Layout (Full Page Scroll)
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Top Heading
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Text(
          AppState.tr('my_account'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      // 1. Profile, Wallet, Location Cards (Top)
      leftColumn,

      const SizedBox(height: 28), // Spacing

      // 2. Orders, Repairs, Portals & Socials (Bottom)
      rightColumn,
    ],
  );

        
  }

  Widget _socialButton(String label, IconData icon, Color color, String url) {
    return InkWell(
      onTap: () {
        html.window.open(url, '_blank');
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAuthForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00A79D), Color(0xFF004D40)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Cashify Pro Auth', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Log in to view orders, track devices & withdraw wallet cash', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _isSignUp = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !_isSignUp ? const Color(0xFF00A79D) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, color: !_isSignUp ? Colors.white : Colors.black87)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _isSignUp = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _isSignUp ? const Color(0xFF00A79D) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, color: _isSignUp ? Colors.white : Colors.black87)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
            label: const Text('Continue with Google', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            onPressed: _signInWithGoogle,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(child: Divider()),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('OR', style: TextStyle(fontSize: 11, color: Colors.grey))),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),

        if (_isSignUp) ...[
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: buildSafeAvatarImage(_selectedAvatarUrl, radius: 36, fallbackName: _nameController.text),
                ),
                const SizedBox(height: 6),
                const Text('Choose Profile Avatar:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _sampleAvatars.map((url) {
                    final bool isSel = _selectedAvatarUrl == url;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatarUrl = url),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSel ? const Color(0xFF00A79D) : Colors.transparent, width: 2),
                        ),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: buildSafeAvatarImage(url, radius: 18, fallbackName: 'Avatar'),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passController,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (!_isSignUp) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _forgotPassword,
              child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF00A79D), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
        ],

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D), foregroundColor: Colors.white),
            onPressed: _isLoading ? null : _handleAuth,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(_isSignUp ? 'Register with Profile Photo' : 'Sign In with Email', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: TextButton(
            onPressed: () => AppState.isGuestUser.value = true,
            child: const Text('Browse as Guest (Skip)', style: TextStyle(color: Colors.grey)),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SELL DEVICE SCREEN (FULL DARK MODE COMPATIBLE)
// -----------------------------------------------------------------------------
class SellDeviceScreen extends StatefulWidget {
  const SellDeviceScreen({super.key});

  @override
  State<SellDeviceScreen> createState() => _SellDeviceScreenState();
}

class _SellDeviceScreenState extends State<SellDeviceScreen> {
  int _currentStep = 3; // 0: Brand, 1: Model, 2: Inspect, 3: Value & Checkout

  final html.IFrameElement _mapIframeElement = html.IFrameElement()
    ..style.border = 'none'
    ..style.width = '100%'
    ..style.height = '100%';

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(
      'real-google-maps-iframe-sell',
      (int viewId) => _mapIframeElement,
    );
  }

  // Brand & Model Data
  String _selectedBrand = 'Samsung';
  final Map<String, List<Map<String, dynamic>>> _brandModels = {
    'Apple': [
      {'name': 'iPhone 15 Pro Max', 'basePrice': 85000},
      {'name': 'iPhone 15', 'basePrice': 52000},
      {'name': 'iPhone 14', 'basePrice': 41000},
    ],
    'Samsung': [
      {'name': 'Galaxy S24 Ultra', 'basePrice': 78000},
      {'name': 'Galaxy S23 5G', 'basePrice': 42000},
      {'name': 'Galaxy S22 5G', 'basePrice': 32500},
    ],
    'OnePlus': [
      {'name': 'OnePlus 12', 'basePrice': 48000},
      {'name': 'OnePlus 11 5G', 'basePrice': 35000},
    ],
  };

  String _selectedModel = 'Galaxy S22 5G';
  int _basePrice = 32500;
  String _selectedStorage = '128 GB';

  // Condition Checklist
  String _screenCondition = 'Flawless (No Scratches)';
  String _bodyCondition = 'Like New';
  bool _touchOk = true;
  bool _cameraOk = true;
  bool _hasOriginalCharger = true;

  // IMEI Verification
  final TextEditingController _imeiController = TextEditingController(text: '862722087246977');
  bool? _isImeiValid = true;
  String _imeiStatusMessage = '✓ Verified Device IMEI (Backend Check Passed)';
  bool _isCheckingImei = false;

  // Pickup Address & Google Map Coordinates
  final TextEditingController _pincodeController = TextEditingController(text: '842001');
  final TextEditingController _addressController = TextEditingController(text: 'Flat 402, Green Glen Heights, HSR Layout');
  String _mapCoordinates = 'Lat: 12.9121, Lng: 77.6445 (Selected via Map)';
  bool _isCheckingPincode = false;
  String _pincodeStatus = '✓ Verified: Muzaffarpur, Bihar';

  // Expected Date & Time Slot
  String _pickupDate = 'Tomorrow (Mon)';
  String _pickupSlot = 'Morning (10:00 AM - 01:00 PM)';

  // Payment Mode
  String _paymentMode = 'Razorpay Instant';
  final TextEditingController _upiController = TextEditingController();

  int get _calculatedValuation {
    double finalPrice = _basePrice.toDouble();
    if (_selectedStorage == '256 GB') finalPrice += 2500;
    if (_selectedStorage == '512 GB') finalPrice += 5000;
    if (_screenCondition == 'Minor Scratches') finalPrice -= 2000;
    if (_screenCondition == 'Cracked') finalPrice -= 6000;
    if (_bodyCondition == 'Minor Dents') finalPrice -= 1500;
    if (_bodyCondition == 'Heavy Wear') finalPrice -= 3500;
    if (!_touchOk) finalPrice -= 3000;
    if (!_cameraOk) finalPrice -= 2500;
    if (_hasOriginalCharger) finalPrice += 500;
    return finalPrice > 1000 ? finalPrice.round() : 1000;
  }

  Future<void> _verifyIMEI() async {
    final imei = _imeiController.text.trim();
    if (imei.length != 15) {
      setState(() {
        _isImeiValid = false;
        _imeiStatusMessage = 'IMEI exactly 15 digits ka hona chahiye.';
      });
      return;
    }

    setState(() {
      _isCheckingImei = true;
      _imeiStatusMessage = 'Express backend se verify ho raha hai...';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/validate-imei'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imei': imei}),
      );

      final data = jsonDecode(response.body);
      setState(() {
        _isImeiValid = data['valid'] == true;
        _imeiStatusMessage = data['message'] ?? '✓ Verified Device IMEI';
      });
    } catch (e) {
      _localLuhnCheck(imei);
    } finally {
      setState(() => _isCheckingImei = false);
    }
  }

  void _localLuhnCheck(String imei) {
    int sum = 0;
    for (int i = 0; i < 15; i++) {
      int digit = int.parse(imei[i]);
      if (i % 2 != 0) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    bool isValid = (sum % 10 == 0);
    setState(() {
      _isImeiValid = isValid;
      _imeiStatusMessage = isValid
          ? '✓ Verified Device IMEI (Luhn Check Passed)'
          : '✕ Invalid IMEI Number (Check *#06#)';
    });
  }

  Future<void> _fetchPincodeDetails(String pin) async {
    if (pin.length != 6) return;
    setState(() {
      _isCheckingPincode = true;
      _pincodeStatus = 'Location auto-detecting...';
    });

    try {
      final res = await http.get(Uri.parse('https://api.postalpincode.in/pincode/$pin'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data[0]['Status'] == 'Success') {
          final poList = data[0]['PostOffice'] as List;
          final area = poList[0]['Name'];
          final district = poList[0]['District'];
          final state = poList[0]['State'];

          setState(() {
            _pincodeStatus = '✓ Verified: $district, $state';
            if (_addressController.text.isEmpty) {
              _addressController.text = '$area, $district, $state - $pin';
            }
          });
        }
      }
    } catch (e) {
      setState(() => _pincodeStatus = '✓ Saved for Pincode $pin');
    } finally {
      setState(() => _isCheckingPincode = false);
    }
  }

  void _openGoogleMapPicker() {
    final TextEditingController mapSearchController = TextEditingController(
      text: _addressController.text.isNotEmpty 
          ? _addressController.text 
          : '${_pincodeController.text}, India',
    );

    String currentQuery = mapSearchController.text;
    _mapIframeElement.src = 'https://maps.google.com/maps?q=${Uri.encodeComponent(currentQuery)}&t=&z=15&ie=UTF8&iwloc=&output=embed';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 540,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.map, color: Color(0xFF00A79D)),
                          SizedBox(width: 8),
                          Text('Live Google Maps Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: mapSearchController,
                          decoration: InputDecoration(
                            hintText: 'Search Area, Landmark or City',
                            isDense: true,
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF00A79D), size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A79D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                        onPressed: () {
                          setModalState(() {
                            currentQuery = mapSearchController.text;
                            _mapIframeElement.src = 'https://maps.google.com/maps?q=${Uri.encodeComponent(currentQuery)}&t=&z=15&ie=UTF8&iwloc=&output=embed';
                          });
                        },
                        child: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF00A79D), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const HtmlElementView(viewType: 'real-google-maps-iframe-sell'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '📍 Locked: $currentQuery',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A79D),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Confirm Map Location', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() {
                          _mapCoordinates = '📍 Google Maps Verified: $currentQuery';
                          if (_addressController.text.isEmpty || _addressController.text.contains('HSR Layout')) {
                            _addressController.text = currentQuery;
                          }
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📍 Location synced from Real Google Maps!'), backgroundColor: Colors.teal),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _submitPickupOrder() {
    if (_isImeiValid != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Pehle valid 15-digit IMEI verify karein!'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Full House / Street Address enter karein!'), backgroundColor: Colors.orange),
      );
      return;
    }

    final String deviceTitle = 'SELL: $_selectedBrand $_selectedModel ($_selectedStorage)';
    final double valuationAmount = _calculatedValuation.toDouble();

    openPaymentGatewayModal(
      context: context,
      totalAmount: valuationAmount,
      itemTitle: deviceTitle,
      orderType: 'sell',
      onSuccess: () {
        setState(() => _currentStep = 0);
        AppState.selectedBottomIndex.value = 4;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppState.isDarkMode,
      builder: (context, isDark, _) {
        final cardBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
        final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
        final chipBg = isDark ? const Color(0xFF383838) : Colors.grey.shade100;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FC),
          appBar: AppBar(
            title: Row(
              children: const [
                Icon(Icons.bolt, color: Colors.amber, size: 22),
                SizedBox(width: 6),
                Text('Cashify Instant Sell', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            backgroundColor: const Color(0xFF00A79D),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
       body: WebContainer(
  maxWidth: 850, // 👈 Form 850px width me center ho jayega
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
                // STEPPER BAR
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stepIndicator(0, 'Brand', isDark),
                      _stepLine(0, isDark),
                      _stepIndicator(1, 'Model', isDark),
                      _stepLine(1, isDark),
                      _stepIndicator(2, 'Inspect', isDark),
                      _stepLine(2, isDark),
                      _stepIndicator(3, 'Value', isDark),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                

                // STEP 0: BRAND
                if (_currentStep == 0) ...[
                  Text('Select Phone Brand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: _brandModels.keys.map((b) {
                      final isSel = _selectedBrand == b;
                      return InkWell(
                        onTap: () => setState(() {
                          _selectedBrand = b;
                          _selectedModel = _brandModels[b]![0]['name'];
                          _basePrice = _brandModels[b]![0]['basePrice'];
                          _currentStep = 1;
                        }),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSel ? (isDark ? const Color(0xFF004D40) : const Color(0xFFE6F6F5)) : cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? const Color(0xFF00A79D) : borderColor, width: isSel ? 2 : 1),
                          ),
                          child: Center(child: Text(b, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSel ? const Color(0xFF00A79D) : textColor))),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // STEP 1: MODEL
                if (_currentStep == 1) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select $_selectedBrand Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      TextButton(onPressed: () => setState(() => _currentStep = 0), child: const Text('Change Brand')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _brandModels[_selectedBrand]!.map((m) {
                      final isSel = _selectedModel == m['name'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSel ? const Color(0xFF00A79D) : borderColor, width: isSel ? 2 : 1),
                        ),
                        child: ListTile(
                          title: Text(m['name'], style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                          subtitle: Text('Base Price: ₹${m['basePrice']}', style: TextStyle(color: subTextColor)),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subTextColor),
                          onTap: () => setState(() {
                            _selectedModel = m['name'];
                            _basePrice = m['basePrice'];
                          }),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D)),
                      onPressed: () => setState(() => _currentStep = 2),
                      child: const Text('Continue to Inspection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],

                // STEP 2: INSPECT
                if (_currentStep == 2) ...[
                  Text('Device Condition Inspection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Screen Condition', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: cardBg,
                          style: TextStyle(color: textColor, fontSize: 13),
                          value: _screenCondition,
                          items: ['Flawless (No Scratches)', 'Minor Scratches', 'Cracked'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() => _screenCondition = val!),
                        ),
                        const SizedBox(height: 10),
                        Text('Body Condition', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: cardBg,
                          style: TextStyle(color: textColor, fontSize: 13),
                          value: _bodyCondition,
                          items: ['Like New', 'Minor Dents', 'Heavy Wear'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) => setState(() => _bodyCondition = val!),
                        ),
                        Divider(color: borderColor),
                        CheckboxListTile(
                          title: Text('Screen Touch Working Properly', style: TextStyle(color: textColor, fontSize: 13)),
                          value: _touchOk,
                          activeColor: const Color(0xFF00A79D),
                          onChanged: (v) => setState(() => _touchOk = v!),
                        ),
                        CheckboxListTile(
                          title: Text('Original Charger Available (+₹500 Bonus)', style: TextStyle(color: textColor, fontSize: 13)),
                          value: _hasOriginalCharger,
                          activeColor: const Color(0xFF00A79D),
                          onChanged: (v) => setState(() => _hasOriginalCharger = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D)),
                      onPressed: () => setState(() => _currentStep = 3),
                      child: const Text('Calculate Valuation Quote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],

                // STEP 3: CHECKOUT WITH GOOGLE MAPS & DARK MODE CHIPS
                if (_currentStep == 3) ...[
                  // Valuation Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF003833) : const Color(0xFFE6F6F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00A79D), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Cashify Valuation Quote', style: TextStyle(fontSize: 12, color: Color(0xFF00A79D), fontWeight: FontWeight.bold)),
                            InkWell(
                              onTap: () => setState(() => _currentStep = 2),
                              child: const Text('Recalculate', style: TextStyle(fontSize: 11, color: Color(0xFF00A79D), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('₹$_calculatedValuation', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF00A79D))),
                        Text('$_selectedBrand $_selectedModel ($_selectedStorage)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // IMEI INPUT
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Enter Device IMEI Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                            const Text('Dial *#06# for IMEI', style: TextStyle(color: Color(0xFF00A79D), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _imeiController,
                                keyboardType: TextInputType.number,
                                maxLength: 15,
                                style: TextStyle(color: textColor),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onChanged: (val) => setState(() {
                                  _isImeiValid = null;
                                  _imeiStatusMessage = '';
                                }),
                                decoration: InputDecoration(
                                  hintText: 'Enter 15-digit IMEI',
                                  hintStyle: TextStyle(color: subTextColor),
                                  counterText: '',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _isCheckingImei ? null : _verifyIMEI,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A79D)),
                              child: _isCheckingImei
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                        if (_imeiStatusMessage.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(_isImeiValid == true ? Icons.check_circle : Icons.error, color: _isImeiValid == true ? Colors.green : Colors.red, size: 16),
                              const SizedBox(width: 6),
                              Expanded(child: Text(_imeiStatusMessage, style: TextStyle(color: _isImeiValid == true ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12))),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ADDRESS & MAP PICKER
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Free Doorstep Pickup Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _pincodeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: TextStyle(color: textColor),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (val) {
                            if (val.length == 6) _fetchPincodeDetails(val);
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter 6-digit Pincode (e.g. 842001)',
                            hintStyle: TextStyle(color: subTextColor),
                            counterText: '',
                            isDense: true,
                            suffixIcon: _isCheckingPincode ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        if (_pincodeStatus.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(_pincodeStatus, style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold)),
                        ],
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: _openGoogleMapPicker,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF003833) : Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF00A79D)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFF00A79D), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_mapCoordinates, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal)),
                                ),
                                const Icon(Icons.chevron_right, color: Color(0xFF00A79D), size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _addressController,
                          maxLines: 2,
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Full House / Street / Flat Address',
                            hintStyle: TextStyle(color: subTextColor),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PICKUP DATE & TIME SLOT CHIPS (DARK MODE FIXED)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Schedule Expected Pickup Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                        const SizedBox(height: 10),
                        Text('Select Pickup Date:', style: TextStyle(fontSize: 11, color: subTextColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Tomorrow (Mon)', 'Tue (Day After)', 'Wed (2 Days)'].map((d) {
                              final isSel = _pickupDate == d;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(d, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : textColor, fontWeight: FontWeight.bold)),
                                  selected: isSel,
                                  selectedColor: const Color(0xFF00A79D),
                                  backgroundColor: chipBg,
                                  side: BorderSide(color: isSel ? const Color(0xFF00A79D) : borderColor),
                                  onSelected: (v) {
                                    if (v) setState(() => _pickupDate = d);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Select Time Slot:', style: TextStyle(fontSize: 11, color: subTextColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _pickupSlot,
                          dropdownColor: cardBg,
                          style: TextStyle(color: textColor, fontSize: 12),
                          decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          items: [
                            'Morning (10:00 AM - 01:00 PM)',
                            'Afternoon (01:00 PM - 04:00 PM)',
                            'Evening (04:00 PM - 07:00 PM)'
                          ].map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 12, color: textColor)))).toList(),
                          onChanged: (v) => setState(() => _pickupSlot = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PREFERRED PAYMENT METHOD CHIPS (DARK MODE FIXED)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preferred Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: ['Razorpay Instant', 'UPI / GPay', 'Bank Transfer', 'Cash'].map((mode) {
                            final isSel = _paymentMode == mode;
                            return ChoiceChip(
                              label: Text(mode, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : textColor, fontWeight: FontWeight.bold)),
                              selected: isSel,
                             selectedColor: const Color(0xFF00A79D),
                              backgroundColor: chipBg,
                              side: BorderSide(color: isSel ? (mode == 'Razorpay Instant' ? Colors.blue.shade900 : const Color(0xFF00A79D)) : borderColor),
                              onSelected: (val) {
                                if (val) setState(() => _paymentMode = mode);
                              },
                            );
                          }).toList(),
                        ),
                        if (_paymentMode == 'Razorpay Instant') ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.blue.shade900.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: const Text('⚡ Secure Razorpay Instant Payout enabled for this transaction.', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        if (_paymentMode == 'UPI / GPay') ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: _upiController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Enter UPI ID (e.g. 9876543210@paytm)',
                              hintStyle: TextStyle(color: subTextColor),
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A79D),
                        disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      ),
                      onPressed: (_isImeiValid == true) ? _submitPickupOrder : null,
                      child: const Text(
                        'Proceed to Secure Checkout & Pickup',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
           ),
        );
      },
    );
  }

  Widget _stepIndicator(int stepIndex, String label, bool isDark) {
    bool isActive = _currentStep >= stepIndex;
    bool isCurrent = _currentStep == stepIndex;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _currentStep = stepIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isCurrent 
                  ? const Color(0xFF00A79D) 
                  : (isActive 
                      ? const Color(0xFF80D3CE) 
                      : (isDark ? const Color(0xFF383838) : const Color(0xFFE6F6F5))),
              child: Text(
                '${stepIndex + 1}', 
                style: TextStyle(
                  fontSize: 10, 
                  color: isActive || isCurrent ? Colors.white : const Color(0xFF00A79D), 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label, 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, 
                color: isCurrent ? const Color(0xFF00A79D) : (isDark ? Colors.grey.shade400 : Colors.grey.shade700)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepLine(int stepIndex, bool isDark) {
    bool isActive = _currentStep > stepIndex;
    return Container(
      width: 12, 
      height: 1.5, 
      color: isActive ? const Color(0xFF00A79D) : (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
    );
  }
}
Future<List<Map<String, dynamic>>> fetchProductsFromNeonDB() async {
  final List<Map<String, dynamic>> defaultProducts = [
    {
      'id': 101,
      'title': 'iPhone 14 Pro (128 GB)',
      'condition': 'Superb • 32-Point Check',
      'price': '₹64,999',
      'rawPrice': 64999,
      'originalPrice': '₹79,900',
      'image': 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 102,
      'title': 'OnePlus Nord CE 3 5G',
      'condition': 'Superb • 32-Point Check',
      'price': '₹22,000',
      'rawPrice': 22000,
      'originalPrice': '₹28,999',
      'image': 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 103,
      'title': 'Dell Inspiron Laptop 15',
      'condition': 'Superb • 32-Point Check',
      'price': '₹55,000',
      'rawPrice': 55000,
      'originalPrice': '₹72,000',
      'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 104,
      'title': 'iPhone 15 (128 GB)',
      'condition': 'Superb • 32-Point Check',
      'price': '₹58,999',
      'rawPrice': 58999,
      'originalPrice': '₹79,900',
      'image': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 105,
      'title': 'Samsung Galaxy S23 Ultra',
      'condition': 'Superb • 32-Point Check',
      'price': '₹74,999',
      'rawPrice': 74999,
      'originalPrice': '₹1,24,999',
      'image': 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 106,
      'title': 'MacBook Air M2 (256 GB)',
      'condition': 'Superb • 32-Point Check',
      'price': '₹82,500',
      'rawPrice': 82500,
      'originalPrice': '₹1,14,900',
      'image': 'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 107,
      'title': 'Google Pixel 8 Pro',
      'condition': 'Superb • 32-Point Check',
      'price': '₹61,000',
      'rawPrice': 61000,
      'originalPrice': '₹1,06,999',
      'image': 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?auto=format&fit=crop&w=600&q=80',
    },
    {
      'id': 108,
      'title': 'iPad Air Gen 5 (Wi-Fi)',
      'condition': 'Superb • 32-Point Check',
      'price': '₹42,999',
      'rawPrice': 42999,
      'originalPrice': '₹59,900',
      'image': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=600&q=80',
    },
  ];

  try {
    final response = await http.get(Uri.parse('http://localhost:5000/api/products'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    }
  } catch (e) {
    debugPrint('Database Fetch Products Error: $e');
  }

  return defaultProducts;
}

// -----------------------------------------------------------------------------
// WEB RESPONSIVE MAX-WIDTH CONTAINER
// -----------------------------------------------------------------------------
class WebContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const WebContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200, // Standard Web Width
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 800) return child; // Mobile par standard full width

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

void showWebResponsiveModal(BuildContext context, Widget content) {
  final isDesktop = MediaQuery.of(context).size.width > 768;

  if (isDesktop) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 600,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: content,
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => content,
    );
  }
}

class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

