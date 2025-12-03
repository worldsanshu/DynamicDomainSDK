import 'package:emoji_selector/src/emoji_internal_data.dart';
import 'package:flutter/material.dart';

class EmojiPage extends StatelessWidget {
  final int rows;
  final int columns;
  final List<EmojiInternalData> emojis;
  final Function(EmojiInternalData) onSelected;
  final Color? primaryColor;

  const EmojiPage({
    Key? key,
    required this.rows,
    required this.columns,
    required this.emojis,
    required this.onSelected,
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectivePrimaryColor = primaryColor ?? const Color(0xFF4F42FF);

    return Container(
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate optimal item size based on available space
          // Ensure at least 3 rows are visible with proper emoji sizing
          final double availableHeight =
              constraints.maxHeight - 12; // Subtract padding
          final double availableWidth =
              constraints.maxWidth - 12; // Subtract padding

          // Calculate how many rows we want to show (minimum 3)
          const int minRows = 3;

          // Calculate maximum item height to fit at least minRows
          final double maxItemHeight =
              (availableHeight - (minRows - 1) * 6) / minRows;

          // Calculate item width based on columns
          final double itemWidth =
              (availableWidth - (columns - 1) * 6) / columns;

          // Use square items (1:1 aspect ratio) for best emoji display
          // But ensure they fit within the available height for at least 3 rows
          final double itemSize =
              itemWidth < maxItemHeight ? itemWidth : maxItemHeight;

          // Calculate the aspect ratio based on actual dimensions
          // This ensures items are properly sized
          final double childAspectRatio = itemWidth / itemSize;

          return GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              if (index >= emojis.length) return const SizedBox.shrink();
              var emoji = emojis[index];
              return _EmojiButton(
                emoji: emoji,
                primaryColor: effectivePrimaryColor,
                onSelected: () => onSelected(emoji),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmojiButton extends StatefulWidget {
  final EmojiInternalData emoji;
  final Color primaryColor;
  final VoidCallback onSelected;

  const _EmojiButton({
    required this.emoji,
    required this.primaryColor,
    required this.onSelected,
  });

  @override
  State<_EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<_EmojiButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                // color: _isHovered
                //     ? widget.primaryColor.withValues(alpha: 0.1)
                //     : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9CA3AF)
                        .withValues(alpha: _isHovered ? 0.08 : 0.06),
                    offset: const Offset(0, 2),
                    blurRadius: _isHovered ? 6 : 4,
                  ),
                ],
                border: Border.all(
                  color: _isHovered
                      ? widget.primaryColor.withValues(alpha: 0.2)
                      : const Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onSelected,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        widget.emoji.char,
                        style: const TextStyle(
                          fontSize: 36,
                          fontFamily: 'Apple Color Emoji',
                          fontFamilyFallback: ["Noto Emoji"],
                        ),
                      ),
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
