#include <stdlib.h>

main() {
  while (1) { 
    system("(echo \"Really daft daemon\" ; echo \"Plan:\" ; cat ~/.plan) | nc -l 4214");
  }
}
