<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::create([
            'name' => 'Campus Admin',
            'email' => 'admin@campus.com',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'is_validated' => true,
        ]);

        User::create([
            'name' => 'Dr. Ahmed Ben',
            'email' => 'ahmed@campus.com',
            'password' => Hash::make('teacher123'),
            'role' => 'teacher',
            'is_validated' => true,
        ]);

        User::create([
            'name' => 'Prof. Sarah Larbi',
            'email' => 'sarah@campus.com',
            'password' => Hash::make('teacher123'),
            'role' => 'teacher',
            'is_validated' => true,
        ]);

        User::create([
            'name' => 'Prof. Fatima Kacmi',
            'email' => 'fatima@campus.com',
            'password' => Hash::make('teacher123'),
            'role' => 'teacher',
            'is_validated' => true,
        ]);

        User::create([
            'name' => 'Dr. Salah Eddin',
            'email' => 'salah@campus.com',
            'password' => Hash::make('teacher123'),
            'role' => 'teacher',
            'is_validated' => true,
        ]);

        User::create([
            'name' => 'Dr. Bouramoul',
            'email' => 'bouramoul@campus.com',
            'password' => Hash::make('teacher123'),
            'role' => 'teacher',
            'is_validated' => true,
        ]);

        User::create([
            'name' => 'Prof. Yassmine Lina',
            'email' => 'lina@campus.com',
            'password' => Hash::make('teacher123'),
            'role' => 'teacher',
            'is_validated' => true,
        ]);

        User::create([
            'name' => 'Prof. Hafida Derradji',
            'email' => 'hafida@campus.com',
            'password' => Hash::make('teacher123'),
            'role' => 'teacher',
            'is_validated' => true,
        ]);

    }
}
