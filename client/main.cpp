#include <thread>
#include <vector>
#include <iostream>
#include <boost/bind.hpp>
#include <boost/asio.hpp>

#include <fstream>

#include "include/client.hpp"

int main(int argc, char* argv[]) {
	if (argc != 5) {
		std::cerr << "\t To run Client chat software use command:" << std::endl;
		std::cerr << "\t\t chat [<string> nickname] [Server ip address] [<unsigned int> port] [<string> password]" << std::endl;
		return EXIT_FAILURE;
	}

	if (strlen(argv[4]) != 16) {
		std::cerr << "\t Password must be 16 characters long" << std::endl;
		return EXIT_FAILURE;
	}

	try {
		cl::Platform platform = cl::Platform::getDefault();
		std::vector<cl::Device> devices;
		platform.getDevices(CL_DEVICE_TYPE_GPU, &devices);
		cl::Device device = devices[0];

		std::vector<uint8_t> key(16);
		boost::asio::io_service io_service;
		std::array<char, NICK_MAX> nickname;
		boost::asio::ip::tcp::resolver resolver(io_service);
		boost::asio::ip::tcp::resolver::query query(argv[2], argv[3]);
		boost::asio::ip::tcp::resolver::iterator iterator = resolver.resolve(query);
		std::vector<uint8_t> iv = {
				0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
		};

		strcpy(nickname.data(), argv[1]);
		for (int i=0; i<16; i++)
			key[i] = argv[4][i];

		Client client(nickname, io_service, iterator, device, key, iv);
		std::thread thread(boost::bind(&boost::asio::io_service::run, &io_service));
		std::array<char, FRAME_SIZE> msg;

		while (true) {
			memset(msg.data(), '\0', msg.size());
			if (!std::cin.getline(msg.data(), FRAME_SIZE - SPACE - NICK_MAX))
				std::cin.clear();

			std::vector<uint8_t> data(msg.begin(), msg.begin()+512);
			msg.fill('\0');

			ocle::AES aes(device, key, ocle::AES::MOD_CBC, &iv);
			auto *out = aes.encrypt(data);

//      	std::ofstream file("in.bin", std::ios::binary);
//      	file.upload(reinterpret_cast<const char*>(out->data()), out->size());
//      	file.close();

			strcpy(&msg[0], "<data>");
			std::copy(out->begin(), out->end(), &msg[6]);

			client.upload(msg);
		}
	} catch (std::exception& e) {
		std::cerr << "Exception: " << e.what() << "\n";
	}

	return 0;
}

