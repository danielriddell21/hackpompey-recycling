@echo off
cd /d %~dp0\..
set PATH=%PATH%;C:\Users\riddler\AppData\Local\Pub\Cache\bin;C:\flutter\bin;C:\Program Files\Git\bin
REM Create output directories
md .\flutter\barcode_scanner_app\lib\generated 2>nul
REM Generate Go code
protoc --go_out=./go/service --go_opt=paths=source_relative --go-grpc_out=./go/service --go-grpc_opt=paths=source_relative proto/*.proto

REM Generate Dart code for Flutter
protoc --dart_out=grpc:./flutter/barcode_scanner_app/lib/generated -Iproto proto/*.proto

echo Code generation complete.