FROM python:3.8-alpine as test

LABEL application=todobackend

# Install basic utilities
RUN apk add --no-cache bash git

# Install build dependencies
RUN apk add --no-cache gcc python3-dev libffi-dev musl-dev linux-headers mariadb-dev

COPY /src/requirements* /build/
WORKDIR /build

RUN pip3 wheel -r requirements_test.txt --no-cache-dir --no-input
RUN pip3 install -r requirements_test.txt -f /build --no-index --no-cache-dir

COPY /src /app
WORKDIR /app

CMD ["python3", "manage.py", "test", "--noinput", "--settings=todobackend.settings_test"]