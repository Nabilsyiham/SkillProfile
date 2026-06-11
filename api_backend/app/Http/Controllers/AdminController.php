<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\User;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function stats()
    {
        return response()->json([
            'total_products' => Product::count(),
            'total_orders' => 0,
            'total_users' => User::where('role', 'user')->count(),
            'total_revenue' => 0,
        ]);
    }
}