import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';
import '../utils/theme.dart';
import '../widgets/loading_overlay.dart';

class AuthScreen extends StatefulWidget {
  final String? role;
  final String? mode;

  const AuthScreen({super.key, this.role, this.mode});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _nameFocus = FocusNode();

  late bool _isLogin;
  String? _selectedRole;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.mode == 'login';
    _selectedRole = widget.role;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        if (_isLogin) {
          _emailFocus.requestFocus();
        } else {
          _nameFocus.requestFocus();
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _nameFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  UserRole? get _role {
    if (_selectedRole == null) return null;
    return _selectedRole == 'requester'
        ? UserRole.requester
        : UserRole.volunteer;
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
      if (!_isLogin) {
        _selectedRole = null;
      }
    });

    _animationController.reset();
    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        if (_isLogin) {
          _emailFocus.requestFocus();
        } else {
          _nameFocus.requestFocus();
        }
      }
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() => _errorMessage = null);

    if (_selectedRole == null) {
      setState(() => _errorMessage = 'Selectează rolul tău');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final appState = context.read<AppState>();

    try {
      if (_isLogin) {
        final validEmails = [
          'maria.popescu@email.com',
          'andrei.ionescu@email.com',
        ];

        final email = _emailController.text.trim().toLowerCase();
        if (!validEmails.contains(email)) {
          setState(() => _errorMessage =
              'Email-ul nu există în sistem. Încearcă unul din email-urile demo:\n'
                  '• maria.popescu@email.com (solicitant)\n'
                  '• andrei.ionescu@email.com (voluntar)');
          return;
        }

        await appState.login(
          email,
          _passwordController.text,
          _role!,
        );
      } else {
        await appState.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _role!,
        );
      }

      if (mounted) {
        context.go(_role == UserRole.requester ? '/requester' : '/volunteer');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return LoadingOverlay(
          isLoading: appState.isLoading,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
                tooltip: 'Înapoi',
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isLogin ? 'Bine ai revenit!' : 'Hai să începem',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? 'Intră rapid în cont'
                              : 'Creează-ți contul în 15 secunde',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Selectează rolul',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                icon: Icons.pan_tool,
                                label: 'Am nevoie\nde ajutor',
                                isSelected: _selectedRole == 'requester',
                                onTap: () =>
                                    setState(() => _selectedRole = 'requester'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RoleCard(
                                icon: Icons.favorite,
                                label: 'Vreau să\najut',
                                isSelected: _selectedRole == 'volunteer',
                                onTap: () =>
                                    setState(() => _selectedRole = 'volunteer'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            decoration: InputDecoration(
                              labelText: 'Nume',
                              hintText: 'ex: Ion Popescu',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Introdu numele';
                              }
                              if (value.trim().length < 2) {
                                return 'Prea scurt';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'ex: ion@email.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              _passwordFocus.requestFocus(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Introdu email-ul';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          decoration: InputDecoration(
                            labelText: 'Parolă',
                            hintText: _isLogin ? '' : 'Min. 6 caractere',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: _isLogin
                              ? TextInputAction.done
                              : TextInputAction.next,
                          onFieldSubmitted: (_) {
                            if (_isLogin) {
                              _submit();
                            } else {
                              _confirmPasswordFocus.requestFocus();
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Introdu parola';
                            }
                            if (!_isLogin && value.length < 6) {
                              return 'Min. 6 caractere';
                            }
                            return null;
                          },
                        ),
                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            decoration: InputDecoration(
                              labelText: 'Confirmă parola',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Parolele nu se potrivesc';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    AppTheme.errorColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppTheme.errorColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppTheme.errorColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        ElevatedButton(
                          onPressed: appState.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _isLogin ? 'Intră în cont' : 'Creează cont',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: _toggleMode,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            child: Text(
                              _isLogin
                                  ? 'Nu ai cont? Creează unul'
                                  : 'Ai deja cont? Intră aici',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: 36,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
