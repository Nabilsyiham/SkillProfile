<?php

namespace App\Http\Controllers;

use App\Models\Order;
use Illuminate\Http\Request;

class AdminOrderController extends Controller
{
    public function index()
    {
        return Order::with(['user', 'items.product', 'address'])->latest()->get();
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:pending,processing,shipped,delivered,cancelled',
        ]);

        $order = Order::findOrFail($id);
        $order->update(['status' => $request->status]);

        return response()->json([
            'message' => 'Status updated',
            'order' => $order->load('user', 'items.product'),
        ]);
    }

    public function pendingCount()
    {
        $count = Order::where('status', 'pending')->count();
        return response()->json(['count' => $count]);
    }
}
