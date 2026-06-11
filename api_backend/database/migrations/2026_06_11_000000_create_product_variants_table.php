<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('product_variants', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained()->onDelete('cascade');
            $table->string('color');
            $table->string('size');
            $table->integer('stock')->default(0);
            $table->timestamps();

            $table->unique(['product_id', 'color', 'size']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('product_variants');
    }
};
