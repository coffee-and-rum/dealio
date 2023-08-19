// #include "TestPrint.hpp"
#include "TestPrint.hpp"
#include "libintl.h"
#include <iostream>

int main( int /*argc*/, const char** /*argv*/ )
{
	bindtextdomain( "my-domain", "locales" );
	textdomain( "my-domain" );
	std::cout << gettext( "Hello Dealio" ) << std::endl;
}
