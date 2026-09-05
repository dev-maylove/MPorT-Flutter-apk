import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthService>();
    try {
      final q = _search.text.trim();
      final path = q.isEmpty
          ? ApiConfig.customers
          : '${ApiConfig.customers}?search=${Uri.encodeComponent(q)}';
      final res = await auth.client.get(path, auth: true);
      if (!mounted) return;
      if (!res.isOk) {
        setState(() {
          _error = res.message;
          _loading = false;
        });
        return;
      }
      final raw = res.json?['data'] ?? res.json?['customers'] ?? [];
      final list = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) list.add(Map<String, dynamic>.from(e));
        }
      }
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

  Future<void> _createOrEdit({Map<String, dynamic>? existing}) async {
    final name = TextEditingController(text: existing?['name']?.toString() ?? existing?['customer_name']?.toString() ?? '');
    final email = TextEditingController(text: existing?['email']?.toString() ?? '');
    final phone = TextEditingController(text: existing?['phone']?.toString() ?? '');
    final address = TextEditingController(text: existing?['address']?.toString() ?? '');
    String status = (existing?['status'] ?? 'active').toString();
    final isEdit = existing != null;
    final id = existing?['id'];

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEdit ? 'Edit Pelanggan' : 'Pelanggan Baru',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama')),
                    const SizedBox(height: 8),
                    TextField(controller: email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 8),
                    TextField(controller: phone, decoration: const InputDecoration(labelText: 'Telepon'), keyboardType: TextInputType.phone),
                    const SizedBox(height: 8),
                    TextField(controller: address, decoration: const InputDecoration(labelText: 'Alamat'), maxLines: 2),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('active')),
                        DropdownMenuItem(value: 'inactive', child: Text('inactive')),
                        DropdownMenuItem(value: 'suspended', child: Text('suspended')),
                      ],
                      onChanged: (v) {
                        if (v != null) setLocal(() => status = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(isEdit ? 'Simpan' : 'Tambah'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (ok != true || !mounted) return;

    final body = <String, dynamic>{
      'name': name.text.trim(),
      'email': email.text.trim(),
      'phone': phone.text.trim(),
      'address': address.text.trim(),
      'status': status,
    };

    final auth = context.read<AuthService>();
    final res = isEdit && id != null
        ? await auth.modules.updateCustomer(int.parse(id.toString()), body)
        : await auth.modules.createCustomer(body);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(res.isOk ? (isEdit ? 'Pelanggan diperbarui' : 'Pelanggan ditambahkan') : res.message),
      ),
    );
    if (res.isOk) _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final id = item['id'];
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus pelanggan?'),
        content: Text('Yakin hapus ${(item['name'] ?? item['customer_name'] ?? id).toString()}?'),
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
    final res = await context.read<AuthService>().modules.deleteCustomer(int.parse(id.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(res.isOk ? 'Dihapus' : res.message)),
    );
    if (res.isOk) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pelanggan'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createOrEdit(),
        icon: const Icon(Icons.person_add),
        label: const Text('Pelanggan'),
        backgroundColor: AppColors.admin,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Cari nama / email / HP',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _load,
                ),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: AppColors.admin,
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.admin))
                  : _error != null
                      ? ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                            ),
                          ],
                        )
                      : _items.isEmpty
                          ? ListView(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text('Tidak ada data pelanggan.', style: TextStyle(color: AppColors.muted)),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                              itemCount: _items.length,
                              itemBuilder: (_, i) {
                                final c = _items[i];
                                final name = (c['name'] ?? c['customer_name'] ?? 'Customer #${c['id']}').toString();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: AppCard(
                                    onTap: () => _createOrEdit(existing: c),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                              if (c['email'] != null)
                                                Text(c['email'].toString(), style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                                              if (c['phone'] != null)
                                                Text(c['phone'].toString(), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                              if (c['status'] != null)
                                                Text('Status: ${c['status']}', style: const TextStyle(color: AppColors.admin, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Edit',
                                          icon: const Icon(Icons.edit_outlined, size: 20),
                                          onPressed: () => _createOrEdit(existing: c),
                                        ),
                                        IconButton(
                                          tooltip: 'Hapus',
                                          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                                          onPressed: () => _delete(c),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
