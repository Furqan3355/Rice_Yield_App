class Validators {
  // --- Email Validation ---
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    // Behtar Regex jo @ aur .com wagera sahi se check karta hai
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // --- Password Validation ---
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  // --- Name Validation ---
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length <3) {
      return 'Name must be at least 3 characters';
    }
    
    return null;
  }

  // --- Phone Normalization (Faltu characters hatane ke liye) ---
  static String normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // --- Phone Validation ---
  static String? validatePhone(String? value) {
    // Agar user ne kuch nahi likha to theek hai (Optional)
    if (value == null || value.trim().isEmpty) {
      return null; 
    }

    final cleaned = normalizePhone(value.trim());

    // Pakistan aur international numbers ke hisab se 10 se 15 digits
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Enter a valid phone number (10-15 digits)';
    }

    return null;
  }

  // --- Confirm Password Validation ---
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}