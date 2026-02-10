import 'package:flutter/material.dart';
import 'package:stl_app/core/app_colors.dart';
import 'package:stl_app/core/di/service_locator.dart';
import 'package:stl_app/features/auth/data/models/user_model.dart';
import 'package:stl_app/features/auth/data/repositories/auth_repository.dart';
import 'package:stl_app/features/auth/presentation/pages/login_screen.dart';
import 'package:stl_app/features/applications/data/repositories/application_repository.dart';
import 'package:stl_app/features/applications/data/models/application_model.dart';
import 'package:stl_app/core/localization/app_strings.dart';
import 'package:stl_app/core/utils/formatter_util.dart';
import 'personal_data_screen.dart';
import 'my_documents_screen.dart';
import 'faq_screen.dart';
import 'contact_us_screen.dart';
import 'about_app_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepository = sl<AuthRepository>();
  final ApplicationRepository _applicationRepository = sl<ApplicationRepository>();
  
  UserModel? _user;
  List<ApplicationModel> _applications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _authRepository.getMe(),
        _applicationRepository.getApplications(),
      ]);
      
      if (!mounted) return;
      setState(() {
        _user = results[0] as UserModel;
        _applications = results[1] as List<ApplicationModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      final isAuthError = _error!.contains('401') || _error!.contains('Unauthorized');
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isAuthError ? Icons.lock_outline : Icons.error_outline,
                  size: 64,
                  color: isAuthError ? AppColors.primary : Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  isAuthError ? 'Сессия истекла' : 'Что-то пошло не так',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  isAuthError 
                      ? 'Ваш токен более недействителен. Пожалуйста, войдите снова.' 
                      : 'Не удалось загрузить данные профиля. Попробуйте еще раз или выйдите из аккаунта.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Повторить'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await _authRepository.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Выйти из аккаунта',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = _user!;
    final totalApps = _applications.length;
    final activeApps = _applications.where((a) => a.status != 'completed' && a.status != 'rejected').length;
    final completedApps = _applications.where((a) => a.status == 'completed').length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          FormatterUtil.formatPhone(user.phone),
                          style: const TextStyle(color: AppColors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Personal Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.get('profile'),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                FormatterUtil.formatPhone(user.phone),
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat(totalApps.toString(), AppStrings.get('total_apps')),
                          _buildStat(activeApps.toString(), AppStrings.get('active_apps')),
                          _buildStat(completedApps.toString(), AppStrings.get('completed_apps')),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                Text(AppStrings.get('personal_data'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildMenuSection([
                  _buildMenuItem(
                    Icons.person_outline,
                    AppStrings.get('personal_data'),
                    'Имя, паспортные данные',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PersonalDataScreen(user: user)),
                    ),
                  ),
                  _buildMenuItem(
                    Icons.description_outlined,
                    AppStrings.get('my_documents'),
                    'Загруженные файлы',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyDocumentsScreen()),
                    ),
                  ),
                  _buildMenuItem(Icons.phone_android_outlined, AppStrings.get('phone'), FormatterUtil.formatPhone(user.phone)),
                ]),
                
                const SizedBox(height: 24),
                Text(AppStrings.get('settings'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildMenuSection([
                  _buildMenuItem(
                    Icons.translate, 
                    AppStrings.get('language'), 
                    _getLanguageName(AppStrings.currentLanguage),
                    onTap: _showLanguageSwitcher,
                  ),
                ]),
                
                const SizedBox(height: 24),
                Text(AppStrings.get('help'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildMenuSection([
                  _buildMenuItem(
                    Icons.help_outline, 
                    AppStrings.get('help'), 
                    'Часто задаваемые вопросы',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FaqScreen()),
                    ),
                  ),
                  _buildMenuItem(
                    Icons.contact_support_outlined, 
                    AppStrings.get('contact_us'), 
                    'Служба поддержки',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactUsScreen()),
                    ),
                  ),
                  _buildMenuItem(
                    Icons.info_outline, 
                    AppStrings.get('about_app'), 
                    'Версия 1.0.0',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutAppScreen()),
                    ),
                  ),
                ]),
                
                const SizedBox(height: 32),
                // Logout button
                GestureDetector(
                  onTap: () async {
                    await _authRepository.logout();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A0000),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.red.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          AppStrings.get('logout'),
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLanguageName(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru: return 'Русский';
      case AppLanguage.uz: return 'O\'zbekcha';
      case AppLanguage.en: return 'English';
    }
  }

  void _showLanguageSwitcher() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('language'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildLanguageOption(AppLanguage.ru, 'Русский', 'RU'),
              _buildLanguageOption(AppLanguage.uz, 'O\'zbekcha', 'UZ'),
              _buildLanguageOption(AppLanguage.en, 'English', 'EN'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(AppLanguage lang, String name, String code) {
    final isSelected = AppStrings.currentLanguage == lang;
    return GestureDetector(
      onTap: () {
        setState(() {
          AppStrings.currentLanguage = lang;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.darkGrey,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  code,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
      onTap: onTap,
    );
  }

}
