#include <iostream>
#include <boost/asio.hpp>
#include <boost/bind.hpp>

#include "../include/client.hpp"

#include <fstream>

/* Public */

void Client::upload(const std::array<char, FRAME_SIZE> &msg) {
	io_service.post(boost::bind(&Client::upload_ml, this, msg));
}

/* Private */

void Client::connection(const boost::system::error_code &code) {
	if (!code)
		boost::asio::async_write(socket,
		                         boost::asio::buffer(nickname2, nickname2.size()),
		                         boost::bind(&Client::download_handle, this, _1));
}

void Client::download_handle(const boost::system::error_code &code) {
	int position = std::string(download_msg.begin(), download_msg.end()).find("<data>");
	if (position > 0 || position < 40) {
		position += 6;
		std::vector<uint8_t> data(download_msg.begin() + position, download_msg.begin() + position + 512);
		ocle::AES aes(device, key, ocle::AES::MOD_CBC, &iv);

//  	std::ofstream file("out.bin", std::ios::binary);
//  	file.upload(reinterpret_cast<const char*>(data.data()), data.size());
//  	file.close();

		auto *out = aes.decrypt(data);

//  	std::ofstream file2("out2.bin", std::ios::binary);
//  	file2.upload(reinterpret_cast<const char*>(out->data()), out->size());
//  	file2.close();

		for (int i=position-6; i < download_msg.size(); i++)
			download_msg[i] = ' ';
		std::copy(out->begin(), out->end(), &download_msg.data()[position]);
		std::cout << download_msg.data() << std::endl;

		download_msg.fill('\0');
	}
	if (!code)
		boost::asio::async_read(socket,
		                        boost::asio::buffer(download_msg, download_msg.size()),
		                        boost::bind(&Client::download_handle, this, _1));
	else
		close_ml();
}

void Client::close_ml() { socket.close(); }

void Client::upload_handle(const boost::system::error_code &code) {
	if (!code) {
		upload_msgs.pop_front();
		if (!upload_msgs.empty())
			boost::asio::async_write(socket,
			                         boost::asio::buffer(upload_msgs.front(),
			                                             upload_msgs.front().size()),
			                         boost::bind(&Client::upload_handle, this, _1));
	}
}

void Client::upload_ml(std::array<char, FRAME_SIZE> msg) {
	bool write_in_progress = !upload_msgs.empty();
	upload_msgs.push_back(msg);
	if (!write_in_progress)
		boost::asio::async_write(socket,
		                         boost::asio::buffer(upload_msgs.front(),
		                                             upload_msgs.front().size()),
		                         boost::bind(&Client::upload_handle, this, _1));
}