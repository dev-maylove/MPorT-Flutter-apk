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
  const ModulePlaceholderScreen({super.key, required this.role, required this.module});
  @override State<ModulePlaceholderScreen> createState() => _ModulePlaceholderScreenState();
}

class _ModulePlaceholderScreenState extends State<ModulePlaceholderScreen> {
  ApiResponse? _response;
  bool _loading = true;
  bool _busy = false;

  String get title => widget.module.split('-').map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}').join(' ');

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final api = context.read<AuthService>().modules;
    final res = await api.list(widget.module);
    if (!mounted) return;
    setState(() { _response = res; _loading = false; });
  }

  Future<void> _markAllRead() async {
    if (_busy) return;
    setState(() => _busy = true);
    final res = await context.read<AuthService>().modules.markAllNotificationsRead();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.isOk ? res.message : res.message)));
    if (res.isOk) _load();
  }

  dynamic get _data => _response?.json?['data'];

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(title), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()), actions: [
        if (widget.module == 'notifications') IconButton(tooltip: 'Tandai semua dibaca', onPressed: _busy ? null : _markAllRead, icon: const Icon(Icons.done_all_rounded)),
        IconButton(tooltip: 'Muat ulang', onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh_rounded)),
      ]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: _load, child: _body()),
    );
  }

  Widget _body() {
    final res = _response;
    if (res == null) return _error('Tidak ada respons dari server.');
    if (!res.isOk) return _error(res.message, status: res.statusCode);
    if (_data == null) return _empty('Server mengembalikan data kosong.');
    if (_data is Map && (_data as Map).containsKey('data')) return _bodyFor(_data['data']);
    return _bodyFor(_data);
  }

  Widget _bodyFor(dynamic data) {
    if (data is List) {
      if (data.isEmpty) return _empty('Belum ada data untuk modul ini.');
      return ListView.separated(padding: const EdgeInsets.fromLTRB(14, 14, 14, 28), itemCount: data.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, i) => _item(data[i], i));
    }
    if (data is Map) {
      final entries = data.entries.toList();
      return ListView(padding: const EdgeInsets.fromLTRB(14, 14, 14, 28), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Data $title', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)))),
        const SizedBox(height: 10),
        ...entries.map((e) => _mapEntry(e.key.toString(), e.value)),
      ]);
    }
    return ListView(padding: const EdgeInsets.all(18), children: [Card(child: Padding(padding: const EdgeInsets.all(16), child: SelectableText('$data')))]);
  }

  Widget _item(dynamic value, int index) {
    if (value is Map) {
      final m = Map<String, dynamic>.from(value);
      final titleValue = m['name'] ?? m['title'] ?? m['subject'] ?? m['invoice_number'] ?? m['ticket_number'] ?? m['customer_code'] ?? 'Item ${index + 1}';
      final subtitle = m['status'] ?? m['email'] ?? m['phone'] ?? m['code'] ?? '';
      return Card(child: ExpansionTile(title: Text('$titleValue', maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: subtitle.toString().isEmpty ? null : Text('$subtitle'), childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14), children: m.entries.map((e) => _mapEntry(e.key, e.value)).toList()));
    }
    return Card(child: ListTile(title: Text('$value')));
  }

  Widget _mapEntry(String key, dynamic value) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 125, child: Text(key, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600))), Expanded(child: SelectableText(value is Map || value is List ? JsonEncoder.withIndent('  ').convert(value) : '${value ?? '-'}'))]));

  Widget _error(String message, {int status = 0}) => ListView(padding: const EdgeInsets.all(22), children: [const SizedBox(height: 40), Icon(status == 401 ? Icons.lock_outline_rounded : Icons.cloud_off_rounded, size: 58, color: AppColors.danger), const SizedBox(height: 16), Text(status == 403 ? 'Akses ditolak' : status == 401 ? 'Sesi berakhir' : 'Gagal memuat modul', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)), const SizedBox(height: 18), Center(child: OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Coba lagi')))]);
  Widget _empty(String message) => ListView(padding: const EdgeInsets.all(22), children: [const SizedBox(height: 80), const Icon(Icons.inbox_outlined, size: 54, color: AppColors.muted), const SizedBox(height: 14), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted))]);
}
