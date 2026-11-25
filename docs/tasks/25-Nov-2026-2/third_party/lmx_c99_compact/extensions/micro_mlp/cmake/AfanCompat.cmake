set(_afan_source "${_micro_vendor}/afan_neural_network/neural_network.c")
file(SHA256 "${_afan_source}" _afan_sha256)
# Pinned upstream 739c9f472c672ca15efc10ad5f472b2a42e7a4f0 uses CRLF.
# The supplied project archive stores that exact source normalized to LF.
# Accept only those two byte representations; never relax the snapshot check.
if(NOT _afan_sha256 STREQUAL "df5cc490a33ff80d59c47b82faad710f3a409f306ae0f8202834cbe586a2d618"
   AND NOT _afan_sha256 STREQUAL "d7d7ca7dad51978e293d9da2e03674f44e254649e087eaf768ac74d40072f314")
  message(FATAL_ERROR "Unexpected afan snapshot; review the narrow loader fix")
endif()
file(READ "${_afan_source}" _afan_text)
string(REPLACE "\r\n" "\n" _afan_text "${_afan_text}")
set(_afan_anchor [=[    for (int i = 1; i < network->num_layers; i++) {
        network->layers[i].neurons = (Neuron *) malloc(network->layers[i].num_neurons * sizeof(Neuron));]=])
set(_afan_replacement [=[    /* The saved topology includes the input layer; forward/free use it too. */
    network->layers[0].neurons = (Neuron *) calloc(network->layers[0].num_neurons, sizeof(Neuron));
    if (!network->layers[0].neurons) {
        fclose(fp);
        free(network->layers);
        free(network);
        return NULL;
    }

    for (int i = 1; i < network->num_layers; i++) {
        network->layers[i].neurons = (Neuron *) malloc(network->layers[i].num_neurons * sizeof(Neuron));]=])
string(FIND "${_afan_text}" "${_afan_anchor}" _afan_position)
if(_afan_position LESS 0)
  message(FATAL_ERROR "Pinned afan loader allocation point was not found")
endif()
string(REPLACE "${_afan_anchor}" "${_afan_replacement}" _afan_text "${_afan_text}")
set(_afan_build_view "${CMAKE_CURRENT_BINARY_DIR}/generated/afan_neural_network/neural_network.c")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/generated/afan_neural_network")
file(WRITE "${_afan_build_view}" "${_afan_text}")
