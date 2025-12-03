import 'package:emoji_selector/src/category_icon.dart';
import 'package:flutter/material.dart';

/// Category selector
class CategorySelector extends StatefulWidget {
  final bool selected;
  final CategoryIcon icon;
  final Function() onSelected;
  final Color? primaryColor;

  const CategorySelector({
    Key? key,
    required this.selected,
    required this.icon,
    required this.onSelected,
    this.primaryColor,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Updated colors according to Cute Minimalist guide
  Color get primaryColor => widget.primaryColor ?? const Color(0xFF4F42FF);
  Color get secondaryColor => const Color(0xFF6B7280);
  Color get surfaceColor => const Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        if (!widget.selected) {
          _animationController.forward();
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        if (!widget.selected) {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.selected ? 1.0 : _scaleAnimation.value,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: widget.selected
                    ? primaryColor
                    : _isHovered
                        ? surfaceColor
                        : surfaceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9CA3AF)
                        .withValues(alpha: widget.selected ? 0.1 : 0.06),
                    offset: const Offset(0, 2),
                    blurRadius: widget.selected ? 8 : 6,
                  ),
                ],
                border: Border.all(
                  color: widget.selected
                      ? primaryColor.withValues(alpha: 0.3)
                      : const Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onSelected,
                  child: Center(
                    child: Icon(
                      widget.icon.icon,
                      size: 20,
                      color: widget.selected
                          ? Colors.white
                          : (_isHovered ? primaryColor : secondaryColor),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
