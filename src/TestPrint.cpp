#include "TestPrint.hpp"
#include <iostream>
#include <libintl.h>

void TestPrint::init() {
  bindtextdomain("my-domain", "locales");
  textdomain("my-domain");
}

void TestPrint::print() { std::cout << gettext("Hello Dealio") << std::endl; }
