// lib/utils/telegram_helper.dart
import 'package:url_launcher/url_launcher.dart';

class TelegramHelper {
  // Bot username (without @)
  static const String botUsername = 'InfinityBookingBot';
  
  // Open Telegram app to the bot chat
  static Future<void> openBotChat() async {
    final url = 'tg://resolve?domain=$botUsername';
    final webUrl = 'https://t.me/$botUsername';
    
    try {
      print('🔗 Opening Telegram bot: $botUsername');
      // Try to open Telegram app
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        print('✅ Opening Telegram bot in app...');
      } else {
        // Fallback to web version
        await launchUrl(Uri.parse(webUrl));
        print('✅ Opening Telegram bot in browser...');
      }
    } catch (e) {
      print('❌ Error opening Telegram: $e');
      // Open web version as last resort
      try {
        await launchUrl(Uri.parse(webUrl));
      } catch (e) {
        print('❌ Error opening web Telegram: $e');
      }
    }
  }
  
  // Open Telegram with start parameter (for auto-starting bot)
  static Future<void> openBotWithStart() async {
    final url = 'tg://resolve?domain=$botUsername&start=otp';
    final webUrl = 'https://t.me/$botUsername?start=otp';
    
    try {
      print('🔗 Opening Telegram bot with start parameter...');
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        await launchUrl(Uri.parse(webUrl));
      }
    } catch (e) {
      print('❌ Error opening Telegram with start: $e');
      await launchUrl(Uri.parse(webUrl));
    }
  }
  
  // Check if Telegram is installed
  static Future<bool> isTelegramInstalled() async {
    try {
      final url = 'tg://resolve?domain=$botUsername';
      return await canLaunchUrl(Uri.parse(url));
    } catch (e) {
      return false;
    }
  }
}