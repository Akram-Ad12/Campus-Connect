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
});