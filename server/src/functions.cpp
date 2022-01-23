#include <chrono>
#include <sstream>
#include <iomanip>

#include "../include/functions.hpp"

std::string dateTime() {
	auto now = std::chrono::system_clock::now();
	auto time = std::chrono::system_clock::to_time_t(now);

	std::stringstream ss;
	ss << "[" << std::put_time(std::localtime(&time), "%Y-%m-%d %H:%M:%S") << "] ";
	return ss.str();
}