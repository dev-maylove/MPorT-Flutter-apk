import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_theme.dart';

class ModulePlaceholderScreen extends StatefulWidget {
  final String role;
  final String module;
  const ModulePlaceholderScreen({
    super.key,
    required this.role,
    required this.module,
  });

  @override
  State<ModulePlaceholderScreen> createState() =>
      _ModulePlaceholderScreenState();
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

  String get title =>
      _titles[widget.module] ??
      widget.module
          .split('-')
          .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
          .join(' ');

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
    final auth = context.read<AuthService>();
    final res = await auth.modules.markAllNotificationsRead();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.message)),
    );
    if (res.isOk) _load();
  }

  /// Unwrap Laravel shapes:
  /// - { data: [ ... ] }
  /// - { data: { data: [ ... ], current_page, total } }  (paginator)
  /// - { data: { ...object } }
  dynamic get _payload {
    final root = _response?.json;
    if (root == null) return null;
    final data = root['data'];
    if (data is Map) {
      final inner = data['data'];
      if (inner is List) return inner; // paginator
      return data; // plain object
    }
    return data; // list or scalar
  }

  void _goBack() {
    final role = widget.role;
    if (context.canPop()) {
      context.pop();
      return;
    }
    if (role == 'admin') {
      context.go('/admin');
    } else if (role == 'technician') {
      context.go('/tech');
    } else {
      context.go('/app');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: _load, child: _body()),
    );
  }

  Widget _body() {
    final res = _response;
    if (res == null) return _error('Tidak ada respons dari server.');
    if (!res.isOk) {
      return _error(_friendlyError(res), status: res.statusCode);
    }

    final data = _payload;
    if (data == null) {
      return _empty('Modul "$title" tidak mengembalikan data.');
    }

    if (data is List) {
      if (data.isEmpty) return _empty('Belum ada data untuk $title.');
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _cardFor(data[i]),
      );
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      // Stats-style object (reports/dashboard/settings): show key-value rows
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: _expandMap(map),
      );
    }

    return _empty(data.toString());
  }

  List<Widget> _expandMap(Map<String, dynamic> map, {String? prefix}) {
    final widgets = <Widget>[];
    map.forEach((key, value) {
      final label = prefix == null ? key : '$prefix.$key';
      if (value is Map) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.cyan,
              ),
            ),
          ),
        );
        widgets.addAll(
          _expandMap(Map<String, dynamic>.from(value), prefix: null),
        );
      } else if (value is List) {
        widgets.add(
          Card(
            color: AppColors.surface.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${value.length} item'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppColors.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(
                        const JsonEncoder.withIndent('  ').convert(value),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        widgets.add(
          Card(
            color: AppColors.surface.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              subtitle: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
        );
      }
    });
    return widgets;
  }

  String _friendlyError(ApiResponse res) {
    final raw = res.message.trim();
    if (res.statusCode == 404 ||
        raw.toLowerCase().contains('could not be found') ||
        raw.toLowerCase().contains('not found')) {
      return 'Endpoint modul "${widget.module}" belum tersedia di server.\n'
          'Deploy backend FLUTTER-READY dan jalankan:\n'
          'php artisan route:clear';
    }
    if (res.statusCode == 403) {
      return 'Akses ditolak untuk "$title".\n'
          'Role Anda tidak memiliki izin modul ini.';
    }
    if (res.statusCode == 401) {
      return 'Sesi berakhir. Silakan login ulang.';
    }
    if (res.statusCode == 0) {
      return raw.isEmpty
          ? 'Tidak dapat terhubung ke server. Periksa Wi‑Fi / API_BASE_URL.'
          : raw;
    }
    if (raw.isEmpty) return 'Gagal memuat modul (HTTP ${res.statusCode}).';
    return raw;
  }

  Widget _cardFor(dynamic item) {
    if (item is Map) {
      return _itemCard(Map<String, dynamic>.from(item));
    }
    return Card(
      child: ListTile(title: Text('$item')),
    );
  }

  Widget _itemCard(Map<String, dynamic> m) {
    final title = (m['title'] ??
            m['name'] ??
            m['subject'] ??
            m['invoice_number'] ??
            m['ticket_number'] ??
            m['label'] ??
            m['asset_code'] ??
            m['code'] ??
            m['id'] ??
            widget.module)
        .toString();
    final subtitle = (m['body'] ??
            m['description'] ??
            m['message'] ??
            m['status'] ??
            m['email'] ??
            m['address'] ??
            '')
        .toString();

    return Card(
      color: AppColors.surface.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: subtitle.isEmpty
            ? null
            : Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis),
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(
                  const JsonEncoder.withIndent('  ').convert(m),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _error(String message, {int? status}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent.shade200),
        const SizedBox(height: 16),
        const Text(
          'Gagal memuat modul',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        if (status != null) ...[
          const SizedBox(height: 6),
          Text(
            'HTTP $status · ${widget.module}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }

  Widget _empty(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        Icon(Icons.inbox_outlined,
            size: 64, color: Colors.white.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
