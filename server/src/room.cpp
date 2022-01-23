#include <cstring>
#include <iostream>
#include <algorithm>
#include <boost/bind.hpp>

#include "../include/room.hpp"
#include "../include/functions.hpp"

/* Public */
void Room::enter(std::shared_ptr<User> participant, const std::string &nickname) {
	users.insert(participant);
	tab_names[participant] = nickname;
	std::cout << "enter " << nickname << std::endl;
	std::for_each(last_msgs.begin(), last_msgs.end(),
	              boost::bind(&User::action, participant, _1));
}

std::string Room::get_nick(std::shared_ptr<User> participant) { return tab_names[participant]; }

void Room::broadcast(std::array<char, FRAME_SIZE> &msg, std::shared_ptr<User> participant) {
	std::string nickname = get_nick(participant);
	std::string timestamp = dateTime();
	std::array<char, FRAME_SIZE> formatted_msg;
	formatted_msg.fill('\0');

	strcpy(formatted_msg.data(), timestamp.c_str());
	strcat(formatted_msg.data(), nickname.c_str());
	strcat(formatted_msg.data(), msg.data());

	last_msgs.push_back(formatted_msg);
	while (last_msgs.size() > max_msgs)
		last_msgs.pop_front();

	std::for_each(users.begin(), users.end(),
	              boost::bind(&User::action, _1, std::ref(formatted_msg)));
}

void Room::leave(std::shared_ptr<User> participant) {
	users.erase(participant);
	std::cout << "leave " << tab_names[participant] << std::endl;
	tab_names.erase(participant);
}