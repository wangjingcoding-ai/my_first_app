import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:alterego/l10n/app_localizations.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Reserved for future animations if needed
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final light = Theme.of(context).brightness == Brightness.light;
    return SafeArea(
      child: Container(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Row(
                children: [
                  const AELogoIcon(size: 24),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)?.appTitle ?? 'AlterEgo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C2B4D))),
                  const Spacer(),
                  Icon(Icons.search, color: light ? Colors.black : Colors.white70),
                  const SizedBox(width: 16),
                  Icon(Icons.notifications_none, color: light ? Colors.black : Colors.white70),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: (light ? Colors.black : Colors.white).withValues(alpha: 0.12),
                    child: Icon(Icons.person, color: light ? Colors.black54 : Colors.white70, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)?.createYourStory ?? 'Create Your Story', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(AppLocalizations.of(context)?.createTagline ?? 'Shape characters, build worlds, and live adventures with AI.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 14),
              const _CtaCard(),
              const SizedBox(height: 20),
              _SectionHeader(title: AppLocalizations.of(context)?.featuredStories ?? 'Featured Stories'),
              const SizedBox(height: 12),
              _StoriesRow(
                labels: const ['Cyberpunk Noir', 'Fantasy Realm', 'Space Opera'],
                onItemTap: (label) {
                  Navigator.pushNamed(context, '/content', arguments: {
                    'title': label,
                    'subtitle': 'Your creation',
                    'body': 'Enjoy reading your story: $label',
                  });
                },
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: AppLocalizations.of(context)?.myCreations ?? 'My Creations'),
              const SizedBox(height: 12),
              _StoriesRow(
                labels: const ['Cyberpunk Noir', 'Fantasy Realm', 'Space Opera'],
                onItemTap: (label) {
                  Navigator.pushNamed(context, '/content', arguments: {
                    'title': label,
                    'subtitle': 'Your creation',
                    'body': 'Enjoy reading your story: $label',
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class AELogoIcon extends StatelessWidget {
  final double size;
  const AELogoIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF141E8C);
    const purple = Color(0xFF9D29EA);
    return Image.asset(
      'assets/images/ae_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) {
        return CustomPaint(
          size: Size(size, size),
          painter: _AEGlyphPainter(gradient: const LinearGradient(colors: [blue, purple], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        );
      },
    );
  }
}

class _AEGlyphPainter extends CustomPainter {
  final Gradient gradient;
  _AEGlyphPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);

    final w = size.width, h = size.height;
    final pathA = Path()
      ..moveTo(w * 0.12, h * 0.80)
      ..lineTo(w * 0.40, h * 0.20)
      ..lineTo(w * 0.52, h * 0.46);
    final bar = Path()
      ..moveTo(w * 0.24, h * 0.56)
      ..lineTo(w * 0.64, h * 0.56);
    final pathE = Path()
      ..moveTo(w * 0.62, h * 0.22)
      ..lineTo(w * 0.88, h * 0.22)
      ..moveTo(w * 0.60, h * 0.50)
      ..lineTo(w * 0.92, h * 0.50)
      ..moveTo(w * 0.58, h * 0.78)
      ..lineTo(w * 0.92, h * 0.78);
    final tail = Path()
      ..moveTo(w * 0.46, h * 0.62)
      ..cubicTo(w * 0.60, h * 0.68, w * 0.74, h * 0.70, w * 0.88, h * 0.66)
      ..moveTo(w * 0.44, h * 0.70)
      ..cubicTo(w * 0.62, h * 0.76, w * 0.76, h * 0.76, w * 0.92, h * 0.72);

    canvas.drawPath(pathA, paint);
    canvas.drawPath(bar, paint);
    canvas.drawPath(pathE, paint);
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant _AEGlyphPainter oldDelegate) => false;
}


class _CtaCard extends StatelessWidget {
  const _CtaCard();

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF141E8C);
    const purple = Color(0xFF9D29EA);
    final light = Theme.of(context).brightness == Brightness.light;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: (light ? Colors.black : Colors.white).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (light ? Colors.black : Colors.white).withValues(alpha: 0.08)),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  gradient: LinearGradient(colors: [blue, purple], begin: Alignment.bottomLeft, end: Alignment.topRight),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)?.ctaTitleNewCharacterWorld ?? 'New Character & World', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context)?.ctaDescCreateCharacters ?? 'Create characters, build worlds, and adventures with AI.',
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              AlterButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/create-story');
                },
                gradient: const LinearGradient(colors: [blue, purple], begin: Alignment.bottomLeft, end: Alignment.topRight),
                child: Text(AppLocalizations.of(context)?.start ?? 'Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Text(AppLocalizations.of(context)?.seeAll ?? 'See all', style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _StoriesRow extends StatelessWidget {
  final List<String> labels;
  final void Function(String label)? onItemTap;
  const _StoriesRow({required this.labels, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF141E8C);
    const purple = Color(0xFF9D29EA);
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final label = labels[i];
          return GestureDetector(
            onTap: () => onItemTap?.call(label),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [blue, purple], begin: Alignment.bottomLeft, end: Alignment.topRight),
                  ),
                  child: const Center(child: Icon(Icons.auto_awesome, color: Colors.white70)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemCount: labels.length,
      ),
    );
  }
}

// GradientTitle removed

class GradientBorder extends StatelessWidget {
  final double borderRadius;
  final Gradient gradient;
  final Widget child;
  const GradientBorder({super.key, required this.borderRadius, required this.gradient, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius - 1),
        ),
        child: child,
      ),
    );
  }
}

// AELogoStripes removed

class AlterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final LinearGradient gradient;
  const AlterButton({super.key, required this.onPressed, required this.child, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x5500F5FF), blurRadius: 20, spreadRadius: 1, offset: Offset(0, 6)),
          ],
        ),
        child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child),
      ),
    );
  }
}
