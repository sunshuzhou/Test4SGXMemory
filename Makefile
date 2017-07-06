SGX_SDK ?= /opt/intel/sgxsdk
SGX_EDGER8R := $(SGX_SDK)/bin/x64/sgx_edger8r
SGX_SIGN := $(SGX_SDK)/bin/x64/sgx_sign
SGX_LIB_PATH := $(SGX_SDK)/lib64

SIGNER_KEY_FILE := /home/sgx/certificate/private_key.pem
REENCRYPT_CONF_FILE := reencrypt/reencrypt.config.xml

TRTS_LIB := sgx_trts
URTS_LIB := sgx_urts
CRYPTO_LIB := sgx_tcrypto
SERVICE_LIB := sgx_tservice

DEST := build

#  -----------------------------------------------------
#  Build All
#  -----------------------------------------------------

all: $(DEST)/test.signed.so $(DEST)/app

#  -----------------------------------------------------
#  Build App
#  -----------------------------------------------------

APP_INC := -I$(SGX_SDK)/include -Ienclave -Iutils
APP_C_FLAGS := $(APP_INC)
APP_CPP_FLAGS := $(APP_INC) -std=c++11
APP_LINK_FLAGS := -L$(SGX_LIB_PATH) -l$(URTS_LIB) -pthread

APP_ENCLAVE_SRC := app/test_u.c app/test_u.h
APP_ENCLAVE_OBJ := app/test_u.o
APP_SRC = app/main.cpp utils/sgx-utils.cpp
APP_OBJ = $(patsubst %.cpp,%.o,$(APP_SRC)) $(APP_ENCLAVE_OBJ)

$(DEST)/app: $(APP_OBJ) $(DEST)/test.signed.so 
	@echo $< "=>" $@
	@$(CXX) -o $@ $(APP_OBJ) $(APP_CPP_FLAGS) $(APP_INC) $(APP_LINK_FLAGS)

app/main.o: app/main.cpp app/test_u.h utils/sgx-utils.h
	@echo $^ "=>" $@
	@$(CXX) -o $@ -c $< $(APP_CPP_FLAGS) $(APP_INC) 

$(APP_ENCLAVE_OBJ): $(APP_ENCLAVE_SRC)
	@echo $^ "=>" $@
	@$(CC) -o $@ -c $< $(ENCLAVE_C_FLAGS) 

$(APP_ENCLAVE_SRC): enclave/test.edl
	@echo $^ "=>" $(APP_ENCLAVE_SRC)
	@$(SGX_EDGER8R) $^ --untrusted --untrusted-dir app
	

#  -----------------------------------------------------
#  Build Utils
#  -----------------------------------------------------

utils/sgx-utils.o: utils/sgx-utils.cpp utils/sgx-utils.h
	@echo $^ "=>" $@
	@$(CXX) -o $@ -c $< $(APP_CPP_FLAGS) $(APP_INC) 

#  -----------------------------------------------------
#  Build Enclave
#  -----------------------------------------------------

ENCLAVE_INC := -I$(SGX_SDK)/include -I$(SGX_SDK)/include/tlibc -I$(SGX_SDK)/include/stlport 
ENCLAVE_C_FLAGS := $(ENCLAVE_INC) -nostdinc -fvisibility=hidden -fpie -fstack-protector
ENCLAVE_LINK_FLAGS := -Wl,--no-undefined -L$(SGX_LIB_PATH) \
	-nostdlib -nodefaultlibs -nostartfiles \
	-Wl,--whole-archive -l$(TRTS_LIB) -Wl,--no-whole-archive \
	-Wl,--start-group -lsgx_tstdc -lsgx_tstdcxx -l$(CRYPTO_LIB) \
	-l$(SERVICE_LIB) -Wl,--end-group  \
	-Wl,-Bstatic -Wl,-Bsymbolic -Wl,--no-undefined \
	-Wl,-pie,-eenclave_entry -Wl,--export-dynamic \
	-Wl,--defsym,__ImageBase=0 \
	-Wl,--version-script=enclave/test.lds

ENCLAVE_TRUSTED_SRC := enclave/test_t.c enclave/test_t.h
ENCLAVE_SRC := $(ENCLAVE_TRUSTED_SRC) enclave/test.c
ENCLAVE_OBJ := $(patsubst %.c, %.o, $(ENCLAVE_SRC))

$(DEST)/test.signed.so: $(DEST)/test.so enclave/test.config.xml
	@mkdir -p build
	@echo $< "=>" $@
	@$(SGX_SIGN) sign -key ${SIGNER_KEY_FILE} -enclave $< -out $@ -config enclave/test.config.xml

$(DEST)/test.so: $(ENCLAVE_OBJ)
	@mkdir -p build
	@echo $^ "=>" $@
	@$(CC) -o $@ $^ $(ENCLAVE_INC) $(ENCLAVE_LINK_FLAGS)

enclave/%.o: enclave/%.c
	@echo $^ "=>" $@
	@$(CC) -o $@ -c $(ENCLAVE_C_FLAGS) $<

$(ENCLAVE_TRUSTED_SRC): enclave/test.edl
	@echo $^ "=>" $(ENCLAVE_TRUSTED_SRC)
	@$(SGX_EDGER8R) $^ --trusted --trusted-dir enclave


clean:
	@rm -f build/*
	@rm -f app/*.o app/test_u.*
	@rm -rf enclave/*.o enclave/test_t.*
	@rm -f app/*.o
