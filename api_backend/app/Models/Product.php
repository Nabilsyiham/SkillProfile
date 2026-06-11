<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'category',
        'material',
        'price',
        'img',
        'is_flash_sale',
        'discount_percent',
    ];

    protected $casts = [
        'is_flash_sale' => 'boolean',
        'discount_percent' => 'integer',
    ];

    public function variants()
    {
        return $this->hasMany(ProductVariant::class);
    }
}
