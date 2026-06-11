<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;

class AdminProductController extends Controller
{
    public function index()
    {
        return Product::all();
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|string',
            'material' => 'required|string',
            'price' => 'required|numeric|min:0',
            'img' => 'required|url',
            'is_flash_sale' => 'boolean',
            'discount_percent' => 'integer|min:0|max:100',
        ]);

        $product = Product::create($validated);
        return response()->json($product, 201);
    }

    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'category' => 'sometimes|required|string',
            'material' => 'sometimes|required|string',
            'price' => 'sometimes|required|numeric|min:0',
            'img' => 'sometimes|required|url',
            'is_flash_sale' => 'boolean',
            'discount_percent' => 'integer|min:0|max:100',
        ]);

        $product->update($validated);
        return response()->json($product);
    }

    public function destroy($id)
    {
        $product = Product::findOrFail($id);
        $product->delete();
        return response()->json(['message' => 'Produk dihapus']);
    }
}
