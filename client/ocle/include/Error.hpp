#pragma once

#include <exception>
#include <string>

namespace ocle {

	/**
	 * @bief Class of exception, extends standard C++ exception
	 */
	class Error : virtual public std::exception {

	protected:
		std::string error_message;

	public:
		/**
		 * Constructor (C++ STL string).
		 * @param msg The error message
		 */
		explicit Error(const std::string& msg) : error_message(msg) {}

		/**
		 * Returns a pointer to the (constant) error description.
		 * @return A pointer to a const char.
		 */
		virtual const char* what() {
			return error_message.c_str();
		}

	};

}
