// Validation helper only: actual CPython C API, not the LMX implementation.
#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <stdio.h>
#include <string.h>

static int failures;
static void check(const char *name, int success) {
    printf("{\"case\":\"%s\",\"passed\":%s}\n", name, success ? "true" : "false");
    if (!success) {
        ++failures;
        if (PyErr_Occurred()) PyErr_Print();
    }
}

int main(int argc, char **argv) {
    PyConfig config;
    PyStatus status;
    if (argc != 3) return 2;
    PyConfig_InitIsolatedConfig(&config);
    config.use_environment = 0;
    config.user_site_directory = 0;
    config.parse_argv = 0;
    config.install_signal_handlers = 0;
    config.site_import = 0;
    status = PyConfig_SetBytesString(&config, &config.program_name, argv[1]);
    if (!PyStatus_Exception(status))
        status = PyConfig_SetBytesString(&config, &config.home, argv[2]);
    if (!PyStatus_Exception(status)) status = Py_InitializeFromConfig(&config);
    if (PyStatus_Exception(status)) {
        fprintf(stderr, "isolated init failed: %s\n", status.err_msg ? status.err_msg : "exit");
        PyConfig_Clear(&config);
        return 3;
    }
    PyConfig_Clear(&config);
    check("isolated_pyconfig_init", Py_IsInitialized());

    PyObject *module = PyImport_ImportModule("math");
    PyObject *callable = module ? PyObject_GetAttrString(module, "factorial") : NULL;
    PyObject *six = PyLong_FromLong(6);
    PyObject *args = six ? PyTuple_Pack(1, six) : NULL;
    PyObject *kwargs = PyDict_New();
    PyObject *result = callable && args && kwargs ? PyObject_Call(callable, args, kwargs) : NULL;
    check("import_getattr_object_call_720", result && PyLong_AsLong(result) == 720
          && !PyErr_Occurred());
    Py_XDECREF(result);
    Py_XDECREF(args);
    Py_XDECREF(six);

    PyObject *negative = PyLong_FromLong(-1);
    args = negative ? PyTuple_Pack(1, negative) : NULL;
    result = callable && args && kwargs ? PyObject_Call(callable, args, kwargs) : NULL;
    PyObject *error = PyErr_GetRaisedException();
    int matched = error ? PyObject_IsInstance(error, PyExc_ValueError) : 0;
    check("exception_captured_and_indicator_cleared", !result && error
          && matched == 1 && !PyErr_Occurred());
    Py_XDECREF(result);
    Py_XDECREF(error);
    Py_XDECREF(args);
    Py_XDECREF(negative);

    PyObject *none = Py_NewRef(Py_None);
    check("none_is_owned_success_value", none == Py_None && !PyErr_Occurred());
    Py_DECREF(none);

    const char content[3] = {'a', '\0', 'b'};
    PyObject *unicode = PyUnicode_DecodeUTF8(content, 3, "strict");
    Py_ssize_t utf8_length = 0;
    const char *utf8 = unicode ? PyUnicode_AsUTF8AndSize(unicode, &utf8_length) : NULL;
    check("utf8_embedded_nul_preserved", utf8 && utf8_length == 3
          && memcmp(utf8, content, 3) == 0);
    Py_XDECREF(unicode);

    PyObject *list = PyList_New(0);
    PyObject *item = PyLong_FromLong(42);
    int appended = list && item ? PyList_Append(list, item) : -1;
    Py_XDECREF(item);
    PyObject *borrowed = appended == 0 ? PyList_GetItem(list, 0) : NULL;
    PyObject *owned = borrowed ? Py_NewRef(borrowed) : NULL;
    Py_XDECREF(list);
    check("borrowed_promoted_before_owner_release", owned && PyLong_AsLong(owned) == 42);
    Py_XDECREF(owned);

    PyObject *bytes = PyByteArray_FromStringAndSize("abc", 3);
    PyObject *view = bytes ? PyMemoryView_FromObject(bytes) : NULL;
    PyObject *step = PyLong_FromLong(-1);
    PyObject *slice = step ? PySlice_New(Py_None, Py_None, step) : NULL;
    PyObject *reverse = view && slice ? PyObject_GetItem(view, slice) : NULL;
    Py_buffer buffer;
    int acquired = reverse ? PyObject_GetBuffer(reverse, &buffer,
                                                PyBUF_FORMAT | PyBUF_STRIDES) : -1;
    int valid = acquired == 0 && buffer.ndim == 1 && buffer.itemsize == 1
        && buffer.len == 3 && buffer.shape[0] == 3 && buffer.strides[0] == -1
        && buffer.readonly == 0 && *(char *)buffer.buf == 'c';
    check("negative_buffer_byte_stride", valid);
    if (acquired == 0) PyBuffer_Release(&buffer);
    Py_XDECREF(reverse);
    Py_XDECREF(slice);
    Py_XDECREF(step);
    Py_XDECREF(view);
    Py_XDECREF(bytes);

    PyThreadState *saved = PyEval_SaveThread();
    PyGILState_STATE gil = PyGILState_Ensure();
    int attached = PyThreadState_Get() != NULL;
    PyGILState_Release(gil);
    PyEval_RestoreThread(saved);
    check("same_main_interpreter_attach_release", attached);
    Py_XDECREF(kwargs);
    Py_XDECREF(callable);
    Py_XDECREF(module);
    int final_status = Py_FinalizeEx();
    printf("{\"case\":\"finalize_once\",\"passed\":%s}\n",
           final_status == 0 ? "true" : "false");
    if (final_status != 0) ++failures;
    return failures ? 1 : 0;
}
