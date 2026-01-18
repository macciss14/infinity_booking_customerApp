// lib/screens/settings/settings_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../config/route_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Helper methods to access theme colors from provider
  Color _primaryColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: true).primaryColor;
  }

  Color _backgroundColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: true).backgroundColor;
  }

  Color _surfaceColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: true).surfaceColor;
  }

  Color _textColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: true).textColor;
  }

  Color _secondaryTextColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: true).secondaryTextColor;
  }

  Color _borderColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: true).borderColor;
  }

  // Available languages
  final List<Map<String, dynamic>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'am', 'name': 'Amharic', 'nativeName': 'አማርኛ'},
    {'code': 'ti', 'name': 'Tigrigna', 'nativeName': 'ትግርኛ'},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: _backgroundColor(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              _getTranslatedText('Settings', languageProvider),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _textColor(context),
              ),
            ),
            backgroundColor: _surfaceColor(context),
            foregroundColor: _textColor(context),
            elevation: 0,
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: _textColor(context),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.help_outline_rounded,
                  color: _textColor(context),
                ),
                onPressed: () {
                  RouteHelper.pushNamed(context, RouteHelper.helpAndSupport);
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // App Settings Header
                _buildSectionHeader(
                  context,
                  _getTranslatedText('App Settings', languageProvider),
                  Icons.settings_outlined,
                ),
                const SizedBox(height: 8),

                // Dark/Light Mode Toggle
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('Dark Mode', languageProvider),
                  subtitle: _getTranslatedText(
                      'Switch between light and dark theme', languageProvider),
                  leadingIcon: Icons.dark_mode_outlined,
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                      HapticFeedback.lightImpact();
                    },
                    activeColor: _primaryColor(context),
                  ),
                ),

                // Theme Color Selection
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('Theme Color', languageProvider),
                  subtitle: _getTranslatedText(
                      'Select your preferred color', languageProvider),
                  leadingIcon: Icons.color_lens_outlined,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: themeProvider.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: _borderColor(context)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        themeProvider.currentThemeName,
                        style: TextStyle(
                          fontSize: 14,
                          color: _secondaryTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showThemeSelection(context, themeProvider);
                  },
                ),

                // Language Settings
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('Language', languageProvider),
                  subtitle: _getTranslatedText(
                      'Select app language', languageProvider),
                  leadingIcon: Icons.language_outlined,
                  trailing: Text(
                    _getCurrentLanguageName(languageProvider),
                    style: TextStyle(
                      fontSize: 14,
                      color: _secondaryTextColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    _showLanguageSelection(context, languageProvider);
                  },
                ),

                const SizedBox(height: 24),

                // Preferences Header
                _buildSectionHeader(
                  context,
                  _getTranslatedText('Preferences', languageProvider),
                  Icons.tune_rounded,
                ),
                const SizedBox(height: 8),

                // Notifications Settings
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('Notifications', languageProvider),
                  subtitle: _getTranslatedText(
                      'Manage notification settings', languageProvider),
                  leadingIcon: Icons.notifications_outlined,
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      // TODO: Implement notification toggle
                    },
                    activeColor: _primaryColor(context),
                  ),
                  onTap: () {
                    RouteHelper.pushNamed(context, RouteHelper.notifications);
                  },
                ),

                // Sound Settings
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText(
                      'Sounds & Vibration', languageProvider),
                  subtitle: _getTranslatedText(
                      'Control app sounds', languageProvider),
                  leadingIcon: Icons.volume_up_outlined,
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      // TODO: Implement sound toggle
                    },
                    activeColor: _primaryColor(context),
                  ),
                ),

                // Data Saver
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('Data Saver', languageProvider),
                  subtitle:
                      _getTranslatedText('Reduce data usage', languageProvider),
                  leadingIcon: Icons.data_saver_off_outlined,
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      // TODO: Implement data saver toggle
                    },
                    activeColor: _primaryColor(context),
                  ),
                ),

                const SizedBox(height: 24),

                // Support Header
                _buildSectionHeader(
                  context,
                  _getTranslatedText('Support', languageProvider),
                  Icons.help_outline_rounded,
                ),
                const SizedBox(height: 8),

                // Help & Support
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('Help & Support', languageProvider),
                  subtitle: _getTranslatedText(
                      'Get help and contact support', languageProvider),
                  leadingIcon: Icons.help_center_outlined,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: _secondaryTextColor(context),
                  ),
                  onTap: () {
                    RouteHelper.pushNamed(context, RouteHelper.helpAndSupport);
                  },
                ),

                // FAQ
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('FAQ', languageProvider),
                  subtitle: _getTranslatedText(
                      'Frequently asked questions', languageProvider),
                  leadingIcon: Icons.question_answer_outlined,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: _secondaryTextColor(context),
                  ),
                  onTap: () {
                    RouteHelper.pushNamed(context, RouteHelper.faq);
                  },
                ),

                // Contact Us
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('Contact Us', languageProvider),
                  subtitle: _getTranslatedText(
                      'Get in touch with our team', languageProvider),
                  leadingIcon: Icons.email_outlined,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: _secondaryTextColor(context),
                  ),
                  onTap: () {
                    RouteHelper.pushNamed(context, RouteHelper.contactContent);
                  },
                ),

                // Rate App
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('Rate App', languageProvider),
                  subtitle: _getTranslatedText(
                      'Share your feedback', languageProvider),
                  leadingIcon: Icons.star_outline_rounded,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: _secondaryTextColor(context),
                  ),
                  onTap: () {
                    // TODO: Implement rate app
                  },
                ),

                const SizedBox(height: 24),

                // Legal Header
                _buildSectionHeader(
                  context,
                  _getTranslatedText('Legal', languageProvider),
                  Icons.gavel_rounded,
                ),
                const SizedBox(height: 8),

                // Terms of Service
                _buildSettingsCard(
                  context: context,
                  title:
                      _getTranslatedText('Terms of Service', languageProvider),
                  subtitle: _getTranslatedText(
                      'Read our terms and conditions', languageProvider),
                  leadingIcon: Icons.description_outlined,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: _secondaryTextColor(context),
                  ),
                  onTap: () {
                    RouteHelper.pushNamed(context, RouteHelper.termsAndPrivacy);
                  },
                ),

                // Privacy Policy
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('Privacy Policy', languageProvider),
                  subtitle: _getTranslatedText(
                      'Read our privacy policy', languageProvider),
                  leadingIcon: Icons.privacy_tip_outlined,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: _secondaryTextColor(context),
                  ),
                  onTap: () {
                    RouteHelper.pushNamed(context, RouteHelper.privacyPolicy);
                  },
                ),

                // About
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('About', languageProvider),
                  subtitle: _getTranslatedText(
                      'Learn about Infinity Booking', languageProvider),
                  leadingIcon: Icons.info_outline_rounded,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: _secondaryTextColor(context),
                  ),
                  onTap: () {
                    RouteHelper.pushNamed(context, RouteHelper.aboutContent);
                  },
                ),

                // Clear Cache
                _buildSettingsCard(
                  context: context,
                  title: _getTranslatedText('Clear Cache', languageProvider),
                  subtitle: _getTranslatedText(
                      'Free up storage space', languageProvider),
                  leadingIcon: Icons.cleaning_services_outlined,
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: _secondaryTextColor(context),
                  ),
                  onTap: () {
                    _showClearCacheDialog(context, languageProvider);
                  },
                ),

                const SizedBox(height: 32),

                // App Version
                Center(
                  child: Text(
                    '${_getTranslatedText('Version', languageProvider)} 1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: _secondaryTextColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _primaryColor(context)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textColor(context),
              ),
            ),
          ],
        ));
  }

  // FIXED: Added named parameter for BuildContext
  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: themeProvider.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: themeProvider.borderColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  leadingIcon,
                  size: 20,
                  color: themeProvider.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: themeProvider.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelection(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: themeProvider.surfaceColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: themeProvider.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 20),

              // Dark/Light Mode Toggle
              Container(
                decoration: BoxDecoration(
                  color: themeProvider.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeProvider.borderColor),
                ),
                child: ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: themeProvider.primaryColor,
                  ),
                  title: Text(
                    themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.textColor,
                    ),
                  ),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                      Navigator.pop(context);
                    },
                    activeColor: themeProvider.primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Select Theme Color',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 16),

              // Color Selection Grid - Now with 7 colors
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: themeProvider.themes.length,
                itemBuilder: (context, index) {
                  final theme = themeProvider.themes[index];
                  final isSelected = themeProvider.selectedThemeIndex == index;

                  return GestureDetector(
                    onTap: () {
                      themeProvider.setThemeByIndex(index);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Theme changed to ${theme['name']}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme['color'],
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: themeProvider.textColor, width: 3)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: theme['color'].withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          theme['name'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? themeProvider.primaryColor
                                : themeProvider.secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: themeProvider.primaryColor),
                  foregroundColor: themeProvider.primaryColor,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSelection(
      BuildContext context, LanguageProvider languageProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: themeProvider.surfaceColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: themeProvider.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  final isSelected =
                      languageProvider.currentLanguage == lang['code'];

                  return ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeProvider.primaryColor.withOpacity(0.1)
                            : themeProvider.surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? themeProvider.primaryColor
                              : themeProvider.borderColor,
                        ),
                      ),
                      child: Icon(
                        Icons.language,
                        size: 18,
                        color: isSelected
                            ? themeProvider.primaryColor
                            : themeProvider.secondaryTextColor,
                      ),
                    ),
                    title: Text(
                      '${lang['name']} (${lang['nativeName']})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: themeProvider.textColor,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded,
                            color: themeProvider.primaryColor)
                        : null,
                    onTap: () {
                      languageProvider.setLanguage(lang['code']);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to ${lang['name']}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: themeProvider.primaryColor),
                  foregroundColor: themeProvider.primaryColor,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showClearCacheDialog(
      BuildContext context, LanguageProvider languageProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getTranslatedText('Clear Cache', languageProvider),
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          _getTranslatedText(
              'Are you sure you want to clear app cache? This action cannot be undone.',
              languageProvider),
          style: TextStyle(color: themeProvider.secondaryTextColor),
        ),
        backgroundColor: themeProvider.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _getTranslatedText('Cancel', languageProvider),
              style: TextStyle(color: themeProvider.secondaryTextColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear cache
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_getTranslatedText(
                      'Cache cleared successfully', languageProvider)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.primaryColor,
            ),
            child: Text(
              _getTranslatedText('Clear', languageProvider),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getTranslatedText(String text, LanguageProvider languageProvider) {
    if (languageProvider.currentLanguage == 'am') {
      switch (text) {
        case 'Settings':
          return 'ማቀናበሪያ';
        case 'App Settings':
          return 'የመተግበሪያ ማቀናበሪያ';
        case 'Dark Mode':
          return 'ጨለማ ሞድ';
        case 'Switch between light and dark theme':
          return 'በብርሃን እና በጨለማ ገጽታ መካከል ቀይር';
        case 'Theme Color':
          return 'የገጽታ ቀለም';
        case 'Select your preferred color':
          return 'የሚወዱትን ቀለም ይምረጡ';
        case 'Language':
          return 'ቋንቋ';
        case 'Select app language':
          return 'የመተግበሪያ ቋንቋ ይምረጡ';
        case 'Preferences':
          return 'ምርጫዎች';
        case 'Notifications':
          return 'ማሳወቂያዎች';
        case 'Manage notification settings':
          return 'የማሳወቂያ ማቀናበሪያዎችን ያቀናብሩ';
        case 'Sounds & Vibration':
          return 'ድምጾች እና መንቀጥቀጥ';
        case 'Control app sounds':
          return 'የመተግበሪያ ድምጾችን ያቀናብሩ';
        case 'Data Saver':
          return 'የውሂብ ቆጣቢ';
        case 'Reduce data usage':
          return 'የውሂብ አጠቃቀም ይቀንሱ';
        case 'Support':
          return 'ድጋፍ';
        case 'Help & Support':
          return 'እገዛ እና ድጋፍ';
        case 'Get help and contact support':
          return 'እገዛ ያግኙ እና ድጋፍን ያነጋግሩ';
        case 'FAQ':
          return 'ተደጋግሞ የሚነሱ ጥያቄዎች';
        case 'Frequently asked questions':
          return 'ተደጋግሞ የሚነሱ ጥያቄዎች';
        case 'Contact Us':
          return 'አግኙን';
        case 'Get in touch with our team':
          return 'ከቡድናችን ጋር ይገናኙ';
        case 'Rate App':
          return 'መተግበሪያውን ደረጃ ይስጡ';
        case 'Share your feedback':
          return 'አስተያየትዎን ያጋሩ';
        case 'Legal':
          return 'ሕጋዊ';
        case 'Terms of Service':
          return 'የአገልግሎት ውሎች';
        case 'Read our terms and conditions':
          return 'የአገልግሎት ውሎቻችንን ያንቡ';
        case 'Privacy Policy':
          return 'የግላዊነት ፖሊሲ';
        case 'Read our privacy policy':
          return 'የግላዊነት ፖሊሲያችንን ያንቡ';
        case 'About':
          return 'ስለ እኛ';
        case 'Learn about Infinity Booking':
          return 'ስለ Infinity Booking ይወቁ';
        case 'Clear Cache':
          return 'መደበቂያ አጽዳ';
        case 'Free up storage space':
          return 'የማከማቻ ቦታ ነፃ ያድርጉ';
        case 'Are you sure you want to clear app cache? This action cannot be undone.':
          return 'መተግበሪያውን መደበቂያ ማጽዳት እርግጠኛ ነዎት? ይህ ተግባር መልሶ ሊመለስ አይችልም።';
        case 'Cancel':
          return 'ሰርዝ';
        case 'Clear':
          return 'አጽዳ';
        case 'Cache cleared successfully':
          return 'መደበቂያ በሚገባ ተነጽቷል';
        case 'Version':
          return 'ስሪት';
        default:
          return text;
      }
    } else if (languageProvider.currentLanguage == 'ti') {
      switch (text) {
        case 'Settings':
          return 'ምርጫታት';
        case 'App Settings':
          return 'ምርጫታት ኣፕሊኬሽን';
        case 'Dark Mode':
          return 'ጸሊም ሞድ';
        case 'Switch between light and dark theme':
          return 'ብጸሓይን ጸሊምን ገጽታ መንጎ ቀይር';
        case 'Theme Color':
          return 'ሕብሪ ገጽታ';
        case 'Select your preferred color':
          return 'ቅቡል ሕብሪ ምረጽ';
        case 'Language':
          return 'ቋንቋ';
        case 'Select app language':
          return 'ቋንቋ ኣፕሊኬሽን ምረጽ';
        case 'Preferences':
          return 'ቅቡላት';
        case 'Notifications':
          return 'መግለጺታት';
        case 'Manage notification settings':
          return 'ምርጫታት መግለጺታት ኣስተድድር';
        case 'Sounds & Vibration':
          return 'ድምጺታት ከምኡውን መንቀጥቀጥ';
        case 'Control app sounds':
          return 'ድምጺታት ኣፕሊኬሽን ኣስተድድር';
        case 'Data Saver':
          return 'ውህደት ኣለቃዒ';
        case 'Reduce data usage':
          return 'ውህደት ኣጠቓቕማ ኣንክስ';
        case 'Support':
          return 'ደገፍ';
        case 'Help & Support':
          return 'ሓገዝ ከምኡውን ደገፍ';
        case 'Get help and contact support':
          return 'ሓገዝ ርኸብ ከምኡውን ደገፍ ተራኸብ';
        case 'FAQ':
          return 'ተደጋጊሞም ዚሕተቱ ሕቶታት';
        case 'Frequently asked questions':
          return 'ተደጋጊሞም ዚሕተቱ ሕቶታት';
        case 'Contact Us':
          return 'ርኸብና';
        case 'Get in touch with our team':
          return 'ምስ ጋንታና ተራኸብ';
        case 'Rate App':
          return 'ኣፕሊኬሽን ደረጃ ሃብ';
        case 'Share your feedback':
          return 'ርእይቶኻ ኣካፍል';
        case 'Legal':
          return 'ሕጋዊ';
        case 'Terms of Service':
          return 'ውዕላት ኣገልግሎት';
        case 'Read our terms and conditions':
          return 'ውዕላት ኣገልግሎትና ኣንብብ';
        case 'Privacy Policy':
          return 'ፖሊሲ ስለይ';
        case 'Read our privacy policy':
          return 'ፖሊሲ ስለይና ኣንብብ';
        case 'About':
          return 'ብዛዕባና';
        case 'Learn about Infinity Booking':
          return 'ብዛዕባ Infinity Booking ፍለጥ';
        case 'Clear Cache':
          return 'ካሽ ኣጽርዮ';
        case 'Free up storage space':
          return 'ናይ ምዕቃብ ቦታ ነጻ ግበር';
        case 'Are you sure you want to clear app cache? This action cannot be undone.':
          return 'ኣፕሊኬሽን ካሽ ምጽራይ ርግጸኛ ዲኻ? እዚ ተግባር እዚ ናብ ቀደምኡ ክምለስ ኣይክእልን እዩ።';
        case 'Cancel':
          return 'ኣትርፍ';
        case 'Clear':
          return 'ኣጽርዮ';
        case 'Cache cleared successfully':
          return 'ካሽ ብኽብረት ተጽሪዩ ኣሎ';
        case 'Version':
          return 'ስሪት';
        default:
          return text;
      }
    }
    return text;
  }

  String _getCurrentLanguageName(LanguageProvider languageProvider) {
    final lang = _languages.firstWhere(
      (lang) => lang['code'] == languageProvider.currentLanguage,
      orElse: () => _languages[0],
    );
    return lang['name'];
  }
}
