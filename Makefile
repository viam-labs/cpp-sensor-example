bufsetup:
	sudo apt-get install -y protobuf-compiler-grpc libgrpc-dev libgrpc++-dev || brew install grpc openssl --quiet
	GOBIN=`pwd`/grpc/bin go install github.com/bufbuild/buf/cmd/buf@v1.8.0
	ln -sf `which grpc_cpp_plugin` grpc/bin/protoc-gen-grpc-cpp
	pkg-config openssl || export PKG_CONFIG_PATH=$$PKG_CONFIG_PATH:`find \`which brew > /dev/null && brew --prefix\` -name openssl.pc | head -n1 | xargs dirname`

buf: bufsetup
	PATH="${PATH}:`pwd`/grpc/bin" buf generate --template ./buf.gen.yaml buf.build/viamrobotics/api
	PATH="${PATH}:`pwd`/grpc/bin" buf generate --template ./buf.grpc.gen.yaml buf.build/viamrobotics/api
	PATH="${PATH}:`pwd`/grpc/bin" buf generate --template ./buf.gen.yaml buf.build/googleapis/googleapis
