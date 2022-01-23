#include "../include/Error.hpp"
#include "../include/AES.hpp"

typedef uint8_t state_t[4][4];

namespace ocle {

/*************************** constructor **************************/

	AES::AES(const cl::Device &cl_device,
			 const std::vector<uint8_t>& key,
			 MOD mod,
			 const std::vector<uint8_t>* iv) :
		Base(cl_device)
	{
		if((key.size() != 16) && (key.size() != 24) && (key.size() != 32))
			throw Error("Invalid key size");

		if((iv != nullptr) && (iv->size() != 16))
			throw Error("Invalid iv size");

		if(mod > 3 && iv != nullptr)
			throw Error("This method does not require an initialization vector");
		else if (mod < 4)
			this->iv.assign(iv->begin(), iv->end());

		this->key = key;
		method = mod;
	}

/***************************** private ****************************/

	void AES::buildKernel(const std::string &kernel_name) {
		std::string definition = key.size() == 16 ? "-D AES128" : key.size() == 24 ? "-D AES192" : "-D AES256";
		program.build(definition.c_str());
		kernel = cl::Kernel(program, kernel_name.c_str());
	}

	void AES::run() {
		Base::run();

		size_t size = plaintext->size()/16 <= global_work_size ? plaintext->size()/16 : global_work_size;

		if(method < 4) {
			uint32_t size2 = size;

			iv_buffer = cl::Buffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
								   iv.size() * sizeof(uint8_t), iv.data());

			kernel.setArg(3, iv_buffer);
			kernel.setArg(4, sizeof(uint8_t) * 16, NULL);
			kernel.setArg(6, sizeof(size2), &size2);

			for(uint32_t i=0; i<size; i++) {
				kernel.setArg(5, sizeof(i), &i);
				queue.enqueueNDRangeKernel(kernel, cl::NullRange, cl::NDRange(1), cl::NullRange, NULL, &event);
				event.wait();
			}

		} else {
			queue.enqueueNDRangeKernel(kernel, cl::NullRange, cl::NDRange(size), cl::NullRange, NULL, &event);
			event.wait();
		}
	}

/***************************** public *****************************/

	std::vector<uint8_t>* AES::encrypt(std::vector<uint8_t>& plaintext)
	{
		if(plaintext.size() % key.size() != 0)
			throw Error("Invalid plaintext size");

		size_t kernel_number = method * 2;
		buildKernel(kernel_names[kernel_number]);
		this->plaintext = &plaintext;
		run();

		auto *out = new std::vector<uint8_t>(plaintext.size());
		queue.enqueueReadBuffer(plaintext_buffer, true, 0,
								plaintext.size() * sizeof(uint8_t), out->data());
		return out;
	}

	std::vector<uint8_t>* AES::decrypt(std::vector<uint8_t>& plaintext) {
		if(plaintext.size() % key.size() != 0)
			throw Error("Invalid plaintext size");

		size_t kernel_number = method * 2 + 1;
		buildKernel(kernel_names[kernel_number]);
		this->plaintext = &plaintext;
		run();

		auto *out = new std::vector<uint8_t>(plaintext.size());
		queue.enqueueReadBuffer(plaintext_buffer, true, 0,
		                        plaintext.size() * sizeof(uint8_t), out->data());
		return out;
	}

}
