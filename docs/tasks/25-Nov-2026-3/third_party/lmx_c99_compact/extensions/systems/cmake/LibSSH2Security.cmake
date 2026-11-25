# Checked backports of published upstream fixes; original vendor stays unchanged.
# See patches/libssh2 and provenance/libssh2-security.json.
function(lmx_libssh2_apply_security_view view)
    file(SHA256 "${view}/src/packet.c" _input_sha)
    if(NOT _input_sha STREQUAL "d8d433c7bb61f277abbd9985f0437378d26781737e173e6bd77415fb3726e54f")
        message(FATAL_ERROR "Unexpected original libssh2 1.11.1 source: packet.c")
    endif()
    file(READ "${view}/src/packet.c" _source)
    string(REPLACE [====[                    _libssh2_get_string(&buf, &name, &name_len);
                    _libssh2_get_string(&buf, &value, &value_len);]====] [====[                    if(_libssh2_get_string(&buf, &name, &name_len))
                        break;
                    if(_libssh2_get_string(&buf, &value, &value_len))
                        break;]====] _source "${_source}")
    file(WRITE "${view}/src/packet.c" "${_source}")
    file(SHA256 "${view}/src/packet.c" _output_sha)
    if(NOT _output_sha STREQUAL "6ec4270e721ec1e0a5e57af52f59006b87438568bcca6057eb76cdcfd3a0b6ca")
        message(FATAL_ERROR "libssh2 security backport output mismatch: packet.c")
    endif()
    file(SHA256 "${view}/src/transport.c" _input_sha)
    if(NOT _input_sha STREQUAL "adcbdc912a3de76fc87a9018feae1ebac2bfe3705b34ddedb3ff47eea144fbc9")
        message(FATAL_ERROR "Unexpected original libssh2 1.11.1 source: transport.c")
    endif()
    file(READ "${view}/src/transport.c" _source)
    string(REPLACE [====[                p->packet_length = _libssh2_ntohu32(block);
                if(p->packet_length < 1)
                    return LIBSSH2_ERROR_DECRYPT;]====] [====[                p->packet_length = _libssh2_ntohu32(block);
                if(p->packet_length < 1) {
                    return LIBSSH2_ERROR_DECRYPT;
                }
                else if(p->packet_length > LIBSSH2_PACKET_MAXPAYLOAD) {
                    return LIBSSH2_ERROR_OUT_OF_BOUNDARY;
                }]====] _source "${_source}")
    file(WRITE "${view}/src/transport.c" "${_source}")
    file(SHA256 "${view}/src/transport.c" _output_sha)
    if(NOT _output_sha STREQUAL "e3efa18d958d78b22fd465a94db329da93d3bd935787c5e50ae11b368719aee9")
        message(FATAL_ERROR "libssh2 security backport output mismatch: transport.c")
    endif()
    file(SHA256 "${view}/src/sftp.c" _input_sha)
    if(NOT _input_sha STREQUAL "99246f4fb07c99467fdea51d75263e1f56d1888d5e24195b3f46ad77436557e5")
        message(FATAL_ERROR "Unexpected original libssh2 1.11.1 source: sftp.c")
    endif()
    file(READ "${view}/src/sftp.c" _source)
    string(REPLACE [====[static int sftp_symlink(LIBSSH2_SFTP *sftp, const char *path,
                        unsigned int path_len, char *target,
                        unsigned int target_len, int link_type)
{
    LIBSSH2_CHANNEL *channel = sftp->channel;
    LIBSSH2_SESSION *session = channel->session;
    size_t data_len = 0, link_len;
    /* 13 = packet_len(4) + packet_type(1) + request_id(4) + path_len(4) */
    ssize_t packet_len =
        path_len + 13 +
        ((link_type == LIBSSH2_SFTP_SYMLINK) ? (4 + target_len) : 0);
    unsigned char *s, *data = NULL;
    static const unsigned char link_responses[2] =
        { SSH_FXP_NAME, SSH_FXP_STATUS };
    int retcode;

    if(sftp->symlink_state == libssh2_NB_state_idle) {
        sftp->last_errno = LIBSSH2_FX_OK;

        if((sftp->version < 3) && (link_type != LIBSSH2_SFTP_REALPATH)) {
            return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                                  "Server does not support SYMLINK or"
                                  " READLINK");
        }

        s = sftp->symlink_packet = LIBSSH2_ALLOC(session, packet_len);
        if(!sftp->symlink_packet) {
            return _libssh2_error(session, LIBSSH2_ERROR_ALLOC,
                                  "Unable to allocate memory for "
                                  "SYMLINK/READLINK/REALPATH packet");
        }

        _libssh2_debug((session, LIBSSH2_TRACE_SFTP, "%s %s on %s",
                       (link_type ==
                        LIBSSH2_SFTP_SYMLINK) ? "Creating" : "Reading",
                       (link_type ==
                        LIBSSH2_SFTP_REALPATH) ? "realpath" : "symlink",
                       path));

        _libssh2_store_u32(&s, (uint32_t)(packet_len - 4));

        switch(link_type) {
        case LIBSSH2_SFTP_REALPATH:
            *(s++) = SSH_FXP_REALPATH;
            break;

        case LIBSSH2_SFTP_SYMLINK:
            *(s++) = SSH_FXP_SYMLINK;
            break;

        case LIBSSH2_SFTP_READLINK:
        default:
            *(s++) = SSH_FXP_READLINK;
        }
        sftp->symlink_request_id = sftp->request_id++;
        _libssh2_store_u32(&s, sftp->symlink_request_id);
        _libssh2_store_str(&s, path, path_len);

        if(link_type == LIBSSH2_SFTP_SYMLINK)
            _libssh2_store_str(&s, target, target_len);

        sftp->symlink_state = libssh2_NB_state_created;
    }

    if(sftp->symlink_state == libssh2_NB_state_created) {
        ssize_t rc = _libssh2_channel_write(channel, 0, sftp->symlink_packet,
                                            packet_len);
        if(rc == LIBSSH2_ERROR_EAGAIN)
            return (int)rc;
        else if(packet_len != rc) {
            LIBSSH2_FREE(session, sftp->symlink_packet);
            sftp->symlink_packet = NULL;
            sftp->symlink_state = libssh2_NB_state_idle;
            return _libssh2_error(session, LIBSSH2_ERROR_SOCKET_SEND,
                                  "Unable to send SYMLINK/READLINK command");
        }
        LIBSSH2_FREE(session, sftp->symlink_packet);
        sftp->symlink_packet = NULL;

        sftp->symlink_state = libssh2_NB_state_sent;
    }

    retcode = sftp_packet_requirev(sftp, 2, link_responses,
                                   sftp->symlink_request_id, &data,
                                   &data_len, 9);
    if(retcode == LIBSSH2_ERROR_EAGAIN)
        return retcode;
    else if(retcode == LIBSSH2_ERROR_BUFFER_TOO_SMALL) {
        if(data_len > 0) {
            LIBSSH2_FREE(session, data);
        }
        return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                              "SFTP symlink packet too short");
    }
    else if(retcode) {
        sftp->symlink_state = libssh2_NB_state_idle;
        return _libssh2_error(session, retcode,
                              "Error waiting for status message");
    }

    sftp->symlink_state = libssh2_NB_state_idle;

    if(data[0] == SSH_FXP_STATUS) {
        retcode = _libssh2_ntohu32(data + 5);
        LIBSSH2_FREE(session, data);
        if(retcode == LIBSSH2_FX_OK)
            return LIBSSH2_ERROR_NONE;
        else {
            sftp->last_errno = retcode;
            return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                                  "SFTP Protocol Error");
        }
    }

    if(_libssh2_ntohu32(data + 5) < 1) {
        LIBSSH2_FREE(session, data);
        return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                              "Invalid READLINK/REALPATH response, "
                              "no name entries");
    }

    if(data_len < 13) {
        if(data_len > 0) {
            LIBSSH2_FREE(session, data);
        }
        return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                              "SFTP stat packet too short");
    }

    /* this reads a u32 and stores it into a signed 32bit value */
    link_len = _libssh2_ntohu32(data + 9);
    if(link_len < target_len) {
        memcpy(target, data + 13, link_len);
        target[link_len] = 0;
        retcode = (int)link_len;
    }
    else
        retcode = LIBSSH2_ERROR_BUFFER_TOO_SMALL;
    LIBSSH2_FREE(session, data);

    return retcode;
}

]====] [====[static int sftp_symlink(LIBSSH2_SFTP *sftp, const char *path,
                        unsigned int path_len, char *target,
                        unsigned int target_len, int link_type)
{
    LIBSSH2_CHANNEL *channel = sftp->channel;
    LIBSSH2_SESSION *session = channel->session;
    size_t data_len = 0, lk_len;
    /* 13 = packet_len(4) + packet_type(1) + request_id(4) + path_len(4) */
    ssize_t packet_len =
        path_len + 13 +
        ((link_type == LIBSSH2_SFTP_SYMLINK) ? (4 + target_len) : 0);
    unsigned char *s, *data = NULL;
    struct string_buf buf;
    static const unsigned char link_responses[2] =
        { SSH_FXP_NAME, SSH_FXP_STATUS };
    int retcode;
    unsigned char packet_type;
    uint32_t tmp_u32;
    unsigned char *lk_target;

    if(sftp->symlink_state == libssh2_NB_state_idle) {
        sftp->last_errno = LIBSSH2_FX_OK;

        if((sftp->version < 3) && (link_type != LIBSSH2_SFTP_REALPATH)) {
            return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                                  "Server does not support SYMLINK or"
                                  " READLINK");
        }

        s = sftp->symlink_packet = LIBSSH2_ALLOC(session, packet_len);
        if(!sftp->symlink_packet) {
            return _libssh2_error(session, LIBSSH2_ERROR_ALLOC,
                                  "Unable to allocate memory for "
                                  "SYMLINK/READLINK/REALPATH packet");
        }

        _libssh2_debug((session, LIBSSH2_TRACE_SFTP, "%s %s on %s",
                       (link_type ==
                        LIBSSH2_SFTP_SYMLINK) ? "Creating" : "Reading",
                       (link_type ==
                        LIBSSH2_SFTP_REALPATH) ? "realpath" : "symlink",
                       path));

        _libssh2_store_u32(&s, (uint32_t)(packet_len - 4));

        switch(link_type) {
        case LIBSSH2_SFTP_REALPATH:
            *(s++) = SSH_FXP_REALPATH;
            break;

        case LIBSSH2_SFTP_SYMLINK:
            *(s++) = SSH_FXP_SYMLINK;
            break;

        case LIBSSH2_SFTP_READLINK:
        default:
            *(s++) = SSH_FXP_READLINK;
        }
        sftp->symlink_request_id = sftp->request_id++;
        _libssh2_store_u32(&s, sftp->symlink_request_id);
        _libssh2_store_str(&s, path, path_len);

        if(link_type == LIBSSH2_SFTP_SYMLINK)
            _libssh2_store_str(&s, target, target_len);

        sftp->symlink_state = libssh2_NB_state_created;
    }

    if(sftp->symlink_state == libssh2_NB_state_created) {
        ssize_t rc = _libssh2_channel_write(channel, 0, sftp->symlink_packet,
                                            packet_len);
        if(rc == LIBSSH2_ERROR_EAGAIN)
            return (int)rc;
        else if(packet_len != rc) {
            LIBSSH2_FREE(session, sftp->symlink_packet);
            sftp->symlink_packet = NULL;
            sftp->symlink_state = libssh2_NB_state_idle;
            return _libssh2_error(session, LIBSSH2_ERROR_SOCKET_SEND,
                                  "Unable to send SYMLINK/READLINK command");
        }
        LIBSSH2_FREE(session, sftp->symlink_packet);
        sftp->symlink_packet = NULL;

        sftp->symlink_state = libssh2_NB_state_sent;
    }

    retcode = sftp_packet_requirev(sftp, 2, link_responses,
                                   sftp->symlink_request_id, &data,
                                   &data_len, 9);
    if(retcode == LIBSSH2_ERROR_EAGAIN)
        return retcode;
    else if(retcode == LIBSSH2_ERROR_BUFFER_TOO_SMALL) {
        if(data_len > 0) {
            LIBSSH2_FREE(session, data);
        }
        return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                              "SFTP symlink packet too short");
    }
    else if(retcode) {
        sftp->symlink_state = libssh2_NB_state_idle;
        return _libssh2_error(session, retcode,
                              "Error waiting for status message");
    }

    sftp->symlink_state = libssh2_NB_state_idle;

    buf.data = data;
    buf.dataptr = buf.data;
    buf.len = data_len;

    if(_libssh2_get_byte(&buf, &packet_type)) {
        LIBSSH2_FREE(session, data);
        return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                              "SFTP Protocol Error (type)");
    }

    /* advance past id (also before parsing a STATUS response) */
    if(_libssh2_get_u32(&buf, &tmp_u32)) {
        LIBSSH2_FREE(session, data);
        return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                              "SFTP Protocol Error (id)");
    }

    if(packet_type == SSH_FXP_STATUS) {
        if(_libssh2_get_u32(&buf, &tmp_u32)) {
            LIBSSH2_FREE(session, data);
            return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                                  "SFTP Protocol Error (code)");
        }
        retcode = (int)tmp_u32;
        LIBSSH2_FREE(session, data);
        if(retcode == LIBSSH2_FX_OK)
            return LIBSSH2_ERROR_NONE;
        else {
            sftp->last_errno = retcode;
            return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                                  "SFTP Protocol Error");
        }
    }

    /* SYMLINK is answered with STATUS only; target is input in that case. */
    if(link_type == LIBSSH2_SFTP_SYMLINK) {
        LIBSSH2_FREE(session, data);
        return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                              "SFTP Protocol Error (unexpected SYMLINK reply)");
    }

    if(_libssh2_get_u32(&buf, &tmp_u32) || tmp_u32 < 1) {
        LIBSSH2_FREE(session, data);
        return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                              "Invalid READLINK/REALPATH response, "
                              "no name entries");
    }

    if(_libssh2_get_string(&buf, &lk_target, &lk_len) == LIBSSH2_ERROR_NONE) {
        if(lk_len < target_len) {
            memcpy(target, lk_target, lk_len);
            target[lk_len] = '\0';
            retcode = (int)lk_len;
        }
        else {
            retcode = LIBSSH2_ERROR_BUFFER_TOO_SMALL;
        }
    }
    else {
        LIBSSH2_FREE(session, data);
        return _libssh2_error(session, LIBSSH2_ERROR_SFTP_PROTOCOL,
                              "SFTP Protocol Error (filename)");
    }
    LIBSSH2_FREE(session, data);

    return retcode;
}

]====] _source "${_source}")
    file(WRITE "${view}/src/sftp.c" "${_source}")
    file(SHA256 "${view}/src/sftp.c" _output_sha)
    if(NOT _output_sha STREQUAL "7436463816a4d761ee55e8ed28c163ff4211c18a1f5efb44e3743f81122586df")
        message(FATAL_ERROR "libssh2 security backport output mismatch: sftp.c")
    endif()
endfunction()
