# Test stage
FROM alpine AS test
LABEL application=todobackend

# Install basic utilities
RUN apk add --no-cache bash git

# Install build dependencies
RUN apk add --update python3 mariadb-dev
RUN python3 -m ensurepip

# Copy requirements
COPY /src/requirements* /build/
WORKDIR /build

RUN pip3 install -r requirements_test.txt

# Copy source code
COPY /src /app
WORKDIR /app

# Test entrypoint
CMD ["python3", "manage.py", "test", "--noinput", "--settings=todobackend.settings_test"]

FROM alpine
LABEL application=todobackend

# Install operating system dependencies
RUN apk add --no-cache python3 mariadb-client bash
RUN python3 -m ensurepip

# Create app user
RUN addgroup -g 1000 app && adduser -u 1000 -G app -D app

COPY --from=test --chown=app:app /app /app
COPY --from=test --chown=app:app /build /build

RUN pip3 install -r /build/requirements.txt
RUN rm -rf /build

WORKDIR /app
USER app




