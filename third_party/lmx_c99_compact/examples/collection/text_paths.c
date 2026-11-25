#include "cwalk.h"
#include "utf8.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* These are lexical operations: the paths need not exist on this host. */
int main(void)
{
  static const char name[] = "caf\xC3\xA9.txt";
  char posix_path[128];
  char windows_path[128];
  enum cwk_path_style original_style = cwk_path_get_style();
  size_t needed;

  cwk_path_set_style(CWK_STYLE_UNIX);
  needed = cwk_path_join("/srv/reports/../data", name, posix_path, sizeof(posix_path));
  if (needed >= sizeof(posix_path)) return EXIT_FAILURE;
  cwk_path_set_style(CWK_STYLE_WINDOWS);
  needed = cwk_path_join("C:\\reports\\..\\data", name, windows_path, sizeof(windows_path));
  cwk_path_set_style(original_style);
  if (needed >= sizeof(windows_path)) return EXIT_FAILURE;

  printf("POSIX:   %s\nWindows: %s\n", posix_path, windows_path);
  printf("Name: %zu bytes, %zu code points\n", strlen(name), utf8len(name));
  return strcmp(posix_path, "/srv/data/caf\xC3\xA9.txt") == 0 &&
         strcmp(windows_path, "C:\\data\\caf\xC3\xA9.txt") == 0 &&
         utf8len(name) == 8 ? EXIT_SUCCESS : EXIT_FAILURE;
}
