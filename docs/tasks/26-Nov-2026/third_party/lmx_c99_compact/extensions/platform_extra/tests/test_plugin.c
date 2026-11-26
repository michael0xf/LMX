/* A C-only symbol used to verify the POSIX loader ABI bridge. */
#if defined(_WIN32)
__declspec(dllexport)
#endif
int lmx_platform_plugin_answer(int value) { return value + 1; }
