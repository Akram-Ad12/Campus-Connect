<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CourseAssignment extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'course_name',
        'teacher_id',
        'group_id',
    ];

    /**
     * Relationship with the User model (Teacher).
     * Since teachers are stored in the users table.
     */
    public function teacher()
    {
        return $this->belongsTo(User::class, 'teacher_id');
    }

    /**
     * Relationship with the Group model.
     */
    public function group()
    {
        return $this->belongsTo(Group::class, 'group_id');
    }
}
