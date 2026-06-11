<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Http\Request;

class VariantController extends Controller
{
    // Get variants for a product
    public function index($productId)
    {
        $product = Product::findOrFail($productId);
        return response()->json(['variants' => $product->variants]);
    }

    // Admin: sync variants (replace all)
    public function sync(Request $request, $productId)
    {
        $product = Product::findOrFail($productId);

        $request->validate([
            'variants' => 'required|array',
            'variants.*.color' => 'required|string',
            'variants.*.size' => 'required|string',
            'variants.*.stock' => 'required|integer|min:0',
        ]);

        $product->variants()->delete();

        foreach ($request->variants as $variant) {
            $product->variants()->create([
                'color' => $variant['color'],
                'size' => $variant['size'],
                'stock' => $variant['stock'],
            ]);
        }

        return response()->json(['variants' => $product->fresh()->variants]);
    }

    // Get stock for a specific color+size combo
    public function stock($productId, Request $request)
    {
        $request->validate([
            'color' => 'required|string',
            'size' => 'required|string',
        ]);

        $variant = ProductVariant::where('product_id', $productId)
            ->where('color', $request->color)
            ->where('size', $request->size)
            ->first();

        return response()->json([
            'stock' => $variant?->stock ?? 0,
        ]);
    }
}
