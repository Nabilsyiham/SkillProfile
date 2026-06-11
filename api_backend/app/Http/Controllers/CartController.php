<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\Product;
use Illuminate\Http\Request;

class CartController extends Controller
{
    // Get user's cart
    public function index(Request $request)
    {
        $cartItems = Cart::where('user_id', $request->user()->id)
            ->with('product:id,name,category,price,img')
            ->get();

        return response()->json(['cart' => $cartItems]);
    }

    // Add item to cart
    public function store(Request $request)
    {
        $request->validate([
            'product_id' => 'required|integer',
            'color' => 'required|string',
            'size' => 'required|string',
            'quantity' => 'required|integer|min:1',
        ]);

        $existing = Cart::where('user_id', $request->user()->id)
            ->where('product_id', $request->product_id)
            ->where('color', $request->color)
            ->where('size', $request->size)
            ->first();

        if ($existing) {
            $existing->update(['quantity' => $existing->quantity + $request->quantity]);
            return response()->json(['cart' => $existing->fresh()->load('product:id,name,category,price,img')]);
        }

        $cartItem = Cart::create([
            'user_id' => $request->user()->id,
            'product_id' => $request->product_id,
            'color' => $request->color,
            'size' => $request->size,
            'quantity' => $request->quantity,
        ]);

        return response()->json(['cart' => $cartItem->load('product:id,name,category,price,img')], 201);
    }

    // Update quantity
    public function update(Request $request, $id)
    {
        $cartItem = Cart::where('user_id', $request->user()->id)->findOrFail($id);

        $request->validate([
            'quantity' => 'required|integer|min:1',
        ]);

        $cartItem->update(['quantity' => $request->quantity]);

        return response()->json(['cart' => $cartItem->fresh()->load('product:id,name,category,price,img')]);
    }

    // Remove item
    public function destroy(Request $request, $id)
    {
        Cart::where('user_id', $request->user()->id)->findOrFail($id)->delete();
        return response()->json(['message' => 'Item removed']);
    }

    // Clear cart
    public function clear(Request $request)
    {
        Cart::where('user_id', $request->user()->id)->delete();
        return response()->json(['message' => 'Cart cleared']);
    }
}
