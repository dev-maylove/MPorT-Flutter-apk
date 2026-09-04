<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Models\AuditLog;
use App\Models\CoverageArea;
use App\Models\Customer;
use App\Models\DeliveryLog;
use App\Models\Invoice;
use App\Models\Material;
use App\Models\MaterialRequest;
use App\Models\MaterialUsage;
use App\Models\NetworkAsset;
use App\Models\Notification;
use App\Models\Package;
use App\Models\Page;
use App\Models\Payment;
use App\Models\Role;
use App\Models\SecurityEvent;
use App\Models\Subscription;
use App\Models\Ticket;
use App\Models\User;
use App\Models\WhatsAppActivity;
use App\Models\WhatsAppNumber;
use App\Models\WorkspaceCampaign;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;

class MobileModuleController extends Controller
{
    private const MAP = [
        'customers' => Customer::class,
        'packages' => Package::class,
        'invoices' => Invoice::class,
        'payments' => Payment::class,
        'tickets' => Ticket::class,
        'users' => User::class,
        'technicians' => User::class,
        'roles' => Role::class,
        'materials' => Material::class,
        'material-requests' => MaterialRequest::class,
        'material-usages' => MaterialUsage::class,
        'network-assets' => NetworkAsset::class,
        'coverage' => CoverageArea::class,
        'notifications' => Notification::class,
        'announcements' => Announcement::class,
        'whatsapp-numbers' => WhatsAppNumber::class,
        'whatsapp-activity' => WhatsAppActivity::class,
        'campaigns' => WorkspaceCampaign::class,
        'security-events' => SecurityEvent::class,
        'audit-logs' => AuditLog::class,
        'delivery-logs' => DeliveryLog::class,
        'subscriptions' => Subscription::class,
        'pages' => Page::class,
    ];

    private const ADMIN_ONLY = [
        'users','technicians','roles','security-events','audit-logs','delivery-logs',
        'whatsapp-numbers','whatsapp-activity','whatsapp','campaigns','settings','ops',
        'network','coverage','network-assets','communications',
    ];
    // reports is available to admin + technician (scoped in reports()).

    private const TECH_ONLY = ['tech-jobs','tech-map','material-requests','material-usages'];

    public function index(Request $request, string $module)
    {
        $user = $request->user();
        $this->authorizeModule($user, $module);

        return match ($module) {
            'dashboard' => $this->dashboard($request),
            'reports' => $this->reports($request),
            'settings' => $this->settings(),
            'tech-map' => $this->techMap($request),
            'tech-jobs' => $this->techJobs($request),
            'communications' => $this->communications($request),
            'ops-comms' => $this->communications($request),
            'support' => $this->support($request),
            'whatsapp' => $this->whatsapp(),
            'olt' => $this->olt(),
            'network' => $this->network(),
            'security' => $this->security(),
            'ops' => $this->ops(),
            'service' => $this->service($request),
            'documents' => $this->documents(),
            'help' => $this->help(),
            default => $this->indexModel($request, $module),
        };
    }

    public function show(Request $request, string $module, int $id)
    {
        $this->authorizeModule($request->user(), $module);
        abort_unless(isset(self::MAP[$module]), 404, 'Modul API tidak ditemukan');
        $item = $this->queryFor($request, $module, self::MAP[$module])->findOrFail($id);
        return response()->json(['success' => true, 'message' => 'OK', 'data' => $item]);
    }

    public function markNotificationRead(Request $request, int $id)
    {
        $notification = Notification::where('user_id', $request->user()->id)->findOrFail($id);
        $notification->update(['read_at' => now()]);
        return response()->json(['success' => true, 'message' => 'Notifikasi ditandai sudah dibaca', 'data' => $notification->fresh()]);
    }

    public function markAllNotificationsRead(Request $request)
    {
        $count = Notification::where('user_id', $request->user()->id)->whereNull('read_at')->update(['read_at' => now()]);
        return response()->json(['success' => true, 'message' => 'Semua notifikasi sudah dibaca', 'data' => ['updated' => $count]]);
    }

