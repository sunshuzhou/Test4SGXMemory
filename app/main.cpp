#include <iostream>

#include "sgx_urts.h"

#include "test_u.h"
#include "sgx-utils.h"

using namespace std;

int main(int argc, char **argv) {

  sgx_launch_token_t launch_token = { 0 };
  sgx_enclave_id_t eid;
  int updated;

  sgx_status_t status;

  
  status = sgx_create_enclave("build/test.signed.so", SGX_DEBUG_FLAG, &launch_token, &updated, &eid, nullptr);
  if (SGX_SUCCESS == status) {
    cout << "sgx_create_enclave success." << endl;
  } else {
    print_error_message(status);
  }

  int ret;
  test_function1(eid, &ret, 10);

  cout << ret << endl;


  cout << "test" << endl;

  return 0;
}
