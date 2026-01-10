<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\TeacherController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);

Route::get('/admin/pending-students', [AdminController::class, 'getPendingStudents']);
Route::post('/admin/validate-student', [AdminController::class, 'validateStudent']);



Route::middleware('auth:sanctum')->group(function () {
    // Group Management
    Route::get('/admin/groups', [AdminController::class, 'getGroups']);
    Route::post('/admin/groups', [AdminController::class, 'createGroup']);
    Route::delete('/admin/groups/{id}', [AdminController::class, 'deleteGroup']);
    
    // User Management
    Route::get('/admin/users-to-assign', [AdminController::class, 'getUsersToAssign']);
    Route::post('/admin/assign-group', [AdminController::class, 'assignGroup']);
    Route::delete('/admin/users/{id}', [AdminController::class, 'deleteStudent']);

    // Schedule Upload
    Route::post('/admin/upload-schedule', [AdminController::class, 'uploadSchedule']);

    // Course Assignment
    Route::get('/admin/course-assignments', [AdminController::class, 'getCourseAssignments']);
    Route::post('/admin/toggle-course-assignment', [AdminController::class, 'toggleCourseAssignment']);

    // Teacher Dashboard
    Route::get('/teacher/dashboard', [TeacherController::class, 'getTeacherData']);
    // Grades Management
    Route::get('/teacher/get-students', [TeacherController::class, 'getGroupStudents']);
    Route::post('/teacher/update-grade', [TeacherController::class, 'updateGrade']);

    // File Uploads
    Route::post('/teacher/upload-file', [TeacherController::class, 'uploadFile']);
    // Get Course Files
    Route::get('/course/files/{course_name}', [TeacherController::class, 'getCourseFiles']);
    // Delete Course File
    Route::delete('/teacher/delete-file/{id}', [TeacherController::class, 'deleteFile']);
    // Attendance Management
    Route::get('/teacher/get-attendance', [TeacherController::class, 'getAttendanceList']);
    Route::post('/teacher/toggle-attendance', [TeacherController::class, 'toggleAttendance']);
});