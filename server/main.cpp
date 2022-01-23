#include <iostream>
#include <list>
#include <boost/thread/thread.hpp>

#include "include/server.hpp"
#include "include/functions.hpp"

int main(int argc, char* argv[]) {
	if (argc < 2) {
		std::cerr << "\t To run Server chat software use commend:" << std::endl;
		std::cerr << "\t Server [<unsigned int> port]..." << std::endl;
		return EXIT_FAILURE;
	}

    try {
        std::shared_ptr<boost::asio::io_service> io_service(new boost::asio::io_service);
        boost::shared_ptr<boost::asio::io_service::work> work(new boost::asio::io_service::work(*io_service));
        boost::shared_ptr<boost::asio::io_service::strand> strand(new boost::asio::io_service::strand(*io_service));

        std::cout << dateTime() << "Server is starting" << std::endl;

        std::list<std::shared_ptr<Server>> servers;
        for (int i = 1; i < argc; ++i) {
            boost::asio::ip::tcp::endpoint endpoint(boost::asio::ip::tcp::v4(), std::atoi(argv[i]));
            std::shared_ptr<Server> a_server(new Server(*io_service, *strand, endpoint));
            servers.push_back(a_server);
        }

        boost::thread t(boost::bind(&boost::asio::io_service::run, io_service));
        t.join();
    }
    catch (std::exception& e) {
        std::cerr << "Exception: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
