from flask import session, redirect, request
from objects.osuapi import authorize
from functools import wraps

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if session == {}:
            return redirect(authorize('login', 'identify', request.path))
        return f(*args, **kwargs)
    return decorated_function