<?php

use App\Http\Controllers\Api\V1\AuthController as V1AuthController;
use App\Http\Controllers\Api\V1\CustomerController as V1CustomerController;
use App\Http\Controllers\Api\V1\DashboardController as V1DashboardController;
use App\Http\Controllers\Api\V1\InvoiceController as V1InvoiceController;
use App\Http\Controllers\Api\V1\OltController as V1OltController;
use App\Http\Controllers\Api\V1\PackageController as V1PackageController;
use App\Http\Controllers\Api\V1\PaymentController as V1PaymentController;
use App\Http\Controllers\Api\V1\TicketController as V1TicketController;
use App\Http\Controllers\Api\V1\MobileModuleController;
use App\Http\Controllers\Api\V2\AuthController as V2AuthController;
use App\Http\Controllers\Api\V2\CustomerController as V2CustomerController;
use App\Http\Controllers\Api\V2\DashboardController as V2DashboardController;
use App\Http\Controllers\Api\V2\InvoiceController as V2InvoiceController;
use App\Http\Controllers\Api\V2\OltController as V2OltController;
use App\Http\Controllers\Api\V2\PackageController as V2PackageController;
use App\Http\Controllers\Api\V2\PaymentController as V2PaymentController;
use App\Http\Controllers\Api\V2\TicketController as V2TicketController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API V1 — flat resources (kompatibel mobile)
| Prefix: /api/v1
|--------------------------------------------------------------------------
*/
Route::prefix('v1')->group(function () {
    Route::get('packages', [V1PackageController::class, 'index']);
    Route::get('packages/{package}', [V1PackageController::class, 'show']);

    Route::prefix('auth')->group(function () {
        Route::post('login', [V1AuthController::class, 'login'])->middleware('throttle:api-auth');
        Route::post('register', [V1AuthController::class, 'register'])->middleware('throttle:api-auth');
        Route::post('forgot-password', [V1AuthController::class, 'forgotPassword'])->middleware('throttle:api-auth');

        Route::middleware('auth:sanctum')->group(function () {
            Route::get('me', [V1AuthController::class, 'me']);
            Route::post('logout', [V1AuthController::class, 'logout']);
        });
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('dashboard', [V1DashboardController::class, 'index']);

        Route::get('tickets', [V1TicketController::class, 'index']);
        Route::post('tickets', [V1TicketController::class, 'store']);
        Route::get('tickets/{ticket}', [V1TicketController::class, 'show']);

        Route::get('customers', [V1CustomerController::class, 'index']);
        Route::get('customers/{customer}', [V1CustomerController::class, 'show']);

        Route::get('invoices', [V1InvoiceController::class, 'index']);
        Route::get('invoices/{invoice}', [V1InvoiceController::class, 'show']);

        Route::get('payments', [V1PaymentController::class, 'index']);

        Route::prefix('olt')->group(function () {
            Route::get('overview', [V1OltController::class, 'overview']);
            Route::get('signals', [V1OltController::class, 'signals']);
            Route::get('{code}', [V1OltController::class, 'show']);
        });

        // Hardened modules for Flutter mobile. Read API, role-scoped.
        Route::get('modules/{module}', [MobileModuleController::class, 'index']);
        Route::post('modules/notifications/read-all', [MobileModuleController::class, 'markAllNotificationsRead']);
        Route::post('modules/notifications/{id}/read', [MobileModuleController::class, 'markNotificationRead'])->whereNumber('id');
        Route::get('modules/{module}/{id}', [MobileModuleController::class, 'show'])->whereNumber('id');
    });
});

/*
|--------------------------------------------------------------------------
| API V2 — envelope { success, message, data, meta }
| Prefix: /api/v2
|--------------------------------------------------------------------------
*/
Route::prefix('v2')->group(function () {
    Route::get('packages', [V2PackageController::class, 'index']);
    Route::get('packages/{package}', [V2PackageController::class, 'show']);

    Route::prefix('auth')->group(function () {
        Route::post('login', [V2AuthController::class, 'login'])->middleware('throttle:api-auth');
        Route::post('register', [V2AuthController::class, 'register'])->middleware('throttle:api-auth');
        Route::post('forgot-password', [V2AuthController::class, 'forgotPassword'])->middleware('throttle:api-auth');

        Route::middleware('auth:sanctum')->group(function () {
            Route::get('me', [V2AuthController::class, 'me']);
            Route::post('logout', [V2AuthController::class, 'logout']);
        });
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('dashboard', [V2DashboardController::class, 'index']);

        Route::get('tickets', [V2TicketController::class, 'index']);
        Route::post('tickets', [V2TicketController::class, 'store']);
        Route::get('tickets/{ticket}', [V2TicketController::class, 'show']);

        Route::get('customers', [V2CustomerController::class, 'index']);
        Route::get('customers/me', [V2CustomerController::class, 'me']);
        Route::get('customers/{customer}', [V2CustomerController::class, 'show']);

        Route::get('invoices', [V2InvoiceController::class, 'index']);
        Route::get('invoices/{invoice}', [V2InvoiceController::class, 'show']);

        Route::get('payments', [V2PaymentController::class, 'index']);

        Route::prefix('olt')->group(function () {
            Route::get('overview', [V2OltController::class, 'overview']);
            Route::get('signals', [V2OltController::class, 'signals']);
            Route::get('{code}', [V2OltController::class, 'show']);
        });
    });
});

