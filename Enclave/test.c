#include "test_t.h"
#include "sgx_trts.h"

int ecall_enclave_visit_outside_memory(uint8_t *data, size_t len) {
  if (sgx_is_outside_enclave(data, len)) {
    // Since it is in the main memory, we can consider it as unsafe.
    // Simple put a sequence to it.
    for (int i = 0; i < len; i++) {
      data[i] = i;
    }
    return 1;
  }
  return 0;
}
