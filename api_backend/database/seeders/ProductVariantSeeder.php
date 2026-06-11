<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Product;

class ProductVariantSeeder extends Seeder
{
    public function run()
    {
        $colors = ['Charcoal', 'Warm Earth', 'Bone White'];
        $sizes = ['XS', 'S', 'M', 'L'];

        $products = Product::all();

        foreach ($products as $product) {
            foreach ($colors as $color) {
                foreach ($sizes as $size) {
                    DB::table('product_variants')->insert([
                        'product_id' => $product->id,
                        'color' => $color,
                        'size' => $size,
                        'stock' => rand(0, 20),
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }
        }
    }
}
