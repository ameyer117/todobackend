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

FROM python:3.8-alpine
LABEL application=todobackend

RUN apk add --no-cache python3 bash mariadb-client

RUN addgroup -g 1000 app && \
    adduser -u 1000 -G app -D app

COPY --from=test --chown=app:app /build /build
COPY --from=test --chown=app:app /app /app

RUN pip3 install -r /build/requirements.txt -f /build --no-index --no-cache-dir
RUN rm -rf /build

# Create public volume for static files
RUN mkdir /static
RUN python3 /app/manage.py collectstatic --no-input --settings=todobackend.settings_release
RUN chown app:app /static


WORKDIR /app
USER app