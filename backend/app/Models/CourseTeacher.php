<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CourseTeacher extends Model
{
    protected $table = 'course_teacher';
    protected $fillable = ['course_name', 'teacher_id', 'teacher_name'];

    public function teacher() {
        return $this->belongsTo(User::class, 'teacher_id');
    }
}
