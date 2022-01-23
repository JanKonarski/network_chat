#pragma once

#include "../../config.hpp"

class User {
public:
	virtual ~User() = default;
	virtual void action(std::array<char, FRAME_SIZE> &msg) = 0;
};