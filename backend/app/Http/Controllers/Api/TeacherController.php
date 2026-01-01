<?php

namespace App\Http\Controllers\Api;

// Add this line to fix the "Class not found" error!
use App\Http\Controllers\Controller; 
use Illuminate\Http\Request;
use App\Models\CourseTeacher;
use App\Models\CourseGroup;
use Illuminate\Support\Facades\DB;

class TeacherController extends Controller
{
    public function getTeacherData(Request $request)
{
    try {
        $user = $request->user();

        // 1. Get Course Names from the course_teacher pivot table
        $courses = CourseTeacher::where('teacher_id', $user->id)
            ->pluck('course_name');

        // 2. Get Group Names directly from the Teacher's own user record
        // We split the string "L3 Group 4, L3 Group 1" into an array
        $groupsString = $user->group_id; 
        $groupsArray = $groupsString ? array_map('trim', explode(',', $groupsString)) : [];

        return response()->json([
            'name' => $user->name,
            'courses' => $courses,
            'groups' => $groupsArray, // Returning the simple list of names
        ]);
    } catch (\Exception $e) {
        return response()->json(['message' => $e->getMessage()], 500);
    }
}
}
