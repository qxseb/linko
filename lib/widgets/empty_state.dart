import 'package:flutter/material.dart';
import '../utils/theme.dart';

class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 56,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontSize: 20,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.message,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (widget.action != null) ...[
                  const SizedBox(height: 28),
                  widget.action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
