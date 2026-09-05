import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../theme/app_theme.dart';

class MenuItemData {
  final String label;
  final IconData icon;
  final String path;
  final String? subtitle;
  const MenuItemData(this.label, this.icon, this.path, {this.subtitle});
}

class RoleMenuDrawer extends StatelessWidget {
  final String role;
  const RoleMenuDrawer({super.key, required this.role});

  List<MenuItemData> get items {
    if (role == 'admin') {
      return const [
        MenuItemData('Dashboard', Icons.dashboard_outlined, '/admin'),
        MenuItemData('Pelanggan', Icons.people_outline, '/admin/customers'),
        MenuItemData('Paket', Icons.inventory_2_outlined, '/admin/module/packages'),
        MenuItemData('Billing', Icons.receipt_long_outlined, '/admin/invoices'),
        MenuItemData('Pembayaran', Icons.payments_outlined, '/admin/module/payments'),
        MenuItemData('Support', Icons.support_agent_outlined, '/admin/module/support'),
        MenuItemData('Jaringan', Icons.account_tree_outlined, '/admin/module/network'),
        MenuItemData('Aset OLT/ODP', Icons.dns_outlined, '/admin/module/network-assets'),
        MenuItemData('Monitor OLT', Icons.monitor_heart_outlined, '/admin/module/olt'),
        MenuItemData('Teknisi', Icons.engineering_outlined, '/admin/module/technicians'),
        MenuItemData('Coverage', Icons.map_outlined, '/admin/module/coverage'),
        MenuItemData('Komunikasi', Icons.campaign_outlined, '/admin/module/communications'),
        MenuItemData('Ops Comms', Icons.cell_tower_outlined, '/admin/module/ops-comms'),
        MenuItemData('Campaigns', Icons.send_outlined, '/admin/module/campaigns'),
        MenuItemData('Laporan', Icons.bar_chart_outlined, '/admin/module/reports'),
        MenuItemData('Material', Icons.inventory_outlined, '/admin/module/materials'),
        MenuItemData('Users', Icons.manage_accounts_outlined, '/admin/users'),
        MenuItemData('Roles', Icons.admin_panel_settings_outlined, '/admin/module/roles'),
        MenuItemData('Security', Icons.shield_outlined, '/admin/module/security'),
        MenuItemData('Website Pages', Icons.language_outlined, '/admin/module/pages'),
        MenuItemData('Settings', Icons.settings_outlined, '/admin/module/settings'),
        MenuItemData('WA Bisnis', Icons.chat_outlined, '/admin/module/whatsapp'),
      ];
    }
    if (role == 'technician') {
      return const [
        MenuItemData('Beranda', Icons.home_outlined, '/tech'),
        MenuItemData('Tugas Saya', Icons.checklist_outlined, '/tech/jobs'),
        MenuItemData('Peta Lokasi', Icons.map_outlined, '/tech/map'),
        MenuItemData('Material & Stok', Icons.inventory_2_outlined, '/tech/materials'),
        MenuItemData('Tugas (API)', Icons.assignment_outlined, '/tech/module/tech-jobs'),
        MenuItemData('Notifikasi', Icons.notifications_none, '/tech/module/notifications'),
        MenuItemData('Pengumuman', Icons.campaign_outlined, '/tech/module/announcements'),
        MenuItemData('Bantuan', Icons.help_outline, '/tech/module/help'),
      ];
    }
    return const [
      MenuItemData('Beranda', Icons.home_outlined, '/app'),
      MenuItemData('Layanan Saya', Icons.wifi_outlined, '/app/module/service'),
      MenuItemData('Tagihan', Icons.receipt_long_outlined, '/app/invoices'),
      MenuItemData('Tiket Gangguan', Icons.support_agent_outlined, '/app/tickets'),
      MenuItemData('Pembayaran', Icons.credit_card_outlined, '/app/module/payments'),
      MenuItemData('Dokumen', Icons.folder_open_outlined, '/app/module/documents'),
      MenuItemData('Bantuan', Icons.help_outline, '/app/module/help'),
      MenuItemData('Pengaturan Akun', Icons.person_outline, '/app/profile'),
    ];
  }

  String get title => role == 'admin'
      ? 'Admin Menu'
      : role == 'technician'
          ? 'Portal Teknisi'
          : 'Portal Pelanggan';

  Color get accent => role == 'admin'
      ? AppColors.admin
      : role == 'technician'
          ? AppColors.tech
          : AppColors.cyan;

  String _initials(String? name) {
    final value = (name ?? '').trim();
    if (value.isEmpty) return 'M';
    final parts = value.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Exact match, or home route when location is exactly that path.
  bool _isSelected(String location, String path) {
    if (location == path) return true;
    // Treat module sub-routes as selected only on exact path (no prefix flood).
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final userName = auth.user?.name.trim();
    final location = GoRouterState.of(context).matchedLocation;
    // Capture router before drawer closes so navigation survives dispose.
    final router = GoRouter.of(context);

    return Drawer(
      elevation: 24,
      width: (MediaQuery.sizeOf(context).width * .88).clamp(280.0, 390.0).toDouble(),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: .65),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 10, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: .18),
                    AppColors.card.withValues(alpha: .72),
                    AppColors.surface,
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: accent.withValues(alpha: .22)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: .30),
                          AppColors.card,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: accent.withValues(alpha: .55)),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: .12),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(userName),
                      style: TextStyle(
                        color: accent,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MPorT',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            color: accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (userName != null && userName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup menu',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = _isSelected(location, item.path);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Material(
                      color: selected
                          ? accent.withValues(alpha: .12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        splashColor: accent.withValues(alpha: .10),
                        highlightColor: accent.withValues(alpha: .06),
                        onTap: () {
                          final target = item.path;
                          Navigator.of(context).pop();
                          // Navigate after drawer has started closing.
                          // Use captured router so we don't depend on drawer context.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            router.go(target);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? accent.withValues(alpha: .25)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 22,
                                color: selected ? accent : AppColors.muted,
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: selected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: selected
                                        ? AppColors.text
                                        : AppColors.muted,
                                  ),
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: accent,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Material(
                color: AppColors.danger.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await auth.logout();
                    router.go('/login');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, color: AppColors.danger),
                        SizedBox(width: 13),
                        Text(
                          'Keluar',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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
