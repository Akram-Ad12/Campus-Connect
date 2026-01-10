<?php

namespace App\Http\Controllers\Api;

// Add this line to fix the "Class not found" error!
use App\Http\Controllers\Controller; 
use Illuminate\Http\Request;
use App\Models\CourseTeacher;
use App\Models\CourseGroup;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

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
        $validated = $request->validate([
            'student_id' => 'required|exists:users,id',
            'course_name' => 'required|string',
            // CHANGE THIS LINE: Add '_mark' to match Flutter and DB
            'column' => 'required|in:cc,control', 
            'val' => 'required|numeric|min:0|max:20',
        ]);

        \DB::table('grades')->updateOrInsert(
            [
                'student_id' => $request->student_id, 
                'course_name' => $request->course_name
            ],
            [
                // This now correctly uses 'cc_mark' or 'control_mark'
                $request->column => $request->val, 
                'updated_at' => now(),
            ]
        );

        return response()->json(['status' => 'success']);
    } catch (\Exception $e) {
        // This will help you see the exact error in your browser console
        return response()->json(['error' => $e->getMessage()], 500);
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

public function deleteFile($id)
    {
        try {
            // Find the file record
            $file = DB::table('course_files')->where('id', $id)->first();

            if (!$file) {
                return response()->json(['message' => 'File not found'], 404);
            }

            // 1. Delete physical file from storage/app/public/
            if (Storage::disk('public')->exists($file->file_path)) {
                Storage::disk('public')->delete($file->file_path);
            }

            // 2. Delete the database record
            DB::table('course_files')->where('id', $id)->delete();

            return response()->json(['message' => 'Deleted successfully'], 200);
            
        } catch (\Exception $e) {
            // This returns the actual error message to your Flutter console
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }


public function getAttendanceList(Request $request) {
    $course = $request->query('course_name');
    $group = $request->query('group_name');
    $week = $request->query('week');

    $students = \App\Models\User::where('role', 'student')
                ->where('group_id', 'like', "%$group%")
                ->orderBy('name', 'asc')
                ->get();

    $data = $students->map(function($student) use ($course, $week) {
        $attendance = DB::table('attendances')
            ->where('student_id', $student->id)
            ->where('course_name', $course)
            ->where('week_number', $week)
            ->first();

        return [
            'id' => $student->id,
            'name' => $student->name,
            'is_present' => $attendance ? (bool)$attendance->is_present : false,
        ];
    });

    return response()->json($data);
}

public function toggleAttendance(Request $request) {
    $studentId = $request->student_id;
    $course = $request->course_name;
    $week = $request->week;
    $isPresent = $request->is_present;

    DB::table('attendances')->updateOrInsert(
        ['student_id' => $studentId, 'course_name' => $course, 'week_number' => $week],
        ['is_present' => $isPresent, 'updated_at' => now()]
    );

    return response()->json(['status' => 'success']);
}

public function getGroupDetails(Request $request) {
    $group = $request->query('group_name');
    $course = $request->query('course_name');

    // Fetch students in the group
    $students = \App\Models\User::where('role', 'student')
                ->where('group_id', 'like', "%$group%")
                ->orderBy('name', 'asc')
                ->get();

    // Inside getGroupDetails in TeacherController.php
$data = $students->map(function($student) use ($course) {
    $grade = DB::table('grades')
        ->where('student_id', $student->id)
        ->where('course_name', $course)
        ->first();

    $attendanceCount = DB::table('attendances')
        ->where('student_id', $student->id)
        ->where('course_name', $course)
        ->where('is_present', true)
        ->count();

    return [
        'name' => $student->name,
        // Match these keys to what the Flutter DataTable expects
        'cc' => $grade ? $grade->cc : null, 
        'control' => $grade ? $grade->control : null,
        'attendance' => $attendanceCount,
    ];
});

    return response()->json($data);
}
}
