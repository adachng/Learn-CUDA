#ifndef LEARN_CUDA__LIB_MYCUDADEVPROP_CUH
#define LEARN_CUDA__LIB_MYCUDADEVPROP_CUH

#include <string>

#ifdef __cplusplus
extern "C"
{
#endif

struct MyCudaDevPropFactory;
struct MyCudaDevProp;

struct MyCudaDevPropFactory* MyCudaDevPropFactory_new(void);

void MyCudaDevPropFactory_free(struct MyCudaDevPropFactor* const self_p);

struct MyCudaDevProp*
    MyCudaDevPropFactory_create(struct MyCudaDevPropFactor* const self_p);

#define SHARED_PROP_DECL_LIST \
    X(driver_ver)             \
    X(runtime_ver)            \
    X(device_count)           \
    X(device)

#define X(name)                                                              \
    int MyCudaDevPropFactory_get_##name(                                     \
        const struct MyCudaDevPropFactory* const self_p);                    \
    int  MyCudaDevProp_get_##name(const struct MyCudaDevProp* const self_p); \
    bool MyCudaDevPropFactory_is_##name##_error(                             \
        const struct MyCudaDevPropFactory* const self_p);                    \
    bool MyCudaDevProp_is_##name##_error(                                    \
        const struct MyCudaDevProp* const self_p);                           \
    std::string MyCudaDevPropFactory_get_##name##_error(                     \
        const struct MyCudaDevPropFactory* const self_p);                    \
    std::string MyCudaDevProp_get_##name##_error(                            \
        const struct MyCudaDevProp* const self_p);
#undef X

#undef SHARED_PROP_DECL_LIST

#ifdef __cplusplus
}
#endif

#endif // LEARN_CUDA__LIB_MYCUDADEVPROP_CUH
