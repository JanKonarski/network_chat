#include <memory>
#include <boost/bind.hpp>

#include "../include/inroom.hpp"

/* private */
void InRoom::upload_handle(const boost::system::error_code &error) {
	if (!error) {
		upload_msgs.pop_front();

		if (!upload_msgs.empty())
			boost::asio::async_write(socket_boost,
			                         boost::asio::buffer(upload_msgs.front(),
			                                             upload_msgs.front().size()),
			                         strand.wrap(boost::bind(&InRoom::upload_handle,
			                                                 shared_from_this(), _1)
			                         )
			);
	}
	else
		room.leave(shared_from_this());
}

void InRoom::download_handle(const boost::system::error_code &error) {
	if (!error) {
		room.broadcast(download_msg, shared_from_this());

		boost::asio::async_read(socket_boost,
		                        boost::asio::buffer(download_msg, download_msg.size()),
		                        strand.wrap(boost::bind(&InRoom::download_handle,
		                                                shared_from_this(), _1)
		                        )
		);
	}
	else {
		room.leave(shared_from_this());
	}
}

void InRoom::nick_handle(const boost::system::error_code &error) {
	if (strlen(nicks.data()) <= NICK_MAX - 2) {
		strcat(nicks.data(), ": ");
	}
	else {
		nicks[NICK_MAX - 2] = ':';
		nicks[NICK_MAX - 1] = ' ';
	}

	room.enter(shared_from_this(), std::string(nicks.data()));

	boost::asio::async_read(socket_boost,
	                        boost::asio::buffer(download_msg, download_msg.size()),
	                        strand.wrap(boost::bind(&InRoom::download_handle,
	                                                shared_from_this(), _1)
	                        )
	);
}

/* public */
void InRoom::action(std::array<char, FRAME_SIZE> &msg) {
	bool write_in_progress = !upload_msgs.empty();
	upload_msgs.push_back(msg);
	if (!write_in_progress)
		boost::asio::async_write(socket_boost,
		                         boost::asio::buffer(upload_msgs.front(),
		                                             upload_msgs.front().size()),
		                         strand.wrap(boost::bind(&InRoom::upload_handle,
		                                                 shared_from_this(), _1)
		                         )
		);
}

boost::asio::ip::tcp::socket& InRoom::socket() { return socket_boost; }

void InRoom::run() {
	boost::asio::async_read(socket_boost, boost::asio::buffer(nicks, nicks.size()),
	                        strand.wrap(boost::bind(&InRoom::nick_handle,
	                                                shared_from_this(), _1)
	                        )
	);
}