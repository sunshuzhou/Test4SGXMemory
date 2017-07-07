#ifndef TEST_T_H__
#define TEST_T_H__

#include <stdint.h>
#include <wchar.h>
#include <stddef.h>
#include "sgx_edger8r.h" /* for sgx_ocall etc. */


#include <stdlib.h> /* for size_t */

#define SGX_CAST(type, item) ((type)(item))

#ifdef __cplusplus
extern "C" {
#endif


int ecall_enclave_visit_outside_memory(uint8_t* data, size_t len);


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif
