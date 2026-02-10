class FormatterUtil {
  /// Formats a phone number string to a "beautiful" format.
  /// Example: 998901234567 -> +998 (90) 123-45-67
  static String formatPhone(String phone) {
    if (phone.isEmpty) return phone;
    
    // Remove all non-digit characters
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    
    // If it's a 12-digit number starting with 998
    if (digits.length == 12 && digits.startsWith('998')) {
      return '+998 (${digits.substring(3, 5)}) ${digits.substring(5, 8)} ${digits.substring(8, 10)} ${digits.substring(10, 12)}';
    }
    
    // If it's a 9-digit number (local Uzbekistan format)
    if (digits.length == 9) {
      return '+998 (${digits.substring(0, 2)}) ${digits.substring(2, 5)} ${digits.substring(5, 7)} ${digits.substring(7, 9)}';
    }

    // If it starts with + and has 12 digits
    if (phone.startsWith('+') && digits.length == 12 && digits.startsWith('998')) {
       return '+998 (${digits.substring(3, 5)}) ${digits.substring(5, 8)} ${digits.substring(8, 10)} ${digits.substring(10, 12)}';
    }

    return phone;
  }
}
