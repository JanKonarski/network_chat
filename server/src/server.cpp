#include <boost/bind.hpp>

#include "../include/server.hpp"

/* Private */
void Server::run() {
	std::shared_ptr<InRoom> new_participant(new InRoom(io_service, strand, room));
	acceptor.async_accept(new_participant->socket(),
	                      strand.wrap(boost::bind(&Server::onAccept, this,
	                                              new_participant, _1)
	                      )
	);
}

void Server::onAccept(std::shared_ptr<InRoom> new_participant, const boost::system::error_code &error) {
	if (!error)
		new_participant->run();
	run();
}