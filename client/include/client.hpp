#pragma once

#include <array>
#include <deque>
#include <deque>
#include <boost/asio.hpp>
#include <boost/bind.hpp>

#include "../../config.hpp"
#include "../ocle/include/ocle.hpp"

class Client {
private:
	std::deque<std::array<char, FRAME_SIZE>> upload_msgs;
	std::array<char, FRAME_SIZE> download_msg;
	std::array<char, NICK_MAX> nickname2;
	boost::asio::io_service& io_service;
	boost::asio::ip::tcp::socket socket;
	std::vector<uint8_t> key;
	std::vector<uint8_t> iv;
	cl::Device device;

	void connection(const boost::system::error_code &code);
	void download_handle(const boost::system::error_code &code);
	void upload_ml(std::array<char, FRAME_SIZE> msg);
	void upload_handle(const boost::system::error_code &code);
	void close_ml();

public:
	Client(const std::array<char, NICK_MAX> &nickname,
	       boost::asio::io_service &io_service,
	       boost::asio::ip::tcp::resolver::iterator endpoint_iterator,
	       cl::Device &device,
	       const std::vector<uint8_t> &key,
	       const std::vector<uint8_t> &iv) :
	       io_service(io_service), socket(io_service), device(device), key(key), iv(iv) {
		strcpy(nickname2.data(), nickname.data());
		memset(download_msg.data(), '\0', FRAME_SIZE);

		boost::asio::async_connect(socket, endpoint_iterator,
								   boost::bind(&Client::connection, this, _1));
	}

	void upload(const std::array<char, FRAME_SIZE> &msg);
};