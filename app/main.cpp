#include <iostream>

#include <cstdio>
#include <cstring>

#include "sgx_urts.h"
#include "sgx_trts.h"

#include "test_u.h"
#include "sgx-utils.h"

using namespace std;

int main(int argc, char **argv) {

  sgx_launch_token_t launch_token = { 0 };
  sgx_enclave_id_t eid;
  int updated;

  sgx_status_t status;

  
  status = sgx_create_enclave("test.signed.so", SGX_DEBUG_FLAG, &launch_token, &updated, &eid, nullptr);
  if (SGX_SUCCESS == status) {
    cout << "SUCCESS : sgx_create_enclave" << endl;
  } else {
    print_error_message(status);
  }

  int ret;
  uint8_t data[128];
  memset(data, 0, 128);
  if (SGX_SUCCESS == ecall_enclave_visit_outside_memory(eid, &ret, data, 128) && 1 == ret) {
    for (int i = 0; i < 128; i++) if (i != data[i]) {
      cout << "ERROR : ecall_enclave_visit_outside_memory" << endl;
      goto ERROR;
    }
    cout << "SUCCESS : ecall_enclave_visit_outside_memory" << endl;
  }

ERROR:
  return 0;
}
