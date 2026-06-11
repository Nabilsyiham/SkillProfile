<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        DB::unprepared("ALTER TABLE orders MODIFY COLUMN status VARCHAR(20) DEFAULT 'pending'");
    }

    public function down()
    {
        DB::unprepared("ALTER TABLE orders MODIFY COLUMN status ENUM('pending','shipped','completed') DEFAULT 'pending'");
    }
};