    private function indexModel(Request $request, string $module)
    {
        abort_unless(isset(self::MAP[$module]), 404, 'Modul API tidak ditemukan');
        $query = $this->queryFor($request, $module, self::MAP[$module]);
        $perPage = min(max((int) $request->input('per_page', 20), 1), 100);
        return response()->json(['success' => true, 'message' => 'OK', 'data' => $query->paginate($perPage)]);
    }

    private function queryFor(Request $request, string $module, string $model): Builder
    {
        $q = $model::query()->latest();
        $user = $request->user();

        if ($module === 'technicians') $q->where('role', 'technician');
        if ($module === 'notifications') $q->where('user_id', $user->id);
        if ($module === 'campaigns' && ! $user->isAdmin()) $q->where('user_id', $user->id);
        if ($module === 'subscriptions' && ! $user->isAdmin()) {
            $customerId = $user->customer?->id;
            $q->where(function ($w) use ($user, $customerId) {
                $w->where('user_id', $user->id);
                if ($customerId) $w->orWhere('customer_id', $customerId);
            });
        }
        if (in_array($module, ['invoices','payments','tickets'], true) && ! $user->isAdmin()) {
            $customerId = $user->customer?->id;
            $q->where(function ($w) use ($user, $customerId) {
                $w->where('user_id', $user->id);
                if ($customerId) $w->orWhere('customer_id', $customerId);
            });
        }
        if ($module === 'customers' && ! $user->isAdmin()) $q->where('user_id', $user->id);
        if ($module === 'material-requests' && ! $user->isAdmin()) $q->where('user_id', $user->id);
        if ($module === 'material-usages' && ! $user->isAdmin()) $q->where('user_id', $user->id);

        if ($request->filled('status') && in_array($module, ['customers','invoices','payments','tickets','coverage','notifications','campaigns','subscriptions','network-assets','material-requests','announcements'], true)) {
            $q->where('status', $request->input('status'));
        }
        if ($request->filled('type') && $module === 'network-assets') $q->where('type', $request->input('type'));

        $search = trim((string) ($request->input('search') ?? $request->input('q', '')));
        if ($search !== '') {
            $columns = [
                'customers' => ['name','customer_code','email','whatsapp'],
                'packages' => ['name','slug','description'],
                'users' => ['name','email','tech_code','work_area'],
                'technicians' => ['name','email','tech_code','work_area'],
                'roles' => ['name','slug'],
                'materials' => ['name','sku'],
                'material-requests' => ['material_name','notes','status'],
                'material-usages' => ['notes'],
                'network-assets' => ['asset_code','code','name','serial_number','mac_address'],
                'coverage' => ['code','name'],
                'tickets' => ['ticket_number','subject','description'],
                'invoices' => ['invoice_number','package_name'],
                'payments' => ['payment_code','reference','note'],
                'notifications' => ['title','body'],
                'announcements' => ['title','slug','body'],
                'whatsapp-numbers' => ['label','phone','department'],
                'whatsapp-activity' => ['event','detail','status'],
                'campaigns' => ['name','description','message'],
                'security-events' => ['type','severity','email','ip'],
                'audit-logs' => ['action','entity','ip'],
                'delivery-logs' => ['message_key','message_title','recipient_name','channel','status'],
                'subscriptions' => ['status','notes'],
                'pages' => ['title','slug'],
            ][$module] ?? null;
            if ($columns) {
                $like = '%'.$search.'%';
                $q->where(function ($w) use ($columns, $like) {
                    foreach ($columns as $i => $column) {
                        $i === 0 ? $w->where($column, 'like', $like) : $w->orWhere($column, 'like', $like);
                    }
                });
            }
        }
        return $q;
    }

    private function authorizeModule(User $user, string $module): void
    {
        // Unknown modules still go through indexModel / MAP; deny only explicit role gates.
        if (in_array($module, self::ADMIN_ONLY, true)) {
            abort_unless(method_exists($user, 'isAdmin') ? $user->isAdmin() : ($user->role === 'admin'), 403, 'Modul khusus admin');
        }
        if (in_array($module, self::TECH_ONLY, true)) {
            abort_unless(
                (method_exists($user, 'isAdmin') && $user->isAdmin()) || $user->role === 'technician' || $user->role === 'admin',
                403,
                'Modul khusus teknisi'
            );
        }
        // reports: admin sees full stats, technician sees own job-oriented stats
        if ($module === 'reports') {
            abort_unless(
                (method_exists($user, 'isAdmin') && $user->isAdmin()) || in_array($user->role, ['admin', 'technician'], true),
                403,
                'Akses laporan ditolak'
            );
        }
        // notifications / announcements / help / documents / service / packages: any authenticated role
    }

