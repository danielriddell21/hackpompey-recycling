@echo off
REM Generate Go code
protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative proto/*.proto

REM Generate Dart code for Flutter
protoc --dart_out=grpc:./flutter/lib/generated -Iproto proto/*.proto

echo Code generation complete.