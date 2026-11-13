import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardPage(color: AppColors.babyPink, icon: Icons.storefront_outlined, title: 'Discover beautiful baby products', body: 'Browse a calm boutique of clothing, care, feeding and play.'),
    _OnboardPage(color: AppColors.babyBlue, icon: Icons.favorite_outline, title: "Shop for your little one's everyday needs", body: 'Save favourites, compare prices and keep the essentials in one cart.'),
    _OnboardPage(color: AppColors.mintGreen, icon: Icons.local_shipping_outlined, title: 'Enjoy easy shopping and convenient delivery', body: 'Check out with cash on delivery or a demo payment, then follow your order.'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() => context.read<AuthProvider>().completeOnboarding();

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _finish, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) => _pages[index],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final active = index == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: active ? 22 : 8,
                  decoration: BoxDecoration(color: active ? AppColors.navy : AppColors.pastelPeach, borderRadius: BorderRadius.circular(8)),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(
                label: last ? 'Get started' : 'Next',
                onPressed: () {
                  if (last) {
                    _finish();
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.color, required this.icon, required this.title, required this.body});

  final Color color;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 84, color: AppColors.navy),
          ),
          const SizedBox(height: 32),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(body, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted, height: 1.4)),
        ],
      ),
    );
  }
}