    private function dashboard(Request $request)
    {
        $user = $request->user();
        $invoiceQ = Invoice::query();
        $ticketQ = Ticket::query();
        if (! $user->isAdmin()) {
            $customerId = $user->customer?->id;
            $invoiceQ->where(function ($w) use ($user, $customerId) { $w->where('user_id',$user->id); if ($customerId) $w->orWhere('customer_id',$customerId); });
            $ticketQ->where(function ($w) use ($user, $customerId) { $w->where('user_id',$user->id); if ($customerId) $w->orWhere('customer_id',$customerId); });
        }
        return response()->json(['success'=>true,'message'=>'OK','data'=>[
            'customers'=>$user->isAdmin() ? Customer::count() : (int) Customer::where('user_id',$user->id)->count(),
            'packages'=>Package::where('is_active',true)->count(),
            'tickets_open'=>$ticketQ->whereIn('status',['open','in_progress'])->count(),
            'invoices_unpaid'=>(clone $invoiceQ)->whereIn('status',['unpaid','overdue','partially_paid'])->count(),
            'unpaid_amount'=>(float)(clone $invoiceQ)->whereIn('status',['unpaid','overdue','partially_paid'])->sum('amount'),
            'notifications_unread'=>Notification::where('user_id',$user->id)->whereNull('read_at')->count(),
        ]]);
    }

    private function reports(Request $request)
    {
        $user = $request->user();
        $isAdmin = method_exists($user, 'isAdmin') ? $user->isAdmin() : ($user->role === 'admin');

        if (! $isAdmin) {
            // Technician-scoped summary
            $ticketQ = Ticket::query()->where(function ($w) use ($user) {
                $w->where('assigned_to', $user->id)->orWhere('technician_id', $user->id)->orWhere('user_id', $user->id);
            });
            return response()->json(['success'=>true,'message'=>'OK','data'=>[
                'role' => 'technician',
                'tickets' => [
                    'total' => (clone $ticketQ)->count(),
                    'open' => (clone $ticketQ)->whereIn('status',['open','in_progress'])->count(),
                    'resolved' => (clone $ticketQ)->where('status','resolved')->count(),
                ],
                'notifications_unread' => Notification::where('user_id',$user->id)->whereNull('read_at')->count(),
            ]]);
        }

        return response()->json(['success'=>true,'message'=>'OK','data'=>[
            'role' => 'admin',
            'customers'=>['total'=>Customer::count(),'active'=>Customer::where('status','active')->count()],
            'users'=>['total'=>User::count(),'technicians'=>User::where('role','technician')->count()],
            'invoices'=>['total'=>Invoice::count(),'unpaid'=>(float)Invoice::whereIn('status',['unpaid','overdue','partially_paid'])->sum('amount'),'paid'=>(float)Invoice::where('status','paid')->sum('amount')],
            'payments'=>['count'=>Payment::count(),'amount'=>(float)Payment::sum('amount')],
            'tickets'=>['total'=>Ticket::count(),'open'=>Ticket::whereIn('status',['open','in_progress'])->count(),'resolved'=>Ticket::where('status','resolved')->count()],
        ]]);
    }

    private function settings()
    {
        return response()->json(['success'=>true,'message'=>'OK','data'=>['app_name'=>config('app.name'),'app_url'=>config('app.url'),'locale'=>config('app.locale')]]);
    }

    private function network()
    {
        return response()->json(['success'=>true,'message'=>'OK','data'=>[
            'assets'=>NetworkAsset::count(),
            'online'=>NetworkAsset::whereIn('status',['online','active','up'])->count(),
            'offline'=>NetworkAsset::whereIn('status',['offline','down','inactive'])->count(),
            'odp'=>NetworkAsset::where('type','odp')->count(), 'olt'=>NetworkAsset::where('type','olt')->count(), 'ont'=>NetworkAsset::where('type','ont')->count(),
        ]]);
    }

