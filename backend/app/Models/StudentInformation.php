<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StudentInformation extends Model
{
    use HasFactory;

    protected $table = 'student_information';

    protected $fillable = [
        'user_id',
        'profile_picture',
        'sex',
        'dob',
        'pob'
    ];

    /**
     * Get the user that owns the profile information.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}