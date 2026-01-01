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
        Schema::create('course_group', function (Blueprint $table) {
            $table->id();
           $table->string('course_name');
            $table->unsignedBigInteger('group_id');
            $table->string('group_name'); // Column to see the name in DB
            $table->timestamps();
            $table->foreign('group_id')->references('id')->on('groups')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('course_group');
    }
};
