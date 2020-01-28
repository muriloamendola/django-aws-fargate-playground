#!/bin/sh

python manage.py migrate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('muriloamendola', 'muriloamendola@gmail.com', '123@Changeme')" | python manage.py shell
python manage.py runserver 0.0.0.0:8800
exec "$@"