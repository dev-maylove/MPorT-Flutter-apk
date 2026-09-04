import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_service.dart';
import 'package:provider/provider.dart';
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
    if (role == 'admin') return const [
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
    if (role == 'technician') return const [
      MenuItemData('Beranda', Icons.home_outlined, '/tech'),
      MenuItemData('Tugas Saya', Icons.checklist_outlined, '/tech/jobs'),
      MenuItemData('Peta Lokasi', Icons.map_outlined, '/tech/map'),
      MenuItemData('Material & Stok', Icons.inventory_2_outlined, '/tech/materials'),
      MenuItemData('Tugas (API)', Icons.assignment_outlined, '/tech/module/tech-jobs'),
      MenuItemData('Notifikasi', Icons.notifications_none, '/tech/module/notifications'),
      MenuItemData('Pengumuman', Icons.campaign_outlined, '/tech/module/announcements'),
      MenuItemData('Bantuan', Icons.help_outline, '/tech/module/help'),
    ];
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

  String get title => role == 'admin' ? 'Admin Menu' : role == 'technician' ? 'Portal Teknisi' : 'Portal Pelanggan';
  Color get accent => role == 'admin' ? AppColors.admin : role == 'technician' ? AppColors.tech : AppColors.cyan;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return Drawer(
      backgroundColor: AppColors.surface,
      width: MediaQuery.sizeOf(context).width * .86,
      child: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: .7))),
              gradient: LinearGradient(colors: [accent.withValues(alpha: .16), Colors.transparent]),
            ),
            child: Row(children: [
              Container(width: 46, height: 46, decoration: BoxDecoration(color: accent.withValues(alpha: .16), borderRadius: BorderRadius.circular(14), border: Border.all(color: accent.withValues(alpha: .45))), child: Icon(Icons.router_rounded, color: accent)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('MPorT', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                Text(title, style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.w700)),
                if (auth.user?.name.isNotEmpty == true) Text(auth.user!.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ])),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ]),
          ),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final current = GoRouterState.of(context).matchedLocation;
              final selected = current == item.path || (item.path == '/admin' && current == '/admin') || (item.path == '/tech' && current == '/tech') || (item.path == '/app' && current == '/app');
              return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: ListTile(
                dense: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                selected: selected, selectedTileColor: accent.withValues(alpha: .12),
                leading: Icon(item.icon, color: selected ? accent : AppColors.muted),
                title: Text(item.label, style: TextStyle(fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.text : AppColors.muted)),
                trailing: selected ? Icon(Icons.chevron_right_rounded, size: 19, color: accent) : null,
                onTap: () { Navigator.pop(context); context.go(item.path); },
              ));
            },
          )),
          const Divider(height: 1, color: AppColors.border),
          Padding(padding: const EdgeInsets.all(12), child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
            title: const Text('Keluar', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
            onTap: () async { Navigator.pop(context); await auth.logout(); if (context.mounted) context.go('/login'); },
          )),
        ]),
      ),
    );
  }
}
