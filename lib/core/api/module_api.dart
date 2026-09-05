import 'api_client.dart';

/// Typed facade for the mobile modules exposed by MPorT Hardened.
/// Methods return ApiResponse so the UI can handle offline/401/403/5xx states
/// without throwing uncaught exceptions.
class ModuleApi {
  ModuleApi(this.client);
  final ApiClient client;

  Future<ApiResponse> list(String module, {Map<String, String>? query}) {
    final encoded = Uri.encodeComponent(module);
    return client.get('/api/v1/modules/$encoded', query: query, auth: true);
  }

  Future<ApiResponse> get(String module, int id) =>
      client.get('/api/v1/modules/${Uri.encodeComponent(module)}/$id', auth: true);

  Future<ApiResponse> create(String module, Map<String, dynamic> body) =>
      client.post('/api/v1/modules/${Uri.encodeComponent(module)}', body: body, auth: true);

  Future<ApiResponse> update(String module, int id, Map<String, dynamic> body) =>
      client.put('/api/v1/modules/${Uri.encodeComponent(module)}/$id', body: body, auth: true);

  Future<ApiResponse> delete(String module, int id) =>
      client.delete('/api/v1/modules/${Uri.encodeComponent(module)}/$id', auth: true);

  Future<ApiResponse> dashboard() => list('dashboard');
  Future<ApiResponse> reports() => list('reports');
  Future<ApiResponse> settings() => list('settings');
  Future<ApiResponse> communications() => list('communications');
  Future<ApiResponse> security() => list('security');
  Future<ApiResponse> ops() => list('ops');
  Future<ApiResponse> network() => list('network');
  Future<ApiResponse> techJobs({Map<String, String>? query}) => list('tech-jobs', query: query);
  Future<ApiResponse> techMap() => list('tech-map');
  Future<ApiResponse> oltOverview() => client.get('/api/v1/olt/overview', auth: true);
  Future<ApiResponse> oltSignals() => client.get('/api/v1/olt/signals', auth: true);
  Future<ApiResponse> olt(String code) => client.get('/api/v1/olt/${Uri.encodeComponent(code)}', auth: true);

  Future<ApiResponse> createCustomer(Map<String, dynamic> body) => client.post('/api/customers', body: body, auth: true);
  Future<ApiResponse> updateCustomer(int id, Map<String, dynamic> body) => client.put('/api/customers/$id', body: body, auth: true);
  Future<ApiResponse> deleteCustomer(int id) => client.delete('/api/customers/$id', auth: true);
  Future<ApiResponse> updateInvoice(int id, Map<String, dynamic> body) => client.put('/api/invoices/$id', body: body, auth: true);
  Future<ApiResponse> deleteInvoice(int id) => client.delete('/api/invoices/$id', auth: true);
  Future<ApiResponse> createTicket(Map<String, dynamic> body) => client.post('/api/tickets', body: body, auth: true);
  Future<ApiResponse> updateTicket(int id, Map<String, dynamic> body) => client.put('/api/tickets/$id', body: body, auth: true);
  Future<ApiResponse> deleteTicket(int id) => client.delete('/api/tickets/$id', auth: true);
  Future<ApiResponse> createAdminUser(Map<String, dynamic> body) => client.post('/api/admin/users', body: body, auth: true);
  Future<ApiResponse> updateAdminUser(int id, Map<String, dynamic> body) => client.put('/api/admin/users/$id', body: body, auth: true);
  Future<ApiResponse> deleteAdminUser(int id) => client.delete('/api/admin/users/$id', auth: true);
  Future<ApiResponse> requestMaterial(Map<String, dynamic> body) => client.post('/api/tech/materials/request', body: body, auth: true);
  Future<ApiResponse> recordMaterialUsage(Map<String, dynamic> body) => client.post('/api/tech/materials/usage', body: body, auth: true);
  Future<ApiResponse> markNotificationRead(int id) => client.post('/api/v1/modules/notifications/$id/read', auth: true);
  Future<ApiResponse> markAllNotificationsRead() => client.post('/api/v1/modules/notifications/read-all', auth: true);

  Future<ApiResponse> customers({String? search, String? status}) => list('customers', query: _q(search: search, status: status));
  Future<ApiResponse> packages({String? search, String? status}) => list('packages', query: _q(search: search, status: status));
  Future<ApiResponse> invoices({String? search, String? status}) => list('invoices', query: _q(search: search, status: status));
  Future<ApiResponse> payments({String? search, String? status}) => list('payments', query: _q(search: search, status: status));
  Future<ApiResponse> tickets({String? search, String? status}) => list('tickets', query: _q(search: search, status: status));
  Future<ApiResponse> users({String? search}) => list('users', query: _q(search: search));
  Future<ApiResponse> roles({String? search}) => list('roles', query: _q(search: search));
  Future<ApiResponse> materials({String? search}) => list('materials', query: _q(search: search));
  Future<ApiResponse> materialRequests({String? status}) => list('material-requests', query: _q(status: status));
  Future<ApiResponse> materialUsages() => list('material-usages');
  Future<ApiResponse> networkAssets({String? search, String? type, String? status}) => list('network-assets', query: _q(search: search, type: type, status: status));
  Future<ApiResponse> coverage({String? search, String? status}) => list('coverage', query: _q(search: search, status: status));
  Future<ApiResponse> notifications({String? status}) => list('notifications', query: _q(status: status));
  Future<ApiResponse> announcements() => list('announcements');
  Future<ApiResponse> whatsappNumbers({String? search, String? status}) => list('whatsapp-numbers', query: _q(search: search, status: status));
  Future<ApiResponse> whatsappActivity() => list('whatsapp-activity');
  Future<ApiResponse> campaigns({String? search, String? status}) => list('campaigns', query: _q(search: search, status: status));
  Future<ApiResponse> securityEvents({String? severity}) {
    final q = <String, String>{};
    if (severity != null && severity.trim().isNotEmpty) {
      q['severity'] = severity.trim();
    }
    return list('security-events', query: q);
  }
  Future<ApiResponse> auditLogs() => list('audit-logs');
  Future<ApiResponse> deliveryLogs({String? status}) => list('delivery-logs', query: _q(status: status));
  Future<ApiResponse> subscriptions({String? status}) => list('subscriptions', query: _q(status: status));

  Map<String, String> _q({String? search, String? status, String? type}) {
    final q = <String, String>{};
    if (search != null && search.trim().isNotEmpty) q['search'] = search.trim();
    if (status != null && status.trim().isNotEmpty) q['status'] = status.trim();
    if (type != null && type.trim().isNotEmpty) q['type'] = type.trim();
    return q;
  }
}
