from celery import Celery

app = Celery(
    'tasks',
    broker='redis://localhost:6379/0',  # Redis as broker
    backend='redis://localhost:6379/0',  # Redis for result storage
)
app.conf.update(
    task_serializer='json',
    result_serializer='json',
    accept_content=['json'],
    timezone='UTC',
    enable_utc=True,
)
