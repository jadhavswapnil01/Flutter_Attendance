from celery import Celery

# Configure Celery
celery_app = Celery(
    'face_tasks',
    broker='redis://localhost:6379/0',  # Change the Redis URL if needed
    backend='redis://localhost:6379/0'
)
