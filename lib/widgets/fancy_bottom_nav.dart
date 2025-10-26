import 'package:flutter/material.dart';

class FancyNavItem {
  const FancyNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class FancyBottomNav extends StatelessWidget {
  const FancyBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.onCenterTap,
  });

  final List<FancyNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCenterTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant;

    const barHeight = 72.0;
    const bubbleSize = 60.0; // Bigger for center FAB
    const bubbleElevation = 8.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background bar
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                height: barHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // First two items
                    ...List.generate(2, (i) {
                      final item = items[i];
                      final selected = i == currentIndex;
                      return _NavButton(
                        icon: item.icon,
                        label: item.label,
                        selected: selected,
                        selectedColor: selectedColor,
                        unselectedColor: unselectedColor,
                        onTap: () => onTap(i),
                      );
                    }),
                    // Center FAB placeholder (keeps spacing)
                    const SizedBox(width: 60),
                    // Last two items
                    ...List.generate(items.length - 2, (i) {
                      final realIndex = i + 2;
                      final item = items[realIndex];
                      final selected = realIndex == currentIndex;
                      return _NavButton(
                        icon: item.icon,
                        label: item.label,
                        selected: selected,
                        selectedColor: selectedColor,
                        unselectedColor: unselectedColor,
                        onTap: () => onTap(realIndex),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Floating Center Plus Button
            Positioned(
              left: 0,
              right: 0,
              top: -bubbleSize / 2,
              child: Center(
                child: GestureDetector(
                  onTap: onCenterTap,
                  child: Material(
                    color: selectedColor,
                    elevation: bubbleElevation,
                    shape: const CircleBorder(),
                    child: SizedBox(
                      width: bubbleSize,
                      height: bubbleSize,
                      child: const Icon(Icons.add, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
