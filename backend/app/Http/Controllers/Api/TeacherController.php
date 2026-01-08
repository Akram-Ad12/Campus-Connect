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

public function getGroupStudents(Request $request) {
    // Use query() to fetch from URL parameters: ?course_name=...&group_name=...
    $course = $request->query('course_name');
    $groupName = $request->query('group_name');

    // Get students where their group_id string contains the selected group name
    $students = \App\Models\User::where('role', 'student')
                ->where('group_id', 'LIKE', "%{$groupName}%")
                ->orderBy('name', 'asc')
                ->get();

    // Map the grades manually to ensure we return 0 if no grade exists yet
    $data = $students->map(function($student) use ($course) {
        $grade = \DB::table('grades')
                   ->where('student_id', $student->id)
                   ->where('course_name', $course)
                   ->first();

        return [
            'id' => $student->id,
            'name' => $student->name,
            'cc' => $grade->cc ?? 0,
            'control' => $grade->control ?? 0,
        ];
    });

    return response()->json($data);
}

// Live-update grade
public function updateGrade(Request $request)
{
    try {
        // 1. Validate the input (0-20 only)
        $validated = $request->validate([
            'student_id' => 'required|exists:users,id',
            'course_name' => 'required|string',
            'column' => 'required|in:cc,control', // Only allow these two columns
            'val' => 'required|numeric|min:0|max:20',
        ]);

        // 2. Perform the update or insert
        // Use updateOrInsert to handle students who don't have a grade record yet
        \DB::table('grades')->updateOrInsert(
            [
                'student_id' => $request->student_id, 
                'course_name' => $request->course_name
            ],
            [
                $request->column => $request->val, 
                'updated_at' => now(),
                'created_at' => now()
            ]
        );

        return response()->json(['status' => 'success']);
    } catch (\Exception $e) {
        // This will print the error to your Laravel logs
        return response()->json(['message' => $e->getMessage()], 500);
    }
}

public function uploadFile(Request $request) {
    $request->validate([
        'course_name' => 'required',
        'file' => 'required|mimes:pdf,jpg,jpeg,png|max:5120', // 5MB limit
    ]);

    if ($request->hasFile('file')) {
        $file = $request->file('file');
        $name = $file->getClientOriginalName();
        $path = $file->store('course_materials', 'public');
        $type = $file->getClientOriginalExtension() == 'pdf' ? 'pdf' : 'image';

        $fileRecord = DB::table('course_files')->insertGetId([
            'course_name' => $request->course_name,
            'file_path' => $path,
            'file_name' => $name,
            'file_type' => $type,
            'created_at' => now(),
        ]);

        return response()->json(['id' => $fileRecord, 'path' => $path]);
    }
}

public function getCourseFiles($course_name) {
    $files = DB::table('course_files')->where('course_name', $course_name)->get();
    return response()->json($files);
}
}
