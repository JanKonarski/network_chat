#pragma once

#include <memory>
#include <array>
#include <deque>
#include <unordered_set>
#include <unordered_map>

#include "../../config.hpp"
#include "user.hpp"

class Room {
private:
	std::unordered_map<std::shared_ptr<User>, std::string> tab_names;
	std::unordered_set<std::shared_ptr<User>> users;
	std::deque<std::array<char, FRAME_SIZE>> last_msgs;
	const int max_msgs = 100;

public:
	void enter(std::shared_ptr<User> participant, const std::string & nickname);
	void leave(std::shared_ptr<User> participant);
	void broadcast(std::array<char, FRAME_SIZE>& msg, std::shared_ptr<User> participant);
	std::string get_nick(std::shared_ptr<User> participant);
};