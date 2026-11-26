# Hash-guarded ISO C99/integration view. Original retained vendor bytes are unchanged.
file(MAKE_DIRECTORY "${NETCDF_VIEW}")
file(COPY "${NETCDF_VENDOR}/" DESTINATION "${NETCDF_VIEW}")
file(SHA256 "${NETCDF_VENDOR}/CMakeLists.txt" input_sha)
if(NOT input_sha STREQUAL "4094596241226a816cbd4ed167dcfadb275c531e85e8cce06a71a2f2998c4f1a")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: CMakeLists.txt")
endif()
file(READ "${NETCDF_VENDOR}/CMakeLists.txt" content)
set(before [====[
#Project Name
project(netCDF
  LANGUAGES C CXX
  HOMEPAGE_URL "https://www.unidata.ucar.edu/software/netcdf/"
  DESCRIPTION "NetCDF is a set of software libraries and machine-independent data formats that support the creation, access, and sharing of array-oriented scientific data."
  VERSION 4.10.1
]====])
set(after [====[
#Project Name
project(netCDF
  LANGUAGES C
  HOMEPAGE_URL "https://www.unidata.ucar.edu/software/netcdf/"
  DESCRIPTION "NetCDF is a set of software libraries and machine-independent data formats that support the creation, access, and sharing of array-oriented scientific data."
  VERSION 4.10.1
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/CMakeLists.txt" "${content}")
file(SHA256 "${NETCDF_VENDOR}/cmake/dependencies.cmake" input_sha)
if(NOT input_sha STREQUAL "0fe09c1eb979f39c7358e7671f71896b0233432ff5cc0ebcfaff65fbd5f2e1bd")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: cmake/dependencies.cmake")
endif()
file(READ "${NETCDF_VENDOR}/cmake/dependencies.cmake" content)
set(before [====[  #####
  # First, find the C and HL libraries.
  #####
  find_package(HDF5 COMPONENTS C HL REQUIRED)

  message(STATUS "Found HDF5 version: ${HDF5_VERSION}")
]====])
set(after [====[  #####
  # First, find the C and HL libraries.
  #####
  find_package(ZLIB REQUIRED)
  if(NOT TARGET ZLIB::ZLIB)
    add_library(ZLIB::ZLIB UNKNOWN IMPORTED)
    set_target_properties(ZLIB::ZLIB PROPERTIES IMPORTED_LOCATION "${ZLIB_LIBRARY}" INTERFACE_INCLUDE_DIRECTORIES "${ZLIB_INCLUDE_DIR}")
  endif()
  find_package(MPI COMPONENTS C)
  find_package(HDF5 COMPONENTS C HL REQUIRED)

  message(STATUS "Found HDF5 version: ${HDF5_VERSION}")
]====])
string(REPLACE "${before}" "${after}" content "${content}")
set(before [====[    set(HDF5_PARALLEL ${HDF5_PROVIDES_PARALLEL})
  endif(NOT HDF5_PARALLEL)

  set(CMAKE_REQUIRED_LIBRARIES HDF5::HDF5)
  include(CheckSymbolExists)

  #Check to see if HDF5 library has collective metadata APIs, (HDF5 >= 1.10.0)
]====])
set(after [====[    set(HDF5_PARALLEL ${HDF5_PROVIDES_PARALLEL})
  endif(NOT HDF5_PARALLEL)

  set(CMAKE_REQUIRED_LIBRARIES HDF5::HDF5 ZLIB::ZLIB Threads::Threads)
  if(TARGET MPI::MPI_C)
    list(APPEND CMAKE_REQUIRED_LIBRARIES MPI::MPI_C)
  endif()
  include(CheckSymbolExists)

  #Check to see if HDF5 library has collective metadata APIs, (HDF5 >= 1.10.0)
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/cmake/dependencies.cmake" "${content}")
file(SHA256 "${NETCDF_VENDOR}/include/ncconfigure.h" input_sha)
if(NOT input_sha STREQUAL "390b93645b5653d86b517e53587b8c6e78b476581303fbed8858a801bc209071")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: include/ncconfigure.h")
endif()
file(READ "${NETCDF_VENDOR}/include/ncconfigure.h" content)
set(before [====[#endif /*_WIN32*/

#ifndef nulldup
#define nulldup(s) ((s)==NULL?s:strdup(s))
#endif

#ifndef nulllen
]====])
set(after [====[#endif /*_WIN32*/

#ifndef nulldup
#define nulldup(s) ((s)==NULL?NULL:strdup(s))
#endif

#ifndef nulllen
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/include/ncconfigure.h" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libdap4/ncd4.h" input_sha)
if(NOT input_sha STREQUAL "03d0444c08540f082a2fa95f2367bb6cd1009ad38485cb6a2f7ba0dca04896ea")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libdap4/ncd4.h")
endif()
file(READ "${NETCDF_VENDOR}/libdap4/ncd4.h" content)
set(before [====[ *
 * Requires a local @c int @c ret and a @c done label in the enclosing function.
 */
#define FAIL(code,fmt,...) do{ret=NCD4_error(code,__LINE__,__FILE__,fmt , ##__VA_ARGS__); goto done;}while(0)

/** Allocate an NCD4offset covering [@p base, @p base+@p size). */
#define BUILDOFFSET(base,size) NCD4_buildoffset(base,size)
]====])
set(after [====[ *
 * Requires a local @c int @c ret and a @c done label in the enclosing function.
 */
#define FAIL(code,...) do{ret=NCD4_error(code,__LINE__,__FILE__,__VA_ARGS__); goto done;}while(0)

/** Allocate an NCD4offset covering [@p base, @p base+@p size). */
#define BUILDOFFSET(base,size) NCD4_buildoffset(base,size)
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libdap4/ncd4.h" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libdap4/ncd4types.h" input_sha)
if(NOT input_sha STREQUAL "d30250671992801902398ce467e06da8c7b96a70502f41e36530bb74718ec601")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libdap4/ncd4types.h")
endif()
file(READ "${NETCDF_VENDOR}/libdap4/ncd4types.h" content)
set(before [====[/* sigh, do the forwards */

typedef struct NCD4INFO NCD4INFO;
typedef enum NCD4CSUM NCD4CSUM;
typedef enum NCD4mode NCD4mode;
typedef enum NCD4format NCD4format;
typedef enum NCD4translation NCD4translation;
typedef struct NCD4curl NCD4curl;
typedef struct NCD4meta NCD4meta;
typedef struct NCD4node NCD4node;
]====])
set(after [====[/* sigh, do the forwards */

typedef struct NCD4INFO NCD4INFO;
typedef struct NCD4curl NCD4curl;
typedef struct NCD4meta NCD4meta;
typedef struct NCD4node NCD4node;
]====])
string(REPLACE "${before}" "${after}" content "${content}")
set(before [====[    NCD4_NOTRANS  = 0, /**< Straight DAP4-to-NetCDF4 translation. */
    NCD4_TRANSNC4 = 1, /**< Use @c _edu.ucar flags for improved translation. */
};

#define NCF_DEBUG_NONE  0 /**< No debug action. */
#define NCF_DEBUG_COPY  1 /**< Write data into substrate and close instead of aborting. */
]====])
set(after [====[    NCD4_NOTRANS  = 0, /**< Straight DAP4-to-NetCDF4 translation. */
    NCD4_TRANSNC4 = 1, /**< Use @c _edu.ucar flags for improved translation. */
};
typedef enum NCD4translation NCD4translation;

#define NCF_DEBUG_NONE  0 /**< No debug action. */
#define NCF_DEBUG_COPY  1 /**< Write data into substrate and close instead of aborting. */
]====])
string(REPLACE "${before}" "${after}" content "${content}")
set(before [====[    NCD4_DAP = 2, /**< Retrieve the full DAP response (DMR + data). */
    NCD4_DSR = 4  /**< Retrieve the DSR (dataset services resource). */
};

/** Wire format of a DAP4 response. */
enum NCD4format {
    NCD4_FORMAT_NONE = 0, /**< No specific format. */
    NCD4_FORMAT_XML  = 1  /**< XML-encoded response. */
};

/**
 * Union providing storage for any DAP4 primitive value.
]====])
set(after [====[    NCD4_DAP = 2, /**< Retrieve the full DAP response (DMR + data). */
    NCD4_DSR = 4  /**< Retrieve the DSR (dataset services resource). */
};
typedef enum NCD4mode NCD4mode;

/** Wire format of a DAP4 response. */
enum NCD4format {
    NCD4_FORMAT_NONE = 0, /**< No specific format. */
    NCD4_FORMAT_XML  = 1  /**< XML-encoded response. */
};
typedef enum NCD4format NCD4format;

/**
 * Union providing storage for any DAP4 primitive value.
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libdap4/ncd4types.h" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libdispatch/dinfermodel.c" input_sha)
if(NOT input_sha STREQUAL "f41f064ed07d06249b47415014a49b806d53c63ff3103d16fddd8dec5f4ad609")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libdispatch/dinfermodel.c")
endif()
file(READ "${NETCDF_VENDOR}/libdispatch/dinfermodel.c" content)
set(before [====[#endif

#ifndef nulldup
 #define nulldup(x) ((x)?strdup(x):(x))
#endif

#undef DEBUG
]====])
set(after [====[#endif

#ifndef nulldup
 #define nulldup(x) ((x)?strdup(x):NULL)
#endif

#undef DEBUG
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libdispatch/dinfermodel.c" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libdispatch/dudfplugins.c" input_sha)
if(NOT input_sha STREQUAL "3e945d826c4b0b84209a89b10cfa9db7fc00b3ceeb34f6a1bb3efbada7267f57")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libdispatch/dudfplugins.c")
endif()
file(READ "${NETCDF_VENDOR}/libdispatch/dudfplugins.c" content)
set(before [====[ * @author Edward Hartnett
 * @date 2/2/26
 */
static void*
get_symbol(void* handle, const char* symbol)
{
    void* sym = NULL;
    
#ifdef _WIN32
    sym = (void*)GetProcAddress((HMODULE)handle, symbol);
    if (!sym) {
        DWORD err = GetLastError();
        nclog(NCLOGERR, "GetProcAddress failed for %s: error %lu", symbol, err);
    }
#else
    sym = dlsym(handle, symbol);
    if (!sym) {
        nclog(NCLOGERR, "dlsym failed for %s: %s", symbol, dlerror());
    }
]====])
set(after [====[ * @author Edward Hartnett
 * @date 2/2/26
 */
typedef void (*lmx_nc_plugin_symbol)(void);
static lmx_nc_plugin_symbol
get_symbol(void* handle, const char* symbol)
{
    lmx_nc_plugin_symbol sym = NULL;
    
#ifdef _WIN32
    sym = (lmx_nc_plugin_symbol)GetProcAddress((HMODULE)handle, symbol);
    if (!sym) {
        DWORD err = GetLastError();
        nclog(NCLOGERR, "GetProcAddress failed for %s: error %lu", symbol, err);
    }
#else
    {
        void* raw_symbol = dlsym(handle, symbol);
        if (sizeof sym != sizeof raw_symbol) return NULL;
        memcpy(&sym, &raw_symbol, sizeof sym);
    }
    if (!sym) {
        nclog(NCLOGERR, "dlsym failed for %s: %s", symbol, dlerror());
    }
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libdispatch/dudfplugins.c" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libdispatch/ncjson.c" input_sha)
if(NOT input_sha STREQUAL "2db7ba2b3e73ad336417e28839885144aaf87d483d43ebdab372b99c7d48e580")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libdispatch/ncjson.c")
endif()
file(READ "${NETCDF_VENDOR}/libdispatch/ncjson.c" content)
set(before [====[#define nullfree(x) {if(x)free(x);}
#endif /*nullfree*/
#ifndef nulldup
#define nulldup(x) ((x)?strdup(x):(x))
#endif /*nulldup*/

#if defined NCJDEBUG || defined NCJTRACE
]====])
set(after [====[#define nullfree(x) {if(x)free(x);}
#endif /*nullfree*/
#ifndef nulldup
#define nulldup(x) ((x)?strdup(x):NULL)
#endif /*nulldup*/

#if defined NCJDEBUG || defined NCJTRACE
]====])
string(REPLACE "${before}" "${after}" content "${content}")
set(before [====[    const NCjson* jvalue = NULL;
    stat = NCJdictget(dict,key,&jvalue);
    if(stat != NCJ_OK) jvalue = NULL;
    return jvalue;
}

/* Unescape the text in parser->yytext; can
]====])
set(after [====[    const NCjson* jvalue = NULL;
    stat = NCJdictget(dict,key,&jvalue);
    if(stat != NCJ_OK) jvalue = NULL;
    return (NCjson*)jvalue;
}

/* Unescape the text in parser->yytext; can
]====])
string(REPLACE "${before}" "${after}" content "${content}")
set(before [====[netcdf_supresswarnings(void)
{
    void* ignore = NULL;
    ignore = (void*)netcdf_supresswarnings;
    ignore = (void*)NCJparse;
    ignore = (void*)NCJparsen;
    ignore = (void*)NCJreclaim;
    ignore = (void*)NCJnew;
    ignore = (void*)NCJnewstring;
    ignore = (void*)NCJnewstringn;
    ignore = (void*)NCJdictget;
    ignore = (void*)NCJdictlookup;
    ignore = (void*)NCJcvt;
    ignore = (void*)NCJaddstring;
    ignore = (void*)NCJappend;
    ignore = (void*)NCJappendstring;
    ignore = (void*)NCJappendint;
    ignore = (void*)NCJinsert;
    ignore = (void*)NCJinsertstring;
    ignore = (void*)NCJinsertint;
    ignore = (void*)NCJoverwrite;
    ignore = (void*)NCJdictsort;
    ignore = (void*)NCJdump;
    (void)ignore;
}
]====])
set(after [====[netcdf_supresswarnings(void)
{
    void* ignore = NULL;
    (void)netcdf_supresswarnings;
    (void)NCJparse;
    (void)NCJparsen;
    (void)NCJreclaim;
    (void)NCJnew;
    (void)NCJnewstring;
    (void)NCJnewstringn;
    (void)NCJdictget;
    (void)NCJdictlookup;
    (void)NCJcvt;
    (void)NCJaddstring;
    (void)NCJappend;
    (void)NCJappendstring;
    (void)NCJappendint;
    (void)NCJinsert;
    (void)NCJinsertstring;
    (void)NCJinsertint;
    (void)NCJoverwrite;
    (void)NCJdictsort;
    (void)NCJdump;
    (void)ignore;
}
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libdispatch/ncjson.c" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libdispatch/ncproplist.c" input_sha)
if(NOT input_sha STREQUAL "1af82b6d18334837711fb73190bfc431c118d960cfb414e510dd1803eb27d7b6")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libdispatch/ncproplist.c")
endif()
file(READ "${NETCDF_VENDOR}/libdispatch/ncproplist.c" content)
set(before [====[static void
ncproplist_unused(void)
{
    void* unused = ncproplist_unused;
    unused = ncproplistnew;
    unused = ncproplistfree;
    unused = ncproplistadd;
    unused = ncproplistaddbytes;
    unused = ncproplistaddstring;
    unused = ncproplistaddx;
    unused = ncproplistclone;
    unused = ncproplistget;
    unused = ncproplistith;
    unused = ncproplistinit;
    unused = (void*)ncproplistith;
    (void)unused;
}
]====])
set(after [====[static void
ncproplist_unused(void)
{
    (void)ncproplist_unused;
    (void)ncproplistnew;
    (void)ncproplistfree;
    (void)ncproplistadd;
    (void)ncproplistaddbytes;
    (void)ncproplistaddstring;
    (void)ncproplistaddx;
    (void)ncproplistclone;
    (void)ncproplistget;
    (void)ncproplistith;
    (void)ncproplistinit;
    (void)ncproplistith;
}
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libdispatch/ncproplist.c" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libhdf5/hdf5internal.c" input_sha)
if(NOT input_sha STREQUAL "271a0023a55657bec1c49359b826c50339631709ba3e32dacf71708281898572")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libhdf5/hdf5internal.c")
endif()
file(READ "${NETCDF_VENDOR}/libhdf5/hdf5internal.c" content)
set(before [====[ * @return 0 for success.
 */
static herr_t
h5catch(void* ignored)
{
    H5Eprint1(NULL);
    return 0;
}
#endif
]====])
set(after [====[ * @return 0 for success.
 */
static herr_t
h5catch(hid_t stack, void* ignored)
{
    (void)ignored;
    H5Eprint2(stack, NULL);
    return 0;
}
#endif
]====])
string(REPLACE "${before}" "${after}" content "${content}")
set(before [====[   severity 0 for errors, 1 for important log messages, 2 for less
   important, etc. */
extern int nc_log_level;

#endif /* LOGGING */

]====])
set(after [====[   severity 0 for errors, 1 for important log messages, 2 for less
   important, etc. */
extern int nc_log_level;
static herr_t lmx_nc_hdf_log_error(hid_t stack, void *stream)
{
    return H5Eprint2(stack, (FILE *)stream);
}

#endif /* LOGGING */

]====])
string(REPLACE "${before}" "${after}" content "${content}")
set(before [====[ * @return 0 for success
 */
static herr_t
set_auto(void* func, void *client_data)
{
#ifdef DEBUGH5
    return H5Eset_auto2(H5E_DEFAULT,(H5E_auto2_t)h5catch,client_data);
#else
    return H5Eset_auto2(H5E_DEFAULT,(H5E_auto2_t)func,client_data);
#endif
}

]====])
set(after [====[ * @return 0 for success
 */
static herr_t
set_auto(H5E_auto2_t func, void *client_data)
{
#ifdef DEBUGH5
    return H5Eset_auto2(H5E_DEFAULT,h5catch,client_data);
#else
    return H5Eset_auto2(H5E_DEFAULT,func,client_data);
#endif
}

]====])
string(REPLACE "${before}" "${after}" content "${content}")
set(before [====[#ifdef LOGGING
/* We will need to check against nc log level from nc4internal.c. */
extern int nc_log_level;

/**
 * @internal This is like nc_set_log_level(), but will also turn on
]====])
set(after [====[#ifdef LOGGING
/* We will need to check against nc log level from nc4internal.c. */
extern int nc_log_level;
static herr_t lmx_nc_hdf_log_error(hid_t stack, void *stream)
{
    return H5Eprint2(stack, (FILE *)stream);
}

/**
 * @internal This is like nc_set_log_level(), but will also turn on
]====])
string(REPLACE "${before}" "${after}" content "${content}")
set(before [====[    }
    else
    {
        if (set_auto((H5E_auto_t)&H5Eprint1, stderr) < 0)
            LOG((0, "H5Eset_auto failed!"));
        LOG((1, "HDF5 error messages turned on."));
    }
]====])
set(after [====[    }
    else
    {
        if (set_auto(lmx_nc_hdf_log_error, stderr) < 0)
            LOG((0, "H5Eset_auto failed!"));
        LOG((1, "HDF5 error messages turned on."));
    }
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libhdf5/hdf5internal.c" "${content}")
file(SHA256 "${NETCDF_VENDOR}/liblib/CMakeLists.txt" input_sha)
if(NOT input_sha STREQUAL "56c97d320abd714c5dd9fee350ad4a7fc838b3de8e0b776c30c949d26edfa735")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: liblib/CMakeLists.txt")
endif()
file(READ "${NETCDF_VENDOR}/liblib/CMakeLists.txt" content)
set(before [====[if(USE_HDF5 AND NOT NETCDF_ENABLE_FILTER_SZIP)
  foreach(_hdf5_tgt IN ITEMS HDF5::HDF5 hdf5::hdf5_hl)
    if(TARGET ${_hdf5_tgt})
      get_target_property(_iface_libs ${_hdf5_tgt} INTERFACE_LINK_LIBRARIES)
      if(_iface_libs)
        list(FILTER _iface_libs EXCLUDE REGEX "(libsz|libszip|libaec|[/\\]sz[.;]|[/\\]szip[.;]|[/\\]aec[.;])")
]====])
set(after [====[if(USE_HDF5 AND NOT NETCDF_ENABLE_FILTER_SZIP)
  foreach(_hdf5_tgt IN ITEMS HDF5::HDF5 hdf5::hdf5_hl)
    if(TARGET ${_hdf5_tgt})
      get_target_property(_hdf5_real ${_hdf5_tgt} ALIASED_TARGET)
      if(_hdf5_real)
        set(_hdf5_tgt ${_hdf5_real})
      endif()
      get_target_property(_iface_libs ${_hdf5_tgt} INTERFACE_LINK_LIBRARIES)
      if(_iface_libs)
        list(FILTER _iface_libs EXCLUDE REGEX "(libsz|libszip|libaec|[/\\]sz[.;]|[/\\]szip[.;]|[/\\]aec[.;])")
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/liblib/CMakeLists.txt" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libncxml/ncxml_xml2.c" input_sha)
if(NOT input_sha STREQUAL "e529a5770474bc8d9ed2132c1a7d098090f5ddea7cb3b4360341bca936be20bd")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libncxml/ncxml_xml2.c")
endif()
file(READ "${NETCDF_VENDOR}/libncxml/ncxml_xml2.c" content)
set(before [====[#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <libxml2/libxml/parser.h>
#include <libxml/tree.h>
#include "ncxml.h"

]====])
set(after [====[#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <libxml/parser.h>
#include <libxml/tree.h>
#include "ncxml.h"

]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libncxml/ncxml_xml2.c" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libnczarr/zdebug.h" input_sha)
if(NOT input_sha STREQUAL "574d8fe364e00e49436de2f34e1c471a0427d1f93a21433f60795e29a44bfc99")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libnczarr/zdebug.h")
endif()
file(READ "${NETCDF_VENDOR}/libnczarr/zdebug.h" content)
set(before [====[#endif

#ifdef ZTRACING
#define ZTRACE(level,fmt,...) nctrace((level),__func__,fmt,##__VA_ARGS__)
#define ZTRACEMORE(level,fmt,...) nctracemore((level),fmt,##__VA_ARGS__)
#define ZUNTRACE(e) ncuntrace(__func__,THROW(e),NULL)
#define ZUNTRACEX(e,fmt,...) ncuntrace(__func__,THROW(e),fmt,##__VA_ARGS__)
#else
#define ZTRACE(level,fmt,...)
#define ZTRACEMORE(level,fmt,...)
#ifdef ZCATCH
#define ZUNTRACE(e) THROW(e)
#define ZUNTRACEX(e,fmt,...) THROW(e)
#else
#define ZUNTRACE(e) (e)
#define ZUNTRACEX(e,fmt,...) (e)
#endif
#endif

]====])
set(after [====[#endif

#ifdef ZTRACING
#define ZTRACE(level,...) nctrace((level),__func__,__VA_ARGS__)
#define ZTRACEMORE(level,...) nctracemore((level),__VA_ARGS__)
#define ZUNTRACE(e) ncuntrace(__func__,THROW(e),NULL)
#define ZUNTRACEX(e,...) ncuntrace(__func__,THROW(e),__VA_ARGS__)
#else
#define ZTRACE(level,...)
#define ZTRACEMORE(level,...)
#ifdef ZCATCH
#define ZUNTRACE(e) THROW(e)
#define ZUNTRACEX(e,...) THROW(e)
#else
#define ZUNTRACE(e) (e)
#define ZUNTRACEX(e,...) (e)
#endif
#endif

]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libnczarr/zdebug.h" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libnczarr/zsync.c" input_sha)
if(NOT input_sha STREQUAL "882990d42e2728e5aec3f597b18bdf52426cab5e196d8fb5396e4059d3074060")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libnczarr/zsync.c")
endif()
file(READ "${NETCDF_VENDOR}/libnczarr/zsync.c" content)
set(before [====[#include "ncutil.h"

#ifndef nulldup
#define nulldup(x) ((x)?strdup(x):(x))
#endif

#undef FILLONCLOSE
]====])
set(after [====[#include "ncutil.h"

#ifndef nulldup
#define nulldup(x) ((x)?strdup(x):NULL)
#endif

#undef FILLONCLOSE
]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libnczarr/zsync.c" "${content}")
file(SHA256 "${NETCDF_VENDOR}/libsrcp/CMakeLists.txt" input_sha)
if(NOT input_sha STREQUAL "02664134878dcf7e7d2d42c6d28d49641a01f50b4f4f43cf8656268290829440")
  message(FATAL_ERROR "netCDF input changed; review C99 adaptation: libsrcp/CMakeLists.txt")
endif()
file(READ "${NETCDF_VENDOR}/libsrcp/CMakeLists.txt" content)
set(before [====[# See netcdf-c/COPYRIGHT file for more info.

add_library(netcdfp OBJECT ${libsrcp_SOURCES})
target_link_libraries(netcdfp PUBLIC PNETCDF::PNETCDF)

target_sources(netcdfp PRIVATE ncpdispatch.c)

]====])
set(after [====[# See netcdf-c/COPYRIGHT file for more info.

add_library(netcdfp OBJECT ${libsrcp_SOURCES})
target_link_libraries(netcdfp PUBLIC PNETCDF::PNETCDF MPI::MPI_C)

target_sources(netcdfp PRIVATE ncpdispatch.c)

]====])
string(REPLACE "${before}" "${after}" content "${content}")
file(WRITE "${NETCDF_VIEW}/libsrcp/CMakeLists.txt" "${content}")
