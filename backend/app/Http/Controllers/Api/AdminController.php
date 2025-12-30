<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Group;
use Illuminate\Http\Request;

class AdminController extends Controller {
    public function getPendingStudents() {
        // Only return students waiting for approval
        $students = User::where('role', 'student')->where('is_validated', 0)->get();
        return response()->json($students);
    }

    public function validateStudent(Request $request) {
        $user = User::find($request->user_id);
        if ($user) {
            // status 1 = approved, -1 = rejected
            $user->is_validated = $request->status;
            $user->save();
            return response()->json(['message' => 'Status updated successfully']);
        }
        return response()->json(['message' => 'User not found'], 404);
    }

public function getGroups() {
    return Group::with(['users' => function($query) {
        $query->select('name', 'role', 'group_id');
    }])->get()->map(function($group) {
        return [
            'id' => $group->id,
            'name' => $group->name,
            'teachers_names' => $group->users->where('role', 'teacher')->pluck('name')->implode(', '),
            'students_names' => $group->users->where('role', 'student')->pluck('name')->implode(', '),
        ];
    });
}

public function createGroup(Request $request) {
    $request->validate(['name' => 'required|unique:groups']);
    Group::create(['name' => $request->name]);
    return response()->json(['message' => 'Group created successfully']);
}

public function deleteGroup($id) {
    $group = Group::find($id);
    if ($group) {
        // This will unassign all students/teachers automatically 
        // if your database is set up correctly
        $group->delete(); 
        return response()->json(['message' => 'Group deleted']);
    }
    return response()->json(['message' => 'Group not found'], 404);
}

public function getUsersToAssign() {
    // Get all validated students and teachers
    $users = User::where('is_validated', 1) 
                 ->whereIn('role', ['student', 'teacher'])
                 ->get();

                 \Log::info("Found users: " . $users->count());
    return response()->json($users);
}

public function assignGroup(Request $request) {
    $user = User::find($request->user_id);
    if ($user) {
        $user->group_id = $request->group_name; // Storing the name as per your current DB schema
        $user->save();
        return response()->json(['message' => 'User assigned to group']);
    }
    return response()->json(['message' => 'User not found'], 404);
}


public function updateMemberGroup(Request $request) {
    $user = User::find($request->user_id);
    $user->group_id = $request->new_group_value; // Just save the string
    $user->save();

    return response()->json(['message' => 'Updated']);
}


public function deleteStudent($id) {
    $user = User::where('id', $id)->where('role', 'student')->first();

    if (!$user) {
        return response()->json(['message' => 'Student not found or unauthorized'], 404);
    }

    $user->delete();
    return response()->json(['message' => 'Student deleted successfully']);
}


public function uploadSchedule(Request $request) {
    $request->validate([
        'group_id' => 'required|exists:groups,id',
        'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
    ]);

    $group = Group::find($request->group_id);

    if ($request->hasFile('image')) {
        // Store in storage/app/public/schedules
        $path = $request->file('image')->store('schedules', 'public');
        $group->schedule_image = $path;
        $group->save();

        return response()->json(['message' => 'Schedule uploaded successfully', 'path' => $path]);
    }

    return response()->json(['message' => 'Upload failed'], 400);
}
}
