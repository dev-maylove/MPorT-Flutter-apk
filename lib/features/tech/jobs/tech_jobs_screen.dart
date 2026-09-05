import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

/// Jobs teknisi — memakai endpoint tickets (assigned) sebagai sumber awal.
class TechJobsScreen extends StatefulWidget {
  const TechJobsScreen({super.key});

  @override
  State<TechJobsScreen> createState() => _TechJobsScreenState();
}

class _TechJobsScreenState extends State<TechJobsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthService>();
    try {
      // Prefer hardened module endpoint, fallback ke /api/tickets
      var res = await auth.modules.techJobs();
      if (!res.isOk) {
        res = await auth.client.get(ApiConfig.tickets, auth: true);
      }
      if (!mounted) return;
      if (res.statusCode == 401) {
        await auth.logout();
        return;
      }
      if (!res.isOk) {
        setState(() {
          _error = res.message;
          _loading = false;
        });
        return;
      }
      final list = _extractList(res.json);
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic>? json) {
    if (json == null) return [];
    dynamic raw = json['data'] ?? json['tickets'] ?? json['items'];
    // Laravel paginator: data.data
    if (raw is Map && raw['data'] is List) {
      raw = raw['data'];
    }
    final list = <Map<String, dynamic>>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) list.add(Map<String, dynamic>.from(e));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(centerTitle: true, title: const Text('Jobs / Work Order')),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.tech,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.tech))
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: const TextStyle(color: AppColors.danger)))])
                : _items.isEmpty
                    ? ListView(children: const [Padding(padding: EdgeInsets.all(24), child: Text('Tidak ada job aktif.', style: TextStyle(color: AppColors.muted)))])
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final t = _items[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (t['subject'] ?? t['title'] ?? 'Job #${t['id']}').toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Status: ${(t['status'] ?? '-').toString()}',
                                    style: const TextStyle(color: AppColors.tech, fontSize: 13),
                                  ),
                                  if (t['customer_name'] != null)
                                    Text('Pelanggan: ${t['customer_name']}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
