#include <cuda_device_runtime_api.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>

#include <driver_types.h>
#include <iostream>

__global__ void helloDevice(void)
{
    // See https://docs.nvidia.com/cuda/cuda-programming-guide
    const size_t threadId =
        size_t{threadIdx.x} + size_t{blockIdx.x} * size_t{blockDim.x};
    printf("Hello, World! I am thread %llu\n",
           static_cast<unsigned long long>(threadId));
}

__host__ int main()
{
    // See the driver and runtime versions:
    {
        int driverVer;
        int runtimeVer;

        const cudaError_t getDriverErr{cudaDriverGetVersion(&driverVer)};
        const cudaError_t getRuntimeErr{cudaRuntimeGetVersion(&runtimeVer)};

        auto printErr = [](std::ostream&     ostr,
                           const cudaError_t driverGetVerErr,
                           const cudaError_t runtimeGetVerErr)
        {
            ostr << "cudeRuntimeGetVersion() returned "
                 << cudaGetErrorName(driverGetVerErr) << std::endl;
            ostr << "cudeRuntimeGetVersion() returned "
                 << cudaGetErrorName(runtimeGetVerErr) << std::endl;
        };

        if (getDriverErr == cudaSuccess && getRuntimeErr == cudaSuccess)
        {
            // printErr(std::cout, getDriverErr, getRuntimeErr);

            std::cout << "CUDA Runtime version " << runtimeVer / 1000 << "."
                      << runtimeVer / 10 % 100 << std::endl;
            std::cout << "CUDA Driver version " << driverVer / 1000 << "."
                      << driverVer / 10 % 100 << std::endl;
        }
        else
        {
            printErr(std::cerr, getDriverErr, getRuntimeErr);
            return 1;
        }
    }

    // See the device count:
    int deviceCount;
    {
        const cudaError_t err{cudaGetDeviceCount(&deviceCount)};

        if (err == cudaSuccess)
        {
            std::cout << "deviceCount = " << deviceCount << std::endl;
        }
        else
        {
            std::cerr << "cudaGetDeviceCount() error: " << cudaGetErrorName(err)
                      << std::endl;
            return 1;
        }
    }

    // See the current device:
    {
        int currentDevice;

        const cudaError_t err{cudaGetDevice(&currentDevice)};

        if (err == cudaSuccess)
        {
            std::cout << "currentDevice = " << currentDevice << std::endl;
        }
        else
        {
            std::cerr << "getCurrentDevErr() error: " << cudaGetErrorName(err)
                      << std::endl;
            return 1;
        }
    }

    // See the properties of all devices:
    {
        for (int i = 0; i < deviceCount; i++)
        {
            cudaDeviceProp    prop;
            const cudaError_t err{cudaGetDeviceProperties(&prop, i)};

            if (err != cudaSuccess)
            {
                std::cerr << "cudaGetDeviceProperties() error: "
                          << cudaGetErrorName(err) << " on device " << i
                          << std::endl;
                return 1;
            }

            std::cout << "Device " << i << ":" << std::endl;

            // Print properties:
#define PROP_MEMBER_LIST  \
    X(name)               \
    X(totalGlobalMem)     \
    X(sharedMemPerBlock)  \
    X(warpSize)           \
    X(maxThreadsPerBlock) \
    X(major)              \
    X(minor)

#define X(member)                                                     \
    std::cout << "\tprop." #member " = " << prop.member << std::endl;
            PROP_MEMBER_LIST
#undef X

#undef PROP_MEMBER_LIST
        }
    }

    helloDevice<<<1, 10>>>();
    const cudaError_t err{cudaDeviceSynchronize()};
    if (err != cudaSuccess)
    {
        std::cout << "cudaDeviceSynchronize() error: " << cudaGetErrorName(err)
                  << std::endl;
    }

    return 0;
}
