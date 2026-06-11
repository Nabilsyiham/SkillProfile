<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'address_id' => 'required|exists:addresses,id',
            'phone' => 'required|string',
            'payment_method' => 'required|string|in:cod,transfer,ewallet',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.color' => 'required|string',
            'items.*.size' => 'required|string',
        ]);

        $address = \App\Models\Address::where('user_id', $request->user()->id)
            ->where('id', $request->address_id)
            ->firstOrFail();

        $totalPrice = 0;
        $items = [];

        foreach ($request->items as $item) {
            $product = \App\Models\Product::find($item['product_id']);
            $subtotal = $product->price * $item['quantity'];
            $totalPrice += $subtotal;
            $items[] = [
                'product_id' => $item['product_id'],
                'quantity' => $item['quantity'],
                'price' => $product->price,
                'color' => $item['color'],
                'size' => $item['size'],
            ];
        }

        $shippingFee = $totalPrice < 250000 ? 15000 : 0;
        $totalPrice += $shippingFee;

        $order = DB::transaction(function () use ($request, $totalPrice, $items, $address) {
            $order = Order::create([
                'user_id' => $request->user()->id,
                'address_id' => $request->address_id,
                'total_price' => $totalPrice,
                'address' => $address->address . ', ' . $address->city . ', ' . $address->province,
                'phone' => $request->phone,
                'payment_method' => $request->payment_method,
                'status' => 'pending',
            ]);

            foreach ($items as $item) {
                $order->items()->create($item);

                $variant = \App\Models\ProductVariant::where('product_id', $item['product_id'])
                    ->where('color', $item['color'])
                    ->where('size', $item['size'])
                    ->first();

                if ($variant) {
                    $variant->stock = max(0, $variant->stock - $item['quantity']);
                    $variant->save();
                }
            }

            return $order;
        });

        return response()->json([
            'message' => 'Order placed successfully',
            'order' => $order->load('items.product'),
        ], 201);
    }

    public function index(Request $request)
    {
        return Order::where('user_id', $request->user()->id)
            ->with('items.product')
            ->latest()
            ->get();
    }

    public function show(Request $request, $id)
    {
        return Order::where('user_id', $request->user()->id)
            ->with('items.product')
            ->findOrFail($id);
    }
}
