import redis
import uuid

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

def create_session(r, user_id, duration_seconds=1800):
    session_id = str(uuid.uuid4())
    r.setex(f"session:{session_id}", duration_seconds, user_id)
    return session_id

def get_session_user(r, session_id):
    user_id = r.get(f"session:{session_id}")
    if user_id:
        r.expire(f"session:{session_id}", 1800)
    return user_id

def delete_session(r, session_id):
    r.delete(f"session:{session_id}")

if __name__ == "__main__":
    sid = create_session(r, "user123")
    print(f"Created session: {sid}")
    print(f"User for session: {get_session_user(r, sid)}")
    delete_session(r, sid)
    print(f"User after delete: {get_session_user(r, sid)}")
