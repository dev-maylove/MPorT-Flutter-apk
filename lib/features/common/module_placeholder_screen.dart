import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_theme.dart';

/// Generic module screen used by hamburger-menu routes that do not yet have
/// a dedicated feature screen. It is intentionally a real UI, not a black
/// placeholder: it shows module identity, API state, structured records and
/// safe retry actions.
class ModulePlaceholderScreen extends StatefulWidget {
  final String role;
  final String module;

  const ModulePlaceholderScreen({
    super.key,
    required this.role,
    required this.module,
  });

  @override
  State<ModulePlaceholderScreen> createState() => _ModulePlaceholderScreenState();
}

class _ModulePlaceholderScreenState extends State<ModulePlaceholderScreen> {
  ApiResponse? _response;
  bool _loading = true;
  bool _busy = false;

  static const _titles = <String, String>{
    'reports': 'Laporan',
    'settings': 'Pengaturan',
    'notifications': 'Notifikasi',
    'announcements': 'Pengumuman',
    'tech-jobs': 'Tugas Teknisi',
    'tech-map': 'Peta Tugas',
    'customers': 'Pelanggan',
    'packages': 'Paket',
    'invoices': 'Tagihan',
    'payments': 'Pembayaran',
    'tickets': 'Tiket',
    'users': 'Pengguna',
    'technicians': 'Teknisi',
    'materials': 'Material',
    'material-requests': 'Permintaan Material',
    'material-usages': 'Pemakaian Material',
    'network-assets': 'Aset Jaringan',
    'coverage': 'Coverage',
    'communications': 'Komunikasi',
    'ops-comms': 'Ops Comms',
    'support': 'Support',
    'whatsapp': 'WhatsApp',
    'campaigns': 'Campaign',
    'security': 'Keamanan',
    'security-events': 'Event Keamanan',
    'audit-logs': 'Audit Log',
    'delivery-logs': 'Log Pengiriman',
    'subscriptions': 'Langganan',
    'pages': 'Halaman',
    'roles': 'Roles',
    'network': 'Jaringan',
    'olt': 'Monitor OLT',
    'ops': 'Operasional',
    'service': 'Layanan Saya',
    'documents': 'Dokumen',
    'help': 'Bantuan',
    'dashboard': 'Dashboard',
  };

  static const _icons = <String, IconData>{
    'reports': Icons.bar_chart_rounded,
    'settings': Icons.settings_rounded,
    'notifications': Icons.notifications_rounded,
    'announcements': Icons.campaign_rounded,
    'tech-jobs': Icons.assignment_rounded,
    'tech-map': Icons.map_rounded,
    'customers': Icons.people_rounded,
    'packages': Icons.inventory_2_rounded,
    'invoices': Icons.receipt_long_rounded,
    'payments': Icons.payments_rounded,
    'tickets': Icons.support_agent_rounded,
    'users': Icons.manage_accounts_rounded,
    'technicians': Icons.engineering_rounded,
    'materials': Icons.inventory_rounded,
    'network-assets': Icons.dns_rounded,
    'coverage': Icons.map_rounded,
    'communications': Icons.campaign_rounded,
    'ops-comms': Icons.cell_tower_rounded,
    'support': Icons.support_agent_rounded,
    'whatsapp': Icons.chat_rounded,
    'campaigns': Icons.send_rounded,
    'security': Icons.shield_rounded,
    'audit-logs': Icons.fact_check_rounded,
    'network': Icons.account_tree_rounded,
    'olt': Icons.monitor_heart_rounded,
    'service': Icons.wifi_rounded,
    'documents': Icons.folder_rounded,
    'help': Icons.help_rounded,
  };

  String get title => _titles[widget.module] ??
      widget.module.split('-').map((s) => s.isEmpty
          ? s
          : '${s[0].toUpperCase()}${s.substring(1)}').join(' ');

  IconData get icon => _icons[widget.module] ?? Icons.apps_rounded;

  Color get accent => widget.role == 'admin'
      ? AppColors.admin
      : widget.role == 'technician'
          ? AppColors.tech
          : AppColors.cyan;

