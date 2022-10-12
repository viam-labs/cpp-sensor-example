# cpp-sensor-example
An example viam sensor component and server in c++.
The server exposes a single instance of a single sensor component.
That component returns the number of times its getReadings() method was called as well as whatever string was passed into its constructor.

## Building and Running
Step 1 is to build the cpp protobuf interfaces:
`make buf` should do the trick

Assuming that goes relatively smoothly,
`make sensorserver` should build the example_sensor executable

On Mac OS X, I found I needed to run `export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig"` to get `make sensorserver` to work.
Otherwise, I would get errors on the includes of `<google/protobuf/port_def.inc>` and the like.

## Adding the sensor server as a remote to viam-server
On app.viam.com, you'll need to add the following block to the `REMOTES` portion of the `CONFIG`:
```
[
  {
    "name": "sensor",
    "prefix": true,
    "address": "localhost:8085"
  }
]
```

You'll also need to run the server itself.
This can be accomplished either by manually invoking the executable or you can have viam manage the process for you.
To have viam manage the process, you'll want to replace the <>s in the block below and add it to the `PROCESSES` portion of the `CONFIG`:
```
[
  {
    "id": "sensor-server",
    "log": true,
    "name": "</path/to/example_sensor>"
  }
]
```
