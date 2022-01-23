#pragma once

#include <boost/asio.hpp>

#include "inroom.hpp"

class Server {
private:
	boost::asio::io_service &io_service;
	boost::asio::io_service::strand &strand;
	boost::asio::ip::tcp::acceptor acceptor;
	Room room;

	void run();
	void onAccept(std::shared_ptr<InRoom> new_participant, const boost::system::error_code& error);

public:
	Server(boost::asio::io_service &io_service,
	       boost::asio::io_service::strand &strand,
	       const boost::asio::ip::tcp::endpoint &endpoint)
	       : io_service(io_service), strand(strand), acceptor(io_service, endpoint) {

		run();
	}
};