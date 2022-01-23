#pragma once

#include <string>
#include <vector>

#define CL_TARGET_OPENCL_VERSION 120
#define __CL_ENABLE_EXCEPTIONS
#ifdef defined(__APPLE__) || defined(MAXOS)
	#include <OpcnCL/cl.hpp>
#else
	#include <CL/cl.hpp>
#endif

namespace ocle {

	/**
	 * @brief Main class of library
	 */
	class Base {

	private:
		const std::string kernel_file_name = "../ocle.cl";
		std::string kernel_source;

	protected:
		size_t global_work_size;
		size_t local_work_size;
		cl::Device device;
		cl::Context context;
		cl::Program program;
		cl::Kernel kernel;
		cl::CommandQueue queue;
		cl::Event event;
		cl::Buffer key_buffer;
		cl::Buffer plaintext_buffer;

		std::vector<uint8_t> *plaintext;
		std::vector<uint8_t> key;

		void readKernelCode(const std::string &file_name);
		virtual void run();

		virtual void buildKernel(const std::string& kernel_name) = 0;

	public:
		explicit Base(const cl::Device& cl_device);

		virtual std::vector<uint8_t>* encrypt(std::vector<uint8_t>& plaintext) = 0;
		virtual std::vector<uint8_t>* decrypt(std::vector<uint8_t>& plaintext) = 0;

	};

}
