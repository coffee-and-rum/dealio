#include <iostream>
#include <cstdlib>
#include "libintl.h"

#include <Windows.h>

int main()
{
	_configthreadlocale( _DISABLE_PER_THREAD_LOCALE );
	SetThreadLocale( 1045 );
	bindtextdomain( "my-domain", "locales" );
	bind_textdomain_codeset( "my-domain", "UTF-8" );
	textdomain( "my-domain" );
	std::cout << gettext( "Hello Dealio" ) << std::endl;
}
