#!/bin/bash

echo ""
echo "Loading azd .env file from current environment"
echo ""

while IFS='=' read -r key value; do
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    export "$key=$value"
done < <(azd env get-values)


if [ $? -ne 0 ]; then
    echo "Failed to load environment variables from azd environment"
    exit $?
fi

echo ""
echo "Restoring backend python packages"
echo ""

cd backend
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "Failed to restore backend python packages"
    exit $?
fi

echo ""
echo "Restoring frontend npm packages"
echo ""

cd ../frontend
npm install
if [ $? -ne 0 ]; then
    echo "Failed to restore frontend npm packages"
    exit $?
fi

echo ""
echo "Building frontend"
echo ""

npm run build
if [ $? -ne 0 ]; then
    echo "Failed to build frontend"
    exit $?
fi

echo ""
echo "Starting backend"
echo ""

cd ../backend
xdg-open http://127.0.0.1:5000
python ./app.py
if [ $? -ne 0 ]; then
    echo "Failed to start backend"
    exit $?
fi
