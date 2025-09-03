#!/bin/bash
. app_data.sh

mkdir -p dist data
rm -rf dist/*
docker run --rm -it \
    -v ./data:/app/data \
    -v ./dist:/app/dist \
    "${REPOSITORY}/${APP_NAME}:${APP_VERSION}" \
    tar -cavf /app/dist/oxipng-lin-x64.tar.gz -C /usr/local/bin/ oxipng &&\
git add . &&\
git commit -m "new version $APP_VERSION" &&\
git tag "$APP_VERSION" &&\
git push &&\
git push --tags &&\
gh release create "$APP_VERSION" \
    --title "$APP_VERSION" \
    --notes "$APP_VERSION" \
    dist/*

EXIT_CODE=$?
echo "Exit code: ${EXIT_CODE}"
exit $EXIT_CODE