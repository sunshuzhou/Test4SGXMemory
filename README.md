# Test4MemoryCpy


## Enclave can see and operate data in the main memory

In `test.edl`, we define a trusted function:

    public int ecall_enclave_visit_outside_memory([user_check]uint8_t *data, size_t len);

The `user_check` will discourage the memory copy operation from enclave to app (specified by `out`), or from app to enclave (specified by `in`). So we need to manually check whether the `data` in the function is inside or outside enclave. Here is the code of it.

    int ecall_enclave_visit_outside_memory(uint8_t *data, size_t len) {
      if (sgx_is_outside_enclave(data, len)) {
        // Since it is in the main memory, we can assume it's unsafe.
        // Simple put a sequence to it.
        for (int i = 0; i < len; i++) {
          data[i] = i;
        }
        return 1;
      }
      return 0;
    }

We are in enclave and we can operate the main memory data. Isn't that useful? We do not need to transfer plaintext from app to enclave by using `in`, if we only want to encrypt it inside the enclave. The `in` parameter will cause the MEE to allow memory in enclave and encrypt *plaintext ouside* to *plaintext inside*. But we DO need to put the cipher encryption/decryption temporary variables inside the enclave memory (EPC), since it may reveal secret information about the **key**.
