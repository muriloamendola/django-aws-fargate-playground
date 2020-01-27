FROM python:3.8.1-alpine3.11

LABEL maintainer="muriloamendola@gmail.com"

ENV PYTHONUNBUFFERED 1

RUN mkdir /app
WORKDIR /app

COPY tutorial ./tutorial 
COPY core ./core
COPY requirements-dev.txt .
COPY requirements.txt .
COPY manage.py .

RUN apk update && apk add postgresql-dev gcc musl-dev
RUN pip install -r requirements.txt

ENTRYPOINT ["python", "manage.py"]
CMD ["runserver", "0.0.0.0:8800"]