<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('course_group', function (Blueprint $table) {
            if (!Schema::hasColumn('course_group', 'group_name')) {
                $table->string('group_name')->after('group_id')->nullable();
            }

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('course_group', function (Blueprint $table) {
            //
        });
    }
};
