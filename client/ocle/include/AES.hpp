#pragma once

#include "Base.hpp"

namespace ocle {

	class AES : public Base {

		const std::vector<std::string> kernel_names = {
				"aes_cbc_encrypt",
				"aes_cbc_decrypt",
				"aes_cfb_encrypt",
				"aes_cfb_decrypt",
				"aes_ofb",
				"aes_ofb",
				"aes_ctr",
				"aes_ctr",
				"aes_ecb_encrypt",
				"aes_ecb_decrypt"
		};

	public:
		enum MOD {
			MOD_CBC,
			MOD_CFB,
			MOD_OFB,
			MOD_CTR,
			MOD_ECB
		};

	private:
		std::vector<uint8_t> iv;
		MOD method;

		const std::string encrypt_kernel_name = "aes_encrypt";
		const std::string decrypt_kernel_name = "aes_decrypt";

		void buildKernel(const std::string& kernel_name) override;
		void run() override;

	protected:
		cl::Buffer iv_buffer;

	public:
		explicit AES(const cl::Device& cl_device,
					 const std::vector<uint8_t>& key,
					 MOD mod,
					 const std::vector<uint8_t>* iv = nullptr);

		std::vector<uint8_t>* encrypt(std::vector<uint8_t>& plaintext) override;
		std::vector<uint8_t>* decrypt(std::vector<uint8_t>& plaintext) override;

	};

}
