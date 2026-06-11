# Role-Based System Design

## Overview

Separate dashboard for **Admin** (sell products) and **User** (buy products) across Flutter app and web.

## Platform Roles

| Platform | Role | Access |
|----------|------|--------|
| Flutter App | Admin | CRUD products, manage orders, stats, chat |
| Flutter App | User | Browse, cart, checkout, wishlist, review, chat |
| Web | User only | Browse, cart, checkout, order history, chat |

## Authentication

- **Admin**: 1 fixed account (no registration)
  - Email: `admin@featuresfound.com`
  - Password: `admin123`
- **User**: Register + Login
- Token-based auth using **Laravel Sanctum**
- Flutter stores token + role in local storage

## Database Schema

### users (modified)
- `id`, `name`, `email`, `password`, `role` (enum: user/admin), `timestamps`

### orders (new)
- `id`, `user_id` (FK), `total_price`, `status` (pending/shipped/completed), `address`, `phone`, `timestamps`

### order_items (new)
- `id`, `order_id` (FK), `product_id` (FK), `quantity`, `price`, `timestamps`

### reviews (new)
- `id`, `user_id` (FK), `product_id` (FK), `rating` (1-5), `comment`, `timestamps`

### wishlists (new)
- `id`, `user_id` (FK), `product_id` (FK), `timestamps`

### chats (new)
- `id`, `user_id` (FK), `admin_id` (FK), `timestamps`

### messages (new)
- `id`, `chat_id` (FK), `sender_id` (FK), `message`, `read` (boolean), `timestamps`

## API Endpoints

### Public
- `POST /api/register` — user registration
- `POST /api/login` — login (returns token + role)
- `GET /api/products` — list products

### User (auth:sanctum + role:user)
- `POST /api/logout` — logout
- `GET /api/user/profile` — get profile
- `POST /api/orders` — checkout
- `GET /api/orders` — order history
- `GET /api/orders/{id}` — order detail
- `POST /api/wishlist` — add to wishlist
- `GET /api/wishlist` — list wishlist
- `DELETE /api/wishlist/{id}` — remove from wishlist
- `POST /api/reviews` — add review
- `GET /api/products/{id}/reviews` — product reviews
- `GET /api/chats` — list user chats
- `POST /api/chats` — start new chat
- `GET /api/chats/{id}/messages` — chat messages
- `POST /api/chats/{id}/messages` — send message

### Admin (auth:sanctum + role:admin)
- `GET /api/admin/stats` — dashboard stats
- `POST /api/admin/products` — create product
- `PUT /api/admin/products/{id}` — update product
- `DELETE /api/admin/products/{id}` — delete product
- `GET /api/admin/orders` — list all orders
- `PUT /api/admin/orders/{id}/status` — update order status
- `GET /api/admin/chats` — list all chats
- `POST /api/admin/chats/{id}/messages` — reply to chat

## Implementation Phases

### Phase 1: Auth System
- Add `role` field to users table
- AuthController (register, login, logout)
- Admin seeder
- Flutter: login, register screens, auth provider
- Web: connect login page to API

### Phase 2: Admin Dashboard (Flutter)
- Admin home (stats)
- Admin products CRUD
- Admin orders management
- Admin chat

### Phase 3: User Shopping (Flutter + Web)
- Checkout flow
- Order history
- Order detail

### Phase 4: Wishlist & Review
- Wishlist CRUD
- Review CRUD

### Phase 5: Chat Real-Time
- Laravel Broadcasting + Pusher
- Chat screens (Flutter + Web)

## Tech Stack

- **Backend**: Laravel 9.5.2, PHP 8.0.30, MySQL, Sanctum
- **Flutter**: Riverpod, Freezed, http package
- **Web**: HTML/CSS/JS, Tailwind CDN
- **Real-time**: Laravel Broadcasting + Pusher (free tier)
