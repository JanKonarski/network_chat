#include <time.h>

#include "../include/ocle.hpp"

namespace ocle {

	std::vector<uint8_t> getRandomBytes(size_t size) {
		std::vector<uint8_t> vector;

		srand( (unsigned)time(NULL) );
		for(size_t i=0; i<size; i++)
			vector.push_back( rand() % 256 );

		return vector;
	}

}
