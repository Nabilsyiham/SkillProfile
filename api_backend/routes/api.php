<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\AdminProductController;
use App\Http\Controllers\AdminOrderController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\WishlistController;
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\VariantController;
use App\Http\Controllers\CartController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::apiResource('products', ProductController::class);
Route::get('/products-flash-sale', [ProductController::class, 'flashSale']);

// Public reviews route
Route::get('/products/{productId}/reviews', [ReviewController::class, 'index']);

// Public variants route
Route::get('/products/{productId}/variants', [VariantController::class, 'index']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user/profile', [AuthController::class, 'profile']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders', [OrderController::class, 'index']);
    Route::get('/orders/{id}', [OrderController::class, 'show']);

    Route::get('/wishlist', [WishlistController::class, 'index']);
    Route::post('/wishlist', [WishlistController::class, 'store']);
    Route::delete('/wishlist/{id}', [WishlistController::class, 'destroy']);

    // Reviews routes
    Route::post('/products/{productId}/reviews', [ReviewController::class, 'store']);
    Route::delete('/reviews/{id}', [ReviewController::class, 'destroy']);

    // Chat routes
    Route::get('/chat', [ChatController::class, 'userChat']);
    Route::get('/chat/{chatId}/messages', [ChatController::class, 'messages']);
    Route::post('/chat/{chatId}/messages', [ChatController::class, 'sendMessage']);
    Route::post('/chat/{chatId}/read', [ChatController::class, 'markAsRead']);

    // Cart routes
    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart', [CartController::class, 'store']);
    Route::put('/cart/{id}', [CartController::class, 'update']);
    Route::delete('/cart/{id}', [CartController::class, 'destroy']);
    Route::delete('/cart', [CartController::class, 'clear']);
});

// Admin routes
Route::prefix('admin')->middleware(['auth:sanctum'])->group(function () {
    Route::get('/stats', [AdminController::class, 'stats']);
    Route::apiResource('products', AdminProductController::class)->except(['show', 'create', 'edit']);
    Route::put('/products/{productId}/variants', [VariantController::class, 'sync']);
    Route::get('/orders', [AdminOrderController::class, 'index']);
    Route::put('/orders/{id}/status', [AdminOrderController::class, 'updateStatus']);

    // Chat routes
    Route::get('/chats', [ChatController::class, 'adminChats']);
    Route::get('/chats/{chatId}/messages', [ChatController::class, 'adminMessages']);
    Route::post('/chats/{chatId}/messages', [ChatController::class, 'adminSendMessage']);
    Route::post('/chats/{chatId}/read', [ChatController::class, 'markAsRead']);
});