GRPCFLAGS = `pkg-config --cflags grpc --libs protobuf grpc++` -pthread -Wl,-lgrpc++_reflection -Wl,-ldl
GRPCDIR=./grpc/cpp/gen
SOURCES = $(GRPCDIR)/robot/v1/robot.grpc.pb.cc $(GRPCDIR)/robot/v1/robot.pb.cc
SOURCES += $(GRPCDIR)/common/v1/common.grpc.pb.cc $(GRPCDIR)/common/v1/common.pb.cc
SOURCES += $(GRPCDIR)/component/sensor/v1/sensor.grpc.pb.cc $(GRPCDIR)/component/sensor/v1/sensor.pb.cc
SOURCES += $(GRPCDIR)/google/api/annotations.pb.cc $(GRPCDIR)/google/api/httpbody.pb.cc
SOURCES += $(GRPCDIR)/google/api/http.pb.cc

bufsetup:
	sudo apt-get install -y protobuf-compiler-grpc libgrpc-dev libgrpc++-dev || brew install grpc openssl --quiet
	GOBIN=`pwd`/grpc/bin go install github.com/bufbuild/buf/cmd/buf@v1.8.0
	ln -sf `which grpc_cpp_plugin` grpc/bin/protoc-gen-grpc-cpp
	pkg-config openssl || export PKG_CONFIG_PATH=$$PKG_CONFIG_PATH:`find \`which brew > /dev/null && brew --prefix\` -name openssl.pc | head -n1 | xargs dirname`

buf: bufsetup
	PATH="${PATH}:`pwd`/grpc/bin" buf generate --template ./buf.gen.yaml buf.build/viamrobotics/api
	PATH="${PATH}:`pwd`/grpc/bin" buf generate --template ./buf.grpc.gen.yaml buf.build/viamrobotics/api
	PATH="${PATH}:`pwd`/grpc/bin" buf generate --template ./buf.gen.yaml buf.build/googleapis/googleapis

sensorserver: example_sensor.cpp $(LIB_FILES) $(SOURCES)
	g++ -g -std=c++17 example_sensor.cpp $(LIB_FILES) `pkg-config --cflags --libs libhttpserver` $(SOURCES) -I$(GRPCDIR) $(GRPCFLAGS) -o example_sensor
