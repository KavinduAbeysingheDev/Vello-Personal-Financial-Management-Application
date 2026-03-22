import 'package:flutter/material.dart';

class VelloTopBar extends StatelessWidget implements PreferredSizeWidget {
  const VelloTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF004D40), // Figma Dark Teal
      elevation: 0,
      toolbarHeight: 70,
      titleSpacing: 12,
      title: Row(
        children: [
          Container(
            width: 44, // Slightly smaller match
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                'assets/images/vello_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "Vello",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile Panel coming soon!')),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
=======
import 'package:flutter/material.dart';

class VelloTopBar extends StatelessWidget implements PreferredSizeWidget {
  const VelloTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Vello', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
>>>>>>> b4cf5d3 (feat(ui): add new home screen layout, top bar, and drawer widgets)
