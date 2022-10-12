#include <assert.h>
#include <grpc/grpc.h>
#include <grpcpp/security/server_credentials.h>
#include <grpcpp/server.h>
#include <grpcpp/server_builder.h>
#include <grpcpp/server_context.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

#include <array>
#include <condition_variable>
#include <functional>
#include <iostream>
#include <queue>
#include <sstream>
#include <thread>
#include <tuple>
#include <vector>

#include "common/v1/common.grpc.pb.h"
#include "common/v1/common.pb.h"
#include "component/sensor/v1/sensor.grpc.pb.h"
#include "component/sensor/v1/sensor.pb.h"
#include "robot/v1/robot.grpc.pb.h"
#include "robot/v1/robot.pb.h"

#define DEBUG(x)
using namespace std;
using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::ServerReader;
using grpc::ServerReaderWriter;
using grpc::ServerWriter;
using viam::common::v1::ResourceName;
using viam::component::sensor::v1::SensorService;
using viam::component::sensor::v1::GetReadingsRequest;
using viam::component::sensor::v1::GetReadingsResponse;
using viam::robot::v1::ResourceNamesRequest;
using viam::robot::v1::ResourceNamesResponse;
using viam::robot::v1::RobotService;

class SensorServiceImpl final : public SensorService::Service {
   private:
    std::string reading;

   public:
    SensorServiceImpl(std::string reading) : reading(reading){};
    virtual ~SensorServiceImpl() = default;

    ::grpc::Status GetReadings(ServerContext* context, const GetReadingsRequest* request,
                                 GetReadingsResponse* response) override {
        auto reqName = request->name();

        // response->());

        return grpc::Status::OK;
    }

    virtual std::string name() const { return std::string("CppExampleSensor"); }
};

class RobotServiceImpl final : public RobotService::Service {
   public:
    grpc::Status ResourceNames(ServerContext* context, const ResourceNamesRequest* request,
                               ResourceNamesResponse* response) override {
        ResourceName* name = response->add_resources();
        name->set_namespace_("rdk");
        name->set_type("component");
        name->set_subtype("sensor");
        name->set_name("example");
        return grpc::Status::OK;
    }
};

int main(int argc, char* argv[]) {
    std::string port = "8085";

    // define the services
    RobotServiceImpl robotService;
    SensorServiceImpl sensorService();
    grpc::EnableDefaultHealthCheckService(true);
    ServerBuilder builder;
    std::string address = "0.0.0.0:" + port;
    builder.AddListeningPort(address, grpc::InsecureServerCredentials());
    builder.RegisterService(&robotService);
    builder.RegisterService(&sensorService);
    std::unique_ptr<Server> server(builder.BuildAndStart());
    std::cout << "SensorExampleServer: Starting to listen on " << address << std::endl;
    server->Wait();
    return 0;
}
