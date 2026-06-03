#include "MyCudaDevProp.cuh"

#include <cuda_runtime.h>

#include <assert.h>
#include <stddef.h>
#include <stdlib.h>

struct cudaDevPropShared
{
    size_t refCount;

    int         driverVer;
    cudaError_t getDriverVerErr;

    int         runtimeVer;
    cudaError_t getRuntimeVerErr;

    int         deviceCount;
    cudaError_t getDeviceCountErr;

    int         currentDevice;
    cudaError_t getDeviceErr;
};

struct MyCudaDevPropFactory
{
    struct cudaDevPropShared* sharedProp_p;
};

struct MyCudaDevProp
{
    cudaDeviceProp            prop;
    struct cudaDevPropShared* sharedProp_p;
    cudaError_t               error;
};

static struct cudaDevPropShared* cudaDevPropShared_new(void)
{
    struct cudaDevPropShared* const ret_p =
        (struct cudaDevPropShared*)malloc(sizeof(struct cudaDevPropShared));

    if (ret_p == NULL)
    {
        return NULL;
    }

    *ret_p = (struct cudaDevPropShared){
        .refCount = 1,
    };

    ret_p->getDriverVerErr   = cudaDriverGetVersion(&ret_p->driverVer);
    ret_p->getRuntimeVerErr  = cudaRuntimeGetVersion(&ret_p->runtimeVer);
    ret_p->getDeviceCountErr = cudaGetDeviceCount(&ret_p->deviceCount);
    ret_p->getDeviceErr      = cudaGetDevice(&ret_p->currentDevice);

    return ret_p;
}

static struct cudaDevPropShared*
    cudaDevPropShared_dec_ref(struct cudaDevPropShared* const self_p)
{
    if (self_p == NULL)
    {
        return NULL;
    }

    assert(self_p->refCount > 0);
    self_p->refCount--;

    if (self_p->refCount <= 0)
    {
        free(self_p);
        return NULL;
    }

    return self_p;
}

static struct cudaDevPropShared*
    cudaDevPropShared_inc_ref(struct cudaDevPropShared* const self_p)
{
    if (self_p == NULL)
    {
        return NULL;
    }

    self_p->refCount++;
    return self_p;
}

struct MyCudaDevPropFactory* MyCudaDevPropFactory_new(void)
{
    struct MyCudaDevPropFactory* const ret_p =
        (struct MyCudaDevPropFactory*)malloc(
            sizeof(struct MyCudaDevPropFactory));
    if (ret_p == NULL)
    {
        return NULL;
    }

    ret_p->sharedProp_p = cudaDevPropShared_new();
    if (ret_p->sharedProp_p == NULL)
    {
        free(ret_p);
        return NULL;
    }

    return ret_p;
}

void MyCudaDevPropFactory_free(struct MyCudaDevPropFactory* const self_p)
{
    if (self_p == NULL)
    {
        return;
    }

    self_p->sharedProp_p->refCount--;
    free(self_p);
}

struct MyCudaDevProp*
    MyCudaDevPropFactory_create(struct MyCudaDevPropFactory* const self_p,
                                const int                          device)
{
    if (self_p == NULL)
    {
        return NULL;
    }

    struct MyCudaDevProp* const ret_p =
        (struct MyCudaDevProp*)malloc(sizeof(struct MyCudaDevProp));
    if (ret_p == NULL)
    {
        return NULL;
    }

    ret_p->error        = cudaGetDeviceProperties(&ret_p->prop, device);
    ret_p->sharedProp_p = cudaDevPropShared_inc_ref(self_p->sharedProp_p);
    return ret_p;
}
