<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CourseGroup extends Model
{
    protected $table = 'course_group';
    protected $fillable = ['course_name', 'group_id', 'group_name'];

    public function group() {
        return $this->belongsTo(Group::class, 'group_id');
    }
}
