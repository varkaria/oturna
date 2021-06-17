from flask import session, redirect, request, flash, url_for
from objects.osuapi import authorize
from objects import mysql
from functools import wraps
from objects.flag import Staff

db = mysql.DB()

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if session == {}:
            return redirect(authorize('login', 'identify', request.path))
        return f(*args, **kwargs)
    return decorated_function

def need_privilege(privilege: Staff):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            user = db.get_staff(user_id=session['user_id'])
            if user == None:
                return redirect(authorize('login', 'identify', request.path))
            user_privilege = Staff(user['privileges'])
            if privilege not in user_privilege:
                flash(f"You don't have {privilege.name} authority!", 'danger')
                return redirect(url_for('backend.dashboard'))
            return f(*args, **kwargs)
        return decorated_function
    return decorator

def check_privilege(id, privilege: Staff):
    user = db.get_staff(staff_id=id)
    user_privilege = Staff(user['privileges'])
    return bool(privilege in user_privilege)