  String get roleLabel => widget.role == 'admin'
      ? 'ADMIN'
      : widget.role == 'technician'
          ? 'TEKNISI'
          : 'PELANGGAN';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ModulePlaceholderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.module != widget.module || oldWidget.role != widget.role) {
      _response = null;
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final auth = context.read<AuthService>();
    final res = await auth.modules.list(widget.module);
    if (!mounted) return;

    if (res.statusCode == 401) {
      await auth.logout();
      if (mounted) context.go('/login');
      return;
    }

    setState(() {
      _response = res;
      _loading = false;
    });
  }

  Future<void> _markAllRead() async {
    if (_busy) return;
    setState(() => _busy = true);
    final res = await context.read<AuthService>().modules.markAllNotificationsRead();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(res.message),
      ),
    );
    if (res.isOk) _load();
  }

  dynamic get _payload {
    final root = _response?.json;
    if (root == null) return null;
    final data = root['data'];
    if (data is Map) {
      final inner = data['data'];
      if (inner is List) return inner;
      return data;
    }
    return data;
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(widget.role == 'admin'
        ? '/admin'
        : widget.role == 'technician'
            ? '/tech'
            : '/app');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
        actions: [
          if (widget.module == 'notifications')
            IconButton(
              tooltip: 'Tandai semua dibaca',
              onPressed: _busy ? null : _markAllRead,
              icon: const Icon(Icons.done_all_rounded),
            ),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: widget.role == 'admin'
          ? FloatingActionButton.extended(
              onPressed: _adminCreate,
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
              backgroundColor: accent,
            )
          : null,
      body: _loading
          ? _loadingView()
          : RefreshIndicator(
              color: accent,
              onRefresh: _load,
              child: _body(),
            ),
    );
  }

  Widget _loadingView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(18),
      children: [
        _heroCard(),
        const SizedBox(height: 14),
        const Center(child: Padding(
          padding: EdgeInsets.all(28),
          child: CircularProgressIndicator(),
        )),
      ],
    );
  }

  Widget _body() {
    final res = _response;
    final data = _payload;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _heroCard(),
        const SizedBox(height: 14),
        if (res == null)
          _statusCard(
            icon: Icons.cloud_off_rounded,
            title: 'Server tidak merespons',
            message: 'Belum ada respons untuk modul ini.',
            action: 'Coba lagi',
          )
        else if (!res.isOk)
          _errorCard(res)
        else if (data == null)
          _statusCard(
            icon: Icons.inbox_outlined,
            title: 'Belum ada data',
            message: 'Modul sudah terbuka, tetapi server belum mengirim data.',
            action: 'Muat ulang',
          )
        else if (data is List)
          _listContent(data)
        else if (data is Map)
          _mapContent(Map<String, dynamic>.from(data))
        else
          _valueCard('$data'),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: .17),
            AppColors.card.withValues(alpha: .94),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: .24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: .32)),
            ),
            child: Icon(icon, color: accent, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  '$roleLabel • MPorT Portal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .7),
                ),
                const SizedBox(height: 5),
                Text(
                  'Informasi dan operasional ${title.toLowerCase()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listContent(List data) {
    if (data.isEmpty) {
      return _statusCard(
        icon: Icons.inbox_outlined,
        title: 'Belum ada data',
        message: 'Tidak ada item untuk $title saat ini.',
        action: 'Muat ulang',
      );
    }

    return Column(
      children: [
        _sectionTitle('${data.length} item', Icons.view_list_rounded),
        const SizedBox(height: 8),
        ...data.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _itemCard(entry.value, entry.key + 1),
            )),
      ],
    );
  }

  Widget _mapContent(Map<String, dynamic> map) {
    final entries = map.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Ringkasan', Icons.insights_rounded),
        const SizedBox(height: 8),
        ...entries.map((e) => _dataTile(e.key, e.value)),
      ],
    );
  }

  Widget _sectionTitle(String text, IconData sectionIcon) {
    return Row(
      children: [
        Icon(sectionIcon, size: 18, color: accent),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _itemCard(dynamic item, int index) {
    if (item is! Map) {
      return _valueCard(item.toString(), index: index);
    }

    final m = Map<String, dynamic>.from(item);
    final itemTitle = (m['title'] ??
            m['name'] ??
            m['subject'] ??
            m['invoice_number'] ??
            m['ticket_number'] ??
            m['label'] ??
            m['asset_code'] ??
            m['code'] ??
            m['id'] ??
            '$title #$index')
        .toString();
    final subtitle = (m['body'] ??
            m['description'] ??
            m['message'] ??
            m['status'] ??
            m['email'] ??
            m['address'] ??
            '')
        .toString();

    return Material(
      color: AppColors.card.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetails(m),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemTitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dataTile(String key, dynamic value) {
    final label = key.replaceAll('_', ' ');
    if (value is Map || value is List) {
      final count = value is List ? value.length : (value as Map).length;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: AppColors.card.withValues(alpha: .92),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (value is Map) {
                _showDetails(Map<String, dynamic>.from(value));
              } else if (value is List) {
                _showListDetails(label, value);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_open_rounded, color: accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(label,
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                  Text('$count item',
                      style: const TextStyle(color: AppColors.muted)),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.muted2),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueCard(String value, {int? index}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.data_object_rounded, color: accent),
          const SizedBox(width: 12),
          Expanded(child: Text(index == null ? value : '#$index  $value')),
        ],
      ),
    );
  }

  Widget _errorCard(ApiResponse res) {
    final raw = res.message.trim();
    final message = res.statusCode == 403
        ? 'Akses ditolak. Role Anda tidak memiliki izin untuk modul ini.'
        : res.statusCode == 404
            ? 'Endpoint modul belum tersedia di server. UI tetap aktif dan dapat dimuat ulang setelah backend tersedia.'
            : res.statusCode == 0
                ? (raw.isEmpty ? 'Tidak dapat terhubung ke server. Periksa koneksi dan API_BASE_URL.' : raw)
                : (raw.isEmpty ? 'Gagal memuat modul (HTTP ${res.statusCode}).' : raw);

    return _statusCard(
      icon: res.statusCode == 403 ? Icons.lock_outline_rounded : Icons.cloud_off_rounded,
      title: 'Data belum tersedia',
      message: message,
      action: 'Coba lagi',
      status: res.statusCode,
    );
  }

  Widget _statusCard({
    required IconData icon,
    required String title,
    required String message,
    required String action,
    int? status,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 46, color: accent.withValues(alpha: .85)),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Text(message, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.45)),
          if (status != null) ...[
            const SizedBox(height: 6),
            Text('HTTP $status • ${widget.module}',
                style: const TextStyle(color: AppColors.muted2, fontSize: 11)),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(action),
          ),
        ],
      ),
    );
  }

  Future<void> _showDetails(Map<String, dynamic> data) async {
    final entries = data.entries.toList();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Row(
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.55,
              maxWidth: 420,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: entries.map((e) {
                  final label = e.key.replaceAll('_', ' ');
                  final v = e.value;
                  String display;
                  if (v == null) {
                    display = '—';
                  } else if (v is Map || v is List) {
                    final n = v is List ? v.length : (v as Map).length;
                    display = '$n item';
                  } else {
                    display = '$v';
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Text(
                            display,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            if (widget.role == 'admin' && data['id'] != null) ...[
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _adminEdit(data);
                },
                child: const Text('Edit'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _adminDelete(data);
                },
                child: const Text('Hapus'),
              ),
            ],
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _adminCreate() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tambah $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama / Judul')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi / Status'), maxLines: 2),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Simpan'),
              ),
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ],
          ),
        );
      },
    );
    if (ok != true || !mounted) return;
    final body = <String, dynamic>{
      'name': nameCtrl.text.trim(),
      'title': nameCtrl.text.trim(),
      if (descCtrl.text.trim().isNotEmpty) 'description': descCtrl.text.trim(),
      if (descCtrl.text.trim().isNotEmpty) 'status': descCtrl.text.trim(),
    };
    final res = await context.read<AuthService>().modules.create(widget.module, body);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(res.isOk ? 'Berhasil ditambahkan' : res.message)),
    );
    if (res.isOk) _load();
  }

  Future<void> _adminEdit(Map<String, dynamic> data) async {
    final id = data['id'];
    if (id == null) return;
    final nameCtrl = TextEditingController(
      text: (data['name'] ?? data['title'] ?? data['label'] ?? '').toString(),
    );
    final descCtrl = TextEditingController(
      text: (data['description'] ?? data['status'] ?? data['body'] ?? '').toString(),
    );
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama / Judul')),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi / Status'), maxLines: 2),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Simpan'),
              ),
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ],
          ),
        );
      },
    );
    if (ok != true || !mounted) return;
    final body = Map<String, dynamic>.from(data)
      ..['name'] = nameCtrl.text.trim()
      ..['title'] = nameCtrl.text.trim();
    if (descCtrl.text.trim().isNotEmpty) {
      body['description'] = descCtrl.text.trim();
      body['status'] = descCtrl.text.trim();
    }
    final res = await context.read<AuthService>().modules.update(widget.module, int.parse(id.toString()), body);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(res.isOk ? 'Berhasil diperbarui' : res.message)),
    );
    if (res.isOk) _load();
  }

  Future<void> _adminDelete(Map<String, dynamic> data) async {
    final id = data['id'];
    if (id == null) return;
    final label = (data['name'] ?? data['title'] ?? data['label'] ?? id).toString();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus data?'),
        content: Text('Yakin hapus $label?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final res = await context.read<AuthService>().modules.delete(widget.module, int.parse(id.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(res.isOk ? 'Dihapus' : res.message)),
    );
    if (res.isOk) _load();
  }

  Future<void> _showListDetails(String label, List data) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.55,
              maxWidth: 420,
            ),
            child: data.isEmpty
                ? const Text('Tidak ada item', style: TextStyle(color: AppColors.muted))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final item = data[i];
                      if (item is Map) {
                        final m = Map<String, dynamic>.from(item);
                        final t = (m['title'] ??
                                m['name'] ??
                                m['subject'] ??
                                m['label'] ??
                                m['id'] ??
                                'Item ${i + 1}')
                            .toString();
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(t, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                          onTap: () {
                            Navigator.of(dialogContext).pop();
                            _showDetails(m);
                          },
                        );
                      }
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('$item'),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
