<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\StudentInformation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StudentController extends Controller
{
    public function updateProfile(Request $request)
   {
    $user = $request->user();
    
    // Validate that the column being sent is one of our allowed profile fields
    $validated = $request->validate([
        'column' => 'required|in:sex,dob,pob',
        'val' => 'required|string|max:255',
    ]);

    StudentInformation::updateOrCreate(
        ['user_id' => $user->id],
        [$validated['column'] => $validated['val']]
    );

    return response()->json(['message' => 'Profile updated successfully']);
    }


    public function getProfile(Request $request) {
    $user = $request->user();
    
    $profile = DB::table('users')
        ->leftJoin('student_information', 'users.id', '=', 'student_information.user_id')
        // CHANGED: Use group_id to join with groups.name
        ->leftJoin('groups', 'users.group_id', '=', 'groups.name') 
        ->where('users.id', $user->id)
        ->select(
            'users.name', 
            'users.email', 
            'users.group_id',
            'student_information.sex', 
            'student_information.dob', 
            'student_information.pob', 
            'student_information.profile_picture',
            'groups.schedule_image'
        )
        ->first();

    return response()->json($profile);
    }

    public function uploadAvatar(Request $request)
   {
    $request->validate([
        'avatar' => 'required|image|mimes:jpeg,png,jpg|max:2048',
    ]);

    $user = $request->user();

    if ($request->hasFile('avatar')) {
        // Store image in public/storage/avatars
        $path = $request->file('avatar')->store('avatars', 'public');

        // Update the profile record
        StudentInformation::updateOrCreate(
            ['user_id' => $user->id],
            ['profile_picture' => $path]
        );

        return response()->json(['message' => 'Avatar uploaded', 'path' => $path]);
    }

    return response()->json(['error' => 'No file uploaded'], 400);
    }
    
}
