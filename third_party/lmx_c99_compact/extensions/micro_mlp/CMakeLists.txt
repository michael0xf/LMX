cmake_minimum_required(VERSION 3.20)
if(NOT COMMAND lmx_c99_target)
  message(FATAL_ERROR "The micro_mlp group requires the base lmx_c99_target helper")
endif()

set(_micro_vendor "${LMX_VENDOR_DIR}")
add_library(lmx_tinn STATIC "${_micro_vendor}/tinn/Tinn.c")
add_library(LMX::tinn ALIAS lmx_tinn)
target_include_directories(lmx_tinn PUBLIC "${_micro_vendor}/tinn")
if(UNIX)
  target_link_libraries(lmx_tinn PUBLIC m)
endif()
lmx_c99_target(lmx_tinn)
set_target_properties(lmx_tinn PROPERTIES POSITION_INDEPENDENT_CODE ON)

# Keep the complete upstream source unchanged; repair only load's missing input
# layer allocation in a separate, pinned build view.
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/AfanCompat.cmake")
add_library(lmx_afan_neural_network STATIC "${_afan_build_view}")
add_library(LMX::afan_neural_network ALIAS lmx_afan_neural_network)
target_include_directories(lmx_afan_neural_network PUBLIC "${_micro_vendor}/afan_neural_network")
if(UNIX)
  target_link_libraries(lmx_afan_neural_network PUBLIC m)
endif()
lmx_c99_target(lmx_afan_neural_network)
set_target_properties(lmx_afan_neural_network PROPERTIES POSITION_INDEPENDENT_CODE ON)

add_library(lmx_micro_mlp INTERFACE)
add_library(LMX::micro_mlp ALIAS lmx_micro_mlp)
target_link_libraries(lmx_micro_mlp INTERFACE LMX::tinn LMX::afan_neural_network)

if(BUILD_TESTING OR LMX_BUILD_EXAMPLES)
  add_executable(lmx_tinn_curve examples/learn_curve.c)
  lmx_c99_target(lmx_tinn_curve)
  target_link_libraries(lmx_tinn_curve PRIVATE LMX::tinn)
endif()
if(BUILD_TESTING)
  add_executable(lmx_tinn_forward_test tests/tinn_forward.c)
  lmx_c99_target(lmx_tinn_forward_test)
  target_link_libraries(lmx_tinn_forward_test PRIVATE LMX::tinn)
  add_test(NAME micro_mlp.tinn_forward COMMAND lmx_tinn_forward_test)
  add_test(NAME micro_mlp.tinn_training_roundtrip COMMAND lmx_tinn_curve "${CMAKE_CURRENT_BINARY_DIR}/tinn.model")

  add_executable(lmx_afan_network_test tests/afan_network.c)
  lmx_c99_target(lmx_afan_network_test)
  target_link_libraries(lmx_afan_network_test PRIVATE LMX::afan_neural_network)
  add_test(NAME micro_mlp.afan_forward_training_roundtrip COMMAND lmx_afan_network_test "${CMAKE_CURRENT_BINARY_DIR}/afan.model")
  set_tests_properties(micro_mlp.tinn_forward micro_mlp.tinn_training_roundtrip
    micro_mlp.afan_forward_training_roundtrip PROPERTIES TIMEOUT 30)
endif()
# CNeuralNet is retained for provenance/reproduction only: its training function
# is an empty stub. No misleading library target is added to the aggregate.
