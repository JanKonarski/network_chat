#pragma once

#include <vector>

#include "Error.hpp"
#include "AES.hpp"

namespace ocle {

	std::vector<uint8_t> getRandomBytes(size_t size);

}
