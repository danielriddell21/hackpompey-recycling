# hackpompey-recycling

This is a recycling app and service for portsmouth

## Pre-requisites
- Go 1.20+
- Air (
    go install github.com/cosmtrek/air@latest
    )
- Flutter (
    https://docs.flutter.dev/get-started/install
    )

## Usage
- Run the service
    just run
- Run the app
    just app
- Forward the service to the internet (requires ngrok)
    just forward
- Generate the protobuf code
    just gen

## Project structure
- `go/` - The Go service
- `app/` - The Flutter app
- `proto/` - The protobuf definitions

## Android users: Scan the QR code to install the app and test it out!
<img src="QR-CODE.png" alt="QR" width="400"/>