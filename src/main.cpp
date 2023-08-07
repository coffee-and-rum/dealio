#include "TestPrint.hpp"

int main(int /*argc*/, const char ** /*argv*/) {
  TestPrint testPrint{};
  testPrint.init();
  testPrint.print();
}
