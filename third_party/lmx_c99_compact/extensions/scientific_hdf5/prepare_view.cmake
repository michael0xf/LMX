# Pinned, hash-guarded C99 view. Vendor bytes are never rewritten.
function(lmx_hdf5_prepare_view original destination)
  get_filename_component(original "${original}" REALPATH)
  file(MAKE_DIRECTORY "${destination}")
  file(COPY "${original}/" DESTINATION "${destination}")
  file(SHA256 "${original}/config/flags/HDFCompilerFlags.cmake" _sha)
  if(NOT _sha STREQUAL "a3bc1acfbf0f174140268ea8c7495ee99e5bfb3b132b63d1473c6f4eaeaeb5b7")
    message(FATAL_ERROR "HDF5 pinned input changed: config/flags/HDFCompilerFlags.cmake")
  endif()
  file(READ "${original}/config/flags/HDFCompilerFlags.cmake" _text)
  string(REPLACE [====[# If you do not have access to either file, you may request a copy from
# help@hdfgroup.org.
#
set (CMAKE_C_STANDARD 11)
set (CMAKE_C_STANDARD_REQUIRED TRUE)

set (CMAKE_C_FLAGS "${CMAKE_C11_STANDARD_COMPILE_OPTION} ${CMAKE_C_FLAGS}")
set (CMAKE_C_FLAGS "${CMAKE_C_SANITIZER_FLAGS} ${CMAKE_C_FLAGS}")
message (VERBOSE "Warnings Configuration: C default: ${CMAKE_C_FLAGS}")
#-----------------------------------------------------------------------------
]====] [====[# If you do not have access to either file, you may request a copy from
# help@hdfgroup.org.
#
set (CMAKE_C_STANDARD 99) # LMX selected ISO C99 profile
set (CMAKE_C_STANDARD_REQUIRED TRUE)

set (CMAKE_C_FLAGS "${CMAKE_C99_STANDARD_COMPILE_OPTION} ${CMAKE_C_FLAGS}")
set (CMAKE_C_FLAGS "${CMAKE_C_SANITIZER_FLAGS} ${CMAKE_C_FLAGS}")
message (VERBOSE "Warnings Configuration: C default: ${CMAKE_C_FLAGS}")
#-----------------------------------------------------------------------------
]====] _text "${_text}")
  file(WRITE "${destination}/config/flags/HDFCompilerFlags.cmake" "${_text}")
  file(SHA256 "${original}/src/H5RTpkg.h" _sha)
  if(NOT _sha STREQUAL "e81c767bc37eb8557ac23c29a72cf81017d7439b1e6b2ae8718dbae85a39e2e6")
    message(FATAL_ERROR "HDF5 pinned input changed: src/H5RTpkg.h")
  endif()
  file(READ "${original}/src/H5RTpkg.h" _text)
  string(REPLACE [====[typedef struct H5RT_node_t H5RT_node_t;

/* Internal node of the r-tree */
typedef struct H5RT_node_t {
    hsize_t min[H5S_MAX_RANK]; /* Invalid for root node */
    hsize_t max[H5S_MAX_RANK]; /* Invalid for root node */
    union {
]====] [====[typedef struct H5RT_node_t H5RT_node_t;

/* Internal node of the r-tree */
/* LMX C99: typedef is already declared above. */
struct H5RT_node_t {
    hsize_t min[H5S_MAX_RANK]; /* Invalid for root node */
    hsize_t max[H5S_MAX_RANK]; /* Invalid for root node */
    union {
]====] _text "${_text}")
  string(REPLACE [====[    } children;
    int  nchildren;
    bool children_are_leaves;
} H5RT_node_t;

/* Overall r-tree */
struct H5RT_t {
]====] [====[    } children;
    int  nchildren;
    bool children_are_leaves;
};

/* Overall r-tree */
struct H5RT_t {
]====] _text "${_text}")
  file(WRITE "${destination}/src/H5RTpkg.h" "${_text}")
endfunction()
