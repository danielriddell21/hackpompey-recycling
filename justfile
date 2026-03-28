set shell := ["powershell.exe", "-c"]

gen: 
  ./scripts/generate.bat

run: 
  cd go/service; air server --port 50051

app:
  cd flutter/barcode_scanner_app; flutter run

forward: 
  ngrok http --app-protocol=http2 50051