#include "test_t.h"

#include "sgx_trts.h" /* for sgx_ocalloc, sgx_is_outside_enclave */

#include <errno.h>
#include <string.h> /* for memcpy etc */
#include <stdlib.h> /* for malloc/free etc */

#define CHECK_REF_POINTER(ptr, siz) do {	\
	if (!(ptr) || ! sgx_is_outside_enclave((ptr), (siz)))	\
		return SGX_ERROR_INVALID_PARAMETER;\
} while (0)

#define CHECK_UNIQUE_POINTER(ptr, siz) do {	\
	if ((ptr) && ! sgx_is_outside_enclave((ptr), (siz)))	\
		return SGX_ERROR_INVALID_PARAMETER;\
} while (0)


typedef struct ms_ecall_enclave_visit_outside_memory_t {
	int ms_retval;
	uint8_t* ms_data;
	size_t ms_len;
} ms_ecall_enclave_visit_outside_memory_t;

static sgx_status_t SGX_CDECL sgx_ecall_enclave_visit_outside_memory(void* pms)
{
	ms_ecall_enclave_visit_outside_memory_t* ms = SGX_CAST(ms_ecall_enclave_visit_outside_memory_t*, pms);
	sgx_status_t status = SGX_SUCCESS;
	uint8_t* _tmp_data = ms->ms_data;

	CHECK_REF_POINTER(pms, sizeof(ms_ecall_enclave_visit_outside_memory_t));

	ms->ms_retval = ecall_enclave_visit_outside_memory(_tmp_data, ms->ms_len);


	return status;
}

SGX_EXTERNC const struct {
	size_t nr_ecall;
	struct {void* ecall_addr; uint8_t is_priv;} ecall_table[1];
} g_ecall_table = {
	1,
	{
		{(void*)(uintptr_t)sgx_ecall_enclave_visit_outside_memory, 0},
	}
};

SGX_EXTERNC const struct {
	size_t nr_ocall;
} g_dyn_entry_table = {
	0,
};


