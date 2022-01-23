#pragma once

#include <boost/asio.hpp>

#include "room.hpp"
#include "user.hpp"

class InRoom : public::User,
               public::std::enable_shared_from_this<InRoom> {
private:
	std::deque<std::array<char, FRAME_SIZE>> upload_msgs;
	boost::asio::io_service::strand &strand;
	std::array<char, FRAME_SIZE> download_msg;
	boost::asio::ip::tcp::socket socket_boost;
	std::array<char, NICK_MAX> nicks;
	Room &room;

	void nick_handle(const boost::system::error_code &error);
	void download_handle(const boost::system::error_code &error);
	void upload_handle(const boost::system::error_code &error);

public:
	InRoom(boost::asio::io_service &io_service,
	       boost::asio::io_service::strand &strand, Room &room)
			: socket_boost(io_service), strand(strand), room(room) {}

	boost::asio::ip::tcp::socket &socket();
	void run();
	void action(std::array<char, FRAME_SIZE> &msg);
};