#include <fstream>

#include "../include/Error.hpp"
#include "../include/Base.hpp"

namespace ocle {

/*************************** constructor **************************/

	Base::Base(const cl::Device& cl_device) :
		device(cl_device)
	{
		global_work_size = device.getInfo<CL_DEVICE_MAX_WORK_GROUP_SIZE>();
		context = cl::Context({ device });
		queue = cl::CommandQueue(context, device);  // TODO: czy kolejność ma znaczenie?
		readKernelCode(kernel_file_name);
		program = cl::Program(context, kernel_source);
	}

/***************************** private ****************************/

	void Base::readKernelCode(const std::string &file_name) {

		std::string line;
		std::ifstream kernel_file(file_name);

		if(!kernel_file)
			throw Error("No kernel file found");

		while(std::getline(kernel_file, line))
			kernel_source += line + '\n';

		kernel_file.close();
	}

	void Base::run() {
		key_buffer = cl::Buffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
								key.size() * sizeof(uint8_t), key.data());
		plaintext_buffer = cl::Buffer(context, CL_MEM_READ_WRITE,plaintext->size() * sizeof(uint8_t));

		queue.enqueueWriteBuffer(plaintext_buffer, CL_TRUE, 0,
		                         plaintext->size() * sizeof(uint8_t), plaintext->data());

		unsigned int data_length = plaintext->size();

		kernel.setArg(0, key_buffer);
		kernel.setArg(1, plaintext_buffer);
		kernel.setArg(2, sizeof(unsigned int), &data_length);
	}

}