/*
|--------------------------------------------------------------------------
| Legacy (tanpa versi) → alias ke V1 agar app Android tetap jalan
| /api/auth/login, /api/auth/register, /api/dashboard, /api/tickets, ...
|--------------------------------------------------------------------------
*/
Route::prefix('auth')->group(function () {
    Route::post('login', [V1AuthController::class, 'login'])->middleware('throttle:api-auth');
    Route::post('register', [V1AuthController::class, 'register'])->middleware('throttle:api-auth');
    Route::post('forgot-password', [V1AuthController::class, 'forgotPassword'])->middleware('throttle:api-auth');

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('me', [V1AuthController::class, 'me']);
        Route::post('logout', [V1AuthController::class, 'logout']);
    });
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('dashboard', [V1DashboardController::class, 'index']);

    Route::get('tickets', [V1TicketController::class, 'index']);
    Route::post('tickets', [V1TicketController::class, 'store']);
    Route::get('tickets/{ticket}', [V1TicketController::class, 'show']);

    Route::get('customers', [V1CustomerController::class, 'index']);
    Route::get('customers/{customer}', [V1CustomerController::class, 'show']);

    Route::get('invoices', [V1InvoiceController::class, 'index']);
    Route::get('invoices/{invoice}', [V1InvoiceController::class, 'show']);
    Route::get('payments', [V1PaymentController::class, 'index']);

    Route::prefix('olt')->group(function () {
        Route::get('overview', [V1OltController::class, 'overview']);
        Route::get('signals', [V1OltController::class, 'signals']);
        Route::get('{code}', [V1OltController::class, 'show']);
    });

    // Write APIs for mobile (admin / staff)
    Route::put('invoices/{invoice}', [V1InvoiceController::class, 'update']);
    Route::delete('invoices/{invoice}', [V1InvoiceController::class, 'destroy']);
    Route::put('tickets/{ticket}', [V1TicketController::class, 'update']);
    Route::delete('tickets/{ticket}', [V1TicketController::class, 'destroy']);
    Route::post('customers', [V1CustomerController::class, 'store']);
    Route::put('customers/{customer}', [V1CustomerController::class, 'update']);
    Route::delete('customers/{customer}', [V1CustomerController::class, 'destroy']);
});

/*
|--------------------------------------------------------------------------
| Mobile extras — tech materials, map, admin users
|--------------------------------------------------------------------------
*/
use App\Http\Controllers\Api\V1\TechMaterialController;
use App\Http\Controllers\Api\V1\TechMapController;
use App\Http\Controllers\Api\V1\AdminUserController;
use App\Http\Controllers\PaymentProofController;

Route::middleware('auth:sanctum')->group(function () {
    // Tech materials
    Route::get('tech/materials', [TechMaterialController::class, 'index']);
    Route::post('tech/materials/request', [TechMaterialController::class, 'storeRequest']);
    Route::post('tech/materials/usage', [TechMaterialController::class, 'storeUsage']);

    // Tech map markers
    Route::get('tech/map', [TechMapController::class, 'index']);

    Route::get('payments/{payment}/proof', [PaymentProofController::class, 'download'])->name('api.payment.proof');
});

// User administration is protected twice: Sanctum authentication and the
// server-side role gate. Keep the controller check as defense in depth.
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('users', [AdminUserController::class, 'index']);
    Route::post('users', [AdminUserController::class, 'store']);
    Route::get('users/{user}', [AdminUserController::class, 'show']);
    Route::put('users/{user}', [AdminUserController::class, 'update']);
    Route::delete('users/{user}', [AdminUserController::class, 'destroy']);
});
