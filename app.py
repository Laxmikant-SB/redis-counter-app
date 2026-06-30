import redis
import time
import os

REDIS_HOST = os.environ.get('REDIS_HOST', 'localhost')
r = redis.Redis(host=REDIS_HOST, port=6379, decode_responses=True)

counter = 0
while True:
    counter += 1
    r.set('visits', counter)
    value = r.get('visits')
    print(f"Visit count: {value}")
    time.sleep(2)

# Intentional broken syntax
def broken_function(:
    pass
