<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    // Sprint 3: Login Process 
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (!Auth::attempt($credentials)) {
            return response()->json(['message' => 'Invalid Credentials'], 401);
        }

        $user = Auth::user();

        // Check if Admin has validated the student 
        if ($user->is_validated == 0) {
            return response()->json(['message' => 'Pending admin approval'], 401);
        }
        if ($user->is_validated == -1) { // Assuming -1 is rejected
            return response()->json(['message' => 'Account not approved by admin'], 401);
        }

        // Create a token for the Flutter app to stay logged in
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user, // This includes the 'role' so Flutter knows which Home to show 
        ]);
    }


    public function register(Request $request) {
    $request->validate([
        'name' => 'required|string',
        'email' => 'required|email|unique:users',
        'password' => 'required|min:6',
    ]);

    $user = User::create([
        'name' => $request->name,
        'email' => $request->email,
        'password' => bcrypt($request->password),
        'role' => 'student', // Requirement 1: Only students can register
        'is_validated' => 0,  // Requirement 4: Must be validated
    ]);

    return response()->json(['message' => 'Register completed, Pending admin approval'], 201);
}

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out successfully']);
    }
}
