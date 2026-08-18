import 'package:flutter/material.dart';

class MenuGridItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const MenuGridItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<MenuGridItem> createState() => _MenuGridItemState();
}

class _MenuGridItemState extends State<MenuGridItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor =
        Theme.of(context).cardTheme.color ??
        (isDark ? const Color(0xFF121A26) : Colors.white);
    final lift = _isPressed ? 0.0 : (_isHovered ? -3.0 : 0.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, lift, 0),
        decoration: BoxDecoration(
          color: _isHovered
              ? Color.lerp(cardColor, widget.color, isDark ? 0.035 : 0.025)
              : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.color.withValues(alpha: _isHovered ? 0.24 : 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _isHovered
                    ? (isDark ? 0.34 : 0.12)
                    : (isDark ? 0.22 : 0.06),
              ),
              blurRadius: _isHovered ? 14 : 6,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _isPressed = value),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: _isHovered ? 1.05 : 1,
                    duration: const Duration(milliseconds: 190),
                    child: Icon(widget.icon, size: 30, color: widget.color),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.subtitle != null &&
                      widget.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.color.withValues(alpha: 0.82),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
