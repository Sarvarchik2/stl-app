import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:stl_app/core/app_colors.dart';
import 'package:stl_app/core/di/service_locator.dart';
import 'package:stl_app/features/auth/data/repositories/auth_repository.dart';
import 'package:stl_app/core/widgets/top_notification.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepository = sl<AuthRepository>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _phoneFormatter = MaskTextInputFormatter(
    mask: '+998 ## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  Future<void> _handleRegister() async {
    final phoneDigits = _phoneFormatter.getUnmaskedText();
    final phone = '998$phoneDigits';
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final password = _passwordController.text.trim();
    
    if (phoneDigits.length < 9 || firstName.isEmpty || lastName.isEmpty || password.isEmpty) {
      TopNotification.show(
        context,
        message: phoneDigits.length < 9 
            ? 'Введите полный номер телефона' 
            : 'Пожалуйста, заполните все поля',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authRepository.register(
        phone: phone,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      
      if (!mounted) return;
      
      TopNotification.show(
        context,
        message: response['message'] ?? 'Код отправлен!',
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            phone: phone,
            password: password,
            firstName: firstName,
            lastName: lastName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Ошибка регистрации';
      if (e is DioException) {
        final detail = e.response?.data?['detail'];
        if (detail is String) {
          errorMessage = detail;
        } else if (detail is List && detail.isNotEmpty) {
          errorMessage = detail[0]['msg']?.toString() ?? errorMessage;
        }
      }
      TopNotification.show(
        context,
        message: errorMessage,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'РЕГИСТРАЦИЯ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildInput(
                controller: _firstNameController,
                icon: Icons.person_outline,
                hint: 'Имя',
              ),
              const SizedBox(height: 16),

              _buildInput(
                controller: _lastNameController,
                icon: Icons.person_outline,
                hint: 'Фамилия',
              ),
              const SizedBox(height: 16),
              
              _buildPhoneInput(),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    hintText: 'Придумайте пароль',
                    border: InputBorder.none,
                    filled: false,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Зарегистрироваться', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Уже есть аккаунт?', style: TextStyle(color: AppColors.grey)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Войти', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.primary),
          hintText: hint,
          border: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [_phoneFormatter],
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          icon: Icon(Icons.phone_outlined, color: AppColors.primary),
          hintText: '+998 XX XXX XX XX',
          border: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }
}
