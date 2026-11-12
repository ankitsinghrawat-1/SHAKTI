import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_strings.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../services/api_config.dart';
import '../../widgets/shakti_emblem.dart';
import '../../widgets/tactile_button.dart';
import '../main_navigation_shell.dart';
import '../onboarding/safety_permissions_screen.dart';

enum AuthMode {
  welcome,
  login,
  register,
}

class SecureLoginScreen extends StatefulWidget {
  final AuthMode initialMode;

  const SecureLoginScreen({
    super.key,
    this.initialMode = AuthMode.login,
  });

  @override
  State<SecureLoginScreen> createState() => _SecureLoginScreenState();
}

class _SecureLoginScreenState extends State<SecureLoginScreen> {
  late AuthMode _currentMode;

  // Login controllers
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _loginPinController = TextEditingController();
  bool _obscureLoginPin = true;

  // Registration controllers
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regPhoneController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPinController =
      TextEditingController();
  final TextEditingController _regConfirmPinController =
      TextEditingController();
  bool _obscureRegPin = true;
  bool _obscureRegConfirmPin = true;
  bool _pairBandNow = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _loginPinController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regPinController.dispose();
    _regConfirmPinController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const MainNavigationShell(),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(opacity: anim1, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _handleLogin(SafetyProvider safety) async {
    setState(() => _errorMessage = null);
    final id = _loginIdController.text.trim();
    final pin = _loginPinController.text.trim();

    if (id.isEmpty) {
      setState(() => _errorMessage = safety.strings.isHindi
          ? 'कृपया अपना मोबाइल नंबर या शील्ड आईडी दर्ज करें।'
          : 'Please enter your registered Phone or Shield ID.');
      return;
    }

    if (pin.length != 4) {
      setState(() => _errorMessage = safety.strings.isHindi
          ? 'कृपया 4-अंकीय सुरक्षा पिन दर्ज करें।'
          : 'Please enter your 4-digit Security PIN.');
      return;
    }

    final success = await safety.authenticateWithCredentialsAsync(identifier: id, pin: pin);
    if (!mounted) return;

    if (success) {
      if (pin == '0000') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(safety.strings.isHindi
                ? 'डुरेस मोड सक्रिय: गुप्त स्क्रीन चालू, चुपचाप सतर्कता प्रेषित।'
                : 'Duress Decoy Mode Activated: Covert camouflage engaged.'),
            backgroundColor: AppColors.secondary,
          ),
        );
      } else if (!safety.isServerOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(safety.strings.isHindi
                ? 'स्थानीय प्रोटोटाइप मोड: सर्वर उपलब्ध नहीं होने पर स्थानीय प्रोफाइल से लॉगिन किया गया।'
                : 'Local Prototype Mode: Server offline. Authenticated with local device profile.'),
            backgroundColor: const Color(0xFFD97706),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      _navigateToDashboard();
    } else {
      setState(() {
        _errorMessage = safety.strings.isHindi
            ? 'अमान्य क्रेडेंशियल। कृपया पंजीकृत मोबाइल नंबर और 4-अंकीय पिन दर्ज करें।'
            : 'Invalid credentials. Use the registered phone number and 4-digit PIN.';
      });
    }
  }

  void _handleRegistration(SafetyProvider safety) async {
    setState(() => _errorMessage = null);
    final name = _regNameController.text.trim();
    final phone = _regPhoneController.text.trim();
    final email = _regEmailController.text.trim();
    final pin = _regPinController.text.trim();
    final confirmPin = _regConfirmPinController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = safety.strings.isHindi
          ? 'कृपया अपना पूरा नाम दर्ज करें।'
          : 'Please enter your full name.');
      return;
    }

    if (phone.isEmpty || phone.length < 8) {
      setState(() => _errorMessage = safety.strings.isHindi
          ? 'कृपया एक वैध मोबाइल नंबर दर्ज करें।'
          : 'Please enter a valid mobile number.');
      return;
    }

    if (pin.length != 4) {
      setState(() => _errorMessage = safety.strings.isHindi
          ? 'सुरक्षा पिन ठीक 4 अंकों का होना चाहिए।'
          : 'Security PIN must be exactly 4 digits.');
      return;
    }

    if (pin == '0000') {
      setState(() => _errorMessage = safety.strings.isHindi
          ? '0000 गुप्त डुरेस अलर्ट हेतु आरक्षित है। कृपया कोई अन्य 4-अंकीय पिन चुनें।'
          : '0000 is reserved for emergency duress. Please choose a different 4-digit PIN.');
      return;
    }

    if (pin != confirmPin) {
      setState(() => _errorMessage = safety.strings.isHindi
          ? 'दोनों सुरक्षा पिन मेल नहीं खाते।'
          : 'PINs do not match. Please verify.');
      return;
    }

    final success = await safety.registerUserAsync(
      name: name,
      phone: phone,
      email: email,
      pin: pin,
      pairBand: _pairBandNow,
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(safety.strings.isHindi
              ? 'खाता सफलतापूर्वक बनाया गया! स्वागत है, $name।'
              : 'Account created successfully! Welcome to SHAKTI, $name.'),
          backgroundColor: AppColors.emeraldSafe,
        ),
      );
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) =>
              const SafetyPermissionsScreen(isFromSettings: false),
          transitionsBuilder: (context, anim1, anim2, child) =>
              FadeTransition(opacity: anim1, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      setState(() => _errorMessage = safety.strings.isHindi
          ? 'पंजीकरण विफल रहा। कृपया सभी फ़ील्ड की जांच करें।'
          : 'Registration failed. Please review your input.');
    }
  }

  void _showForgotPinDialog(SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          safety.strings.isHindi ? 'खाता रिकवरी / पिन सहायता' : 'Account Recovery & PIN Help',
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              safety.strings.isHindi
                  ? 'अपना पंजीकृत मोबाइल नंबर और सुरक्षा पिन उपयोग करें। पिन रिकवरी सुविधा जल्द उपलब्ध होगी।'
                  : 'Use your registered phone number and security PIN. PIN recovery is not available yet.',
              style: AppTypography.bodySm.copyWith(height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(safety.strings.isHindi ? 'समझ गया' : 'Got It'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;

    return Scaffold(
      backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar with Language & Navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentMode != AuthMode.welcome)
                      GestureDetector(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            setState(() => _currentMode = AuthMode.welcome);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_back, size: 16, color: AppColors.onSurface),
                              const SizedBox(width: 4),
                              Text(
                                strings.back,
                                style: AppTypography.labelMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          const ShaktiEmblem(size: 26, animatePulse: false),
                          const SizedBox(width: 8),
                          Text(
                            'SHAKTI',
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                    // Language Switcher
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          _langChip('EN', !strings.isHindi, () => safety.setLanguage('en')),
                          const SizedBox(width: 4),
                          _langChip('हिन्दी', strings.isHindi, () => safety.setLanguage('hi')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Body Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentModeContent(safety, strings),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildCurrentModeContent(SafetyProvider safety, AppStrings strings) {
    switch (_currentMode) {
      case AuthMode.welcome:
        return _buildWelcomeView(safety, strings);
      case AuthMode.login:
        return _buildLoginView(safety, strings);
      case AuthMode.register:
        return _buildRegisterView(safety, strings);
    }
  }

  // -------------------------------------------------------------
  // Panel 1: Welcome Screen (Layout from Reference Image)
  // -------------------------------------------------------------
  Widget _buildWelcomeView(SafetyProvider safety, AppStrings strings) {
    return Column(
      key: const ValueKey('welcome_view'),
      children: [
        const SizedBox(height: 30),

        // Hero Illustration & Radial Crimson Emblem
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryFixedDim.withValues(alpha: 0.35),
                ),
              ),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerLowest,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F1F2687),
                      offset: Offset(0, 10),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Center(
                  child: ShaktiEmblem(size: 72, animatePulse: true),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // Brand Headline
        Text(
          strings.welcomeTitle.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.headlineLg.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            strings.welcomeSubtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.slateSecondary,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 48),

        // Primary Action: Create New Account
        SizedBox(
          width: double.infinity,
          child: TactileButton(
            label: strings.createAccountBtn,
            style: TactileButtonStyle.primaryCrimson,
            height: 52,
            trailingIcon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _currentMode = AuthMode.register;
              });
            },
          ),
        ),

        const SizedBox(height: 14),

        // Secondary Option: Already Have an Account? Sign In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _currentMode = AuthMode.login;
              });
            },
            child: Text(
              strings.alreadyHaveAccount,
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Subtle Decorative Safe Botanical Element at bottom
        _decorativeBottomGraphic(),
      ],
    );
  }

  // -------------------------------------------------------------
  // Panel 2: Sign In (Returning User — Reference Image Layout)
  // -------------------------------------------------------------
  Widget _buildLoginView(SafetyProvider safety, AppStrings strings) {
    return Column(
      key: const ValueKey('login_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // Header with Logo
        Row(
          children: [
            const ShaktiEmblem(size: 28, animatePulse: false),
            const SizedBox(width: 8),
            Text(
              'SHAKTI',
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Text(
          strings.signInTitle,
          style: AppTypography.headlineLg.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          strings.signInSubtitle,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.slateSecondary,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 24),

        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.secondary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Field 1: Phone or Shield ID
        Text(
          strings.phoneOrShieldLabel,
          style: AppTypography.labelMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _loginIdController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: 'e.g. 98112 40291 or SH-98112-X',
            prefixIcon: const Icon(Icons.phone_android, size: 20, color: AppColors.slateSecondary),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x18000000)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x18000000)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Field 2: Security PIN
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.securityPinLabel,
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            GestureDetector(
              onTap: () => _showForgotPinDialog(safety),
              child: Text(
                strings.forgotPin,
                style: AppTypography.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _loginPinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: _obscureLoginPin,
          decoration: InputDecoration(
            hintText: '••••',
            counterText: '',
            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.slateSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPin ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: AppColors.slateSecondary,
              ),
              onPressed: () => setState(() => _obscureLoginPin = !_obscureLoginPin),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x18000000)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x18000000)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Primary Action: Sign In Button
        SizedBox(
          width: double.infinity,
          child: TactileButton(
            label: strings.signInBtn,
            style: TactileButtonStyle.primaryCrimson,
            height: 52,
            trailingIcon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            onPressed: () => _handleLogin(safety),
          ),
        ),

        if (kDebugMode) ...[
          const SizedBox(height: 12),
          _buildServerStatusIndicator(safety),
        ],
        const SizedBox(height: 18),

        // Link to Register: Don't have an account? Sign Up
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _errorMessage = null;
                _currentMode = AuthMode.register;
              });
            },
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                children: [
                  TextSpan(text: strings.isHindi ? 'खाता नहीं है? ' : "Don't have an account? "),
                  TextSpan(
                    text: strings.isHindi ? 'नया खाता बनाएं' : 'Sign Up',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Duress Notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x15000000)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.duressNotice,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.slateSecondary,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _decorativeBottomGraphic(),
      ],
    );
  }

  // -------------------------------------------------------------
  // Panel 3: Sign Up (New User — Reference Image Layout)
  // -------------------------------------------------------------
  Widget _buildRegisterView(SafetyProvider safety, AppStrings strings) {
    return Column(
      key: const ValueKey('register_view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // Header with Logo
        Row(
          children: [
            const ShaktiEmblem(size: 28, animatePulse: false),
            const SizedBox(width: 8),
            Text(
              'SHAKTI',
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Text(
          strings.signUpTitle,
          style: AppTypography.headlineLg.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          strings.signUpSubtitle,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.slateSecondary,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 22),

        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.secondary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Field 1: Full Name
        Text(
          strings.fullNameLabel,
          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regNameController,
          decoration: InputDecoration(
            hintText: 'Full name',
            prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.slateSecondary),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x18000000)),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Field 2: Mobile Number
        Text(
          strings.mobileLabel,
          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regPhoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Mobile number',
            prefixIcon: const Icon(Icons.phone_android, size: 20, color: AppColors.slateSecondary),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x18000000)),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Field 3: Email Address
        Text(
          strings.emailLabel,
          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'e.g. ananya.sharma@shield.net',
            prefixIcon: const Icon(Icons.mail_outline, size: 20, color: AppColors.slateSecondary),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x18000000)),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Field 4: Create Security PIN
        Text(
          strings.createPinLabel,
          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regPinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: _obscureRegPin,
          decoration: InputDecoration(
            hintText: '4 Digits',
            counterText: '',
            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.slateSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegPin ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: AppColors.slateSecondary,
              ),
              onPressed: () => setState(() => _obscureRegPin = !_obscureRegPin),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x18000000)),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Field 5: Confirm Security PIN
        Text(
          strings.confirmPinLabel,
          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regConfirmPinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: _obscureRegConfirmPin,
          decoration: InputDecoration(
            hintText: 'Re-enter 4 Digits',
            counterText: '',
            prefixIcon: const Icon(Icons.check_circle_outline, size: 20, color: AppColors.slateSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegConfirmPin ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: AppColors.slateSecondary,
              ),
              onPressed: () => setState(() => _obscureRegConfirmPin = !_obscureRegConfirmPin),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x18000000)),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Checkbox: Pair Band
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _pairBandNow,
          activeColor: AppColors.primary,
          title: Text(
            strings.pairBandCheckbox,
            style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            strings.isHindi ? 'बीएलई 5.x सुरक्षित मेश से जोड़ें' : 'Pairs Nordic/ESP32 hardware telemetry',
            style: AppTypography.labelSm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
          ),
          onChanged: (val) => setState(() => _pairBandNow = val ?? true),
        ),

        const SizedBox(height: 20),

        // Primary Action: Create Shield Account
        SizedBox(
          width: double.infinity,
          child: TactileButton(
            label: strings.completeRegistrationBtn,
            style: TactileButtonStyle.primaryCrimson,
            height: 52,
            trailingIcon: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
            onPressed: () => _handleRegistration(safety),
          ),
        ),

        if (kDebugMode) ...[
          const SizedBox(height: 12),
          _buildServerStatusIndicator(safety),
        ],
        const SizedBox(height: 16),

        // Link to Login
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _errorMessage = null;
                _currentMode = AuthMode.login;
              });
            },
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurface),
                children: [
                  TextSpan(text: strings.isHindi ? 'पहले से खाता है? ' : 'Already have an account? '),
                  TextSpan(
                    text: strings.isHindi ? 'साइन इन करें' : 'Sign In',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        _decorativeBottomGraphic(),
      ],
    );
  }

  Widget _decorativeBottomGraphic() {
    return Center(
      child: Opacity(
        opacity: 0.15,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 40, height: 1, color: AppColors.primary),
            const SizedBox(width: 8),
            const Icon(Icons.spa, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Container(width: 40, height: 1, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _langChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x18000000),
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? AppColors.primary : AppColors.slateSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildServerStatusIndicator(SafetyProvider safety) {
    final isOnline = safety.isServerOnline;
    final isChecking = safety.serverConnectionStatus == ServerConnectionStatus.checking;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.emeraldLightBg
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isOnline
              ? AppColors.emeraldSafe.withValues(alpha: 0.3)
              : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline
                  ? AppColors.emeraldSafe
                  : (isChecking ? AppColors.secondary : const Color(0xFFD97706)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline
                ? (safety.strings.isHindi ? 'सर्वर ऑनलाइन • लाइव सत्र' : 'Server Online • Live API Session')
                : (isChecking
                    ? (safety.strings.isHindi ? 'कनेक्ट हो रहा है...' : 'Connecting to Server...')
                    : (safety.strings.isHindi ? 'लोकल प्रोटोटाइप मोड (सर्वर ऑफलाइन)' : 'Local Prototype Mode (Server Offline)')),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isOnline
                  ? AppColors.emeraldSafe
                  : const Color(0xFF92400E),
            ),
          ),
          if (!isOnline && !isChecking) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => safety.retryServerConnection(),
              child: Text(
                safety.strings.isHindi ? '[पुनः प्रयास]' : '[Retry]',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