    private function security()
    {
        return response()->json(['success'=>true,'message'=>'OK','data'=>['events'=>SecurityEvent::latest()->limit(50)->get(),'audit'=>AuditLog::latest()->limit(50)->get()]]);
    }

    private function communications(Request $request)
    {
        return response()->json(['success'=>true,'message'=>'OK','data'=>[
            'announcements'=>Announcement::latest()->limit(20)->get(),
            'notifications'=>Notification::where('user_id',$request->user()->id)->latest()->limit(20)->get(),
            'whatsapp_numbers'=>WhatsAppNumber::where('is_active',true)->get(),
            'delivery_logs'=>DeliveryLog::latest()->limit(20)->get(),
        ]]);
    }

    private function ops()
    {
        return response()->json(['success'=>true,'message'=>'OK','data'=>[
            'network'=>['assets'=>NetworkAsset::count(),'online'=>NetworkAsset::whereIn('status',['online','active','up'])->count(),'offline'=>NetworkAsset::whereIn('status',['offline','down','inactive'])->count()],
            'technicians'=>User::where('role','technician')->get(['id','name','email','duty_status','tech_code','work_area']),
            'coverage'=>CoverageArea::latest()->limit(100)->get(), 'campaigns'=>WorkspaceCampaign::latest()->limit(50)->get(),
        ]]);
    }

    private function techJobs(Request $request)
    {
        $user=$request->user(); $q=Ticket::query()->latest();
        if (!$user->isAdmin()) $q->where('technician_id',$user->id);
        return response()->json(['success'=>true,'message'=>'OK','data'=>$q->paginate(min(max((int)$request->input('per_page',20),1),100))]);
    }

    private function techMap(Request $request)
    {
        $user=$request->user(); $q=Customer::query()->select(['id','customer_code','name','lat','lng','address','odp_code','status']);
        if (!$user->isAdmin()) $q->where('technician_id',$user->id);
        return response()->json(['success'=>true,'message'=>'OK','data'=>$q->whereNotNull('lat')->whereNotNull('lng')->get()]);
    }

    private function support(Request $request)
    {
        $user = $request->user();
        $q = Ticket::query()->latest();
        if (! $user->isAdmin()) {
            $cid = $user->customer?->id;
            $q->where(function ($w) use ($user, $cid) { $w->where('user_id', $user->id); if ($cid) $w->orWhere('customer_id', $cid); });
        }
        return response()->json(['success'=>true,'message'=>'OK','data'=>$q->limit(50)->get()]);
    }

    private function whatsapp()
    {
        return response()->json(['success'=>true,'message'=>'OK','data'=>[
            'numbers'=>WhatsAppNumber::latest()->limit(100)->get(),
            'activity'=>WhatsAppActivity::latest()->limit(100)->get(),
        ]]);
    }

    private function olt()
    {
        return response()->json(['success'=>true,'message'=>'OK','data'=>[
            'total'=>NetworkAsset::where('type','olt')->count(),
            'online'=>NetworkAsset::where('type','olt')->whereIn('status',['online','active','up'])->count(),
            'offline'=>NetworkAsset::where('type','olt')->whereIn('status',['offline','down','inactive'])->count(),
            'assets'=>NetworkAsset::where('type','olt')->latest()->limit(100)->get(),
        ]]);
    }

    private function service(Request $request)
    {
        $user=$request->user(); $q=Subscription::query()->latest();
        if (!$user->isAdmin()) { $cid=$user->customer?->id; $q->where(function($w) use($user,$cid){$w->where('user_id',$user->id); if($cid)$w->orWhere('customer_id',$cid);}); }
        return response()->json(['success'=>true,'message'=>'OK','data'=>$q->paginate(20)]);
    }

    private function documents() { return response()->json(['success'=>true,'message'=>'OK','data'=>[],'meta'=>['note'=>'Dokumen portal belum memiliki model khusus.']]); }
    private function help() { return response()->json(['success'=>true,'message'=>'OK','data'=>Announcement::latest()->limit(20)->get()]); }
}
