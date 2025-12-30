<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Predefined Admin Account [cite: 9, 10]
        User::create([
            'name' => 'Campus Admin',
            'email' => 'admin@campus.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'is_validated' => true, // Admin is pre-validated
        ]);

        // 2. Predefined Teacher Account 1 [cite: 9, 11]
        User::create([
            'name' => 'Dr. Ahmed Ben',
            'email' => 'ahmed@campus.com',
            'password' => Hash::make('teacher123'),
            'role' => 'teacher',
            'is_validated' => true,
        ]);

        // 3. Predefined Teacher Account 2 [cite: 9, 11]
        User::create([
            'name' => 'Prof. Sarah Larbi',
            'email' => 'sarah@campus.com',
            'password' => Hash::make('teacher123'),
            'role' => 'teacher',
            'is_validated' => true,
        ]);
    }
}
