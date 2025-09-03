#!/bin/bash
. app_data.sh

TEST_COMMAND="oxipng data/test.png --out test.png"

# Build image
docker build --no-cache \
    --build-arg "APP_NAME=${APP_NAME}" \
    --build-arg "APP_VERSION=${APP_VERSION}" \
    -t "${REPOSITORY}/${APP_NAME}:${APP_VERSION}" \
    -t "${REPOSITORY}/${APP_NAME}:latest" \
    . &&\
docker run --rm -it \
    -v ./data:/app/data \
    "${REPOSITORY}/${APP_NAME}:${APP_VERSION}" \
    $TEST_COMMAND &&\
docker push --all-tags "${REPOSITORY}/${APP_NAME}"

EXIT_CODE=$?
echo "Exit code: ${EXIT_CODE}"
exit $EXIT_CODE