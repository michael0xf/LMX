# Generated from pinned release bytes. The vendor trees remain unchanged.
function(lmx_platform_c99_view name original destination)
  get_filename_component(original "${original}" REALPATH)
  file(MAKE_DIRECTORY "${destination}")
  file(COPY "${original}/" DESTINATION "${destination}")
  if(name STREQUAL "apr-util")
    set(_file "${original}/hooks/apr_hooks.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "a7b5e364a4e7503b55fa105c5be22154d1e39043ae1d07cc9493caa7c441bd7a")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[#endif
    if(!s_phOptionalFunctions)
        return NULL;
    return (void(*)(void))apr_hash_get(s_phOptionalFunctions,szName,strlen(szName));
}

/* Deprecated */
]====] [====[#endif
    if(!s_phOptionalFunctions)
        return NULL;
    /* LMX C99 build view: store a pointer to a typed callback cell. */
    {
        apr_opt_fn_t **cell = apr_hash_get(s_phOptionalFunctions,szName,strlen(szName));
        return cell ? *cell : NULL;
    }
}

/* Deprecated */
]====] _text "${_text}")
    string(REPLACE [====[#endif
    if(!s_phOptionalFunctions)
        s_phOptionalFunctions=apr_hash_make(apr_hook_global_pool);
    apr_hash_set(s_phOptionalFunctions,szName,strlen(szName),(void *)pfn);
}

#if 0
]====] [====[#endif
    if(!s_phOptionalFunctions)
        s_phOptionalFunctions=apr_hash_make(apr_hook_global_pool);
    /* LMX C99 build view: preserve NULL-as-remove without function/object casts. */
    if (pfn) {
        apr_opt_fn_t **cell = apr_palloc(apr_hook_global_pool, sizeof(*cell));
        *cell = pfn;
        apr_hash_set(s_phOptionalFunctions,szName,strlen(szName),cell);
    } else {
        apr_hash_set(s_phOptionalFunctions,szName,strlen(szName),NULL);
    }
}

#if 0
]====] _text "${_text}")
    file(WRITE "${destination}/hooks/apr_hooks.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/core/unix/SDL_gtk.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "a652e5a825b8a562a010c5bb227587a4f8da0adce648a276899be0a907a70d11")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[#include <errno.h>
#include <unistd.h>

#define SDL_GTK_SYM2_OPTIONAL(ctx, lib, sub, fn, sym)                     \
    ctx.sub.fn = (void *)SDL_LoadFunction(lib, #sym)

#define SDL_GTK_SYM2(ctx, lib, sub, fn, sym)                              \
    SDL_GTK_SYM2_OPTIONAL(ctx, lib, sub, fn, sym);                        \
]====] [====[#include <errno.h>
#include <unistd.h>

/* LMX C99 build view: copy the platform loader's function-pointer representation. */
#define SDL_GTK_SYM2_OPTIONAL(ctx, lib, sub, fn, sym)                     \
    do {                                                                 \
        SDL_FunctionPointer lmx_symbol = SDL_LoadFunction(lib, #sym);      \
        typedef char lmx_same_size[(sizeof(ctx.sub.fn) == sizeof(lmx_symbol)) ? 1 : -1]; \
        (void)sizeof(lmx_same_size);                                      \
        ctx.sub.fn = NULL;                                               \
        if (lmx_symbol) SDL_memcpy(&ctx.sub.fn, &lmx_symbol, sizeof(ctx.sub.fn)); \
    } while (0)

#define SDL_GTK_SYM2(ctx, lib, sub, fn, sym)                              \
    SDL_GTK_SYM2_OPTIONAL(ctx, lib, sub, fn, sym);                        \
]====] _text "${_text}")
    string(REPLACE [====[static SDL_GtkContext gtk;
static GMainContext *sdl_main_context;

static gulong signal_connect(gpointer instance, const gchar *detailed_signal, void *c_handler, gpointer data)
{
    return gtk.g.signal_connect_data(instance, detailed_signal, SDL_G_CALLBACK(c_handler), data, NULL, (SDL_GConnectFlags)0);
}
]====] [====[static SDL_GtkContext gtk;
static GMainContext *sdl_main_context;

static gulong signal_connect(gpointer instance, const gchar *detailed_signal, GCallback c_handler, gpointer data)
{
    return gtk.g.signal_connect_data(instance, detailed_signal, SDL_G_CALLBACK(c_handler), data, NULL, (SDL_GConnectFlags)0);
}
]====] _text "${_text}")
    file(WRITE "${destination}/src/core/unix/SDL_gtk.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/core/unix/SDL_gtk.h")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "5141719a988063427f6a2b0b4ac6ba069c7160e744254b276a7e8f89450865b3")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[	/* Glib 2.0 */
	struct
	{
		gulong (*signal_connect)(gpointer instance, const gchar *detailed_signal, void *c_handler, gpointer data);
		gulong (*signal_connect_data)(gpointer instance, const gchar *detailed_signal, GCallback c_handler, gpointer data, GClosureNotify destroy_data, SDL_GConnectFlags connect_flags);
		void (*object_unref)(gpointer object);
		gchar *(*mkdtemp)(gchar *template);
]====] [====[	/* Glib 2.0 */
	struct
	{
		gulong (*signal_connect)(gpointer instance, const gchar *detailed_signal, GCallback c_handler, gpointer data) /* LMX C99: callback is a function pointer */;
		gulong (*signal_connect_data)(gpointer instance, const gchar *detailed_signal, GCallback c_handler, gpointer data, GClosureNotify destroy_data, SDL_GConnectFlags connect_flags);
		void (*object_unref)(gpointer object);
		gchar *(*mkdtemp)(gchar *template);
]====] _text "${_text}")
    file(WRITE "${destination}/src/core/unix/SDL_gtk.h" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/dynapi/SDL_dynapi.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "da79192249a4a246fc06eae2c800a9edc1f2c22f0f0aa377cc12e946811441e2")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[                char ch = *ptr;
                if ((ch == ',') || (ch == '\0')) {
                    *ptr = '\0';
                    entry = (SDL_DYNAPI_ENTRYFN)get_sdlapi_entry(libname, "SDL_DYNAPI_entry");
                    *ptr = ch;
                    libname = (ch == '\0') ? ptr : (ptr + 1);
                    break;
]====] [====[                char ch = *ptr;
                if ((ch == ',') || (ch == '\0')) {
                    *ptr = '\0';
                    /* LMX C99 build view: POSIX/Win32 loader address representation.
                       Copy object representation without an ISO-forbidden cast;
                       SDL itself cannot be called before its jump table is ready. */
                    {
                        void *address = get_sdlapi_entry(libname, "SDL_DYNAPI_entry");
                        typedef char lmx_loader_pointer_sizes_must_match[(sizeof(entry) == sizeof(address)) ? 1 : -1];
                        size_t i;
                        const unsigned char *from = (const unsigned char *)&address;
                        unsigned char *to = (unsigned char *)&entry;
                        (void)sizeof(lmx_loader_pointer_sizes_must_match);
                        for (i = 0; i < sizeof(entry); ++i) to[i] = from[i];
                    }
                    *ptr = ch;
                    libname = (ch == '\0') ? ptr : (ptr + 1);
                    break;
]====] _text "${_text}")
    file(WRITE "${destination}/src/dynapi/SDL_dynapi.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/io/SDL_iostream.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "b9c4e6d5af4dc93855af42a418a64bc5bd0bc66afee2aa4e8762bd8269b1a0c4")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[static bool SDLCALL mem_close(void *userdata)
{
    IOStreamMemData *iodata = (IOStreamMemData *) userdata;
    SDL_free_func free_func = SDL_GetPointerProperty(iodata->props, SDL_PROP_IOSTREAM_MEMORY_FREE_FUNC_POINTER, NULL);
    if (free_func) {
        free_func(iodata->base);
    }
]====] [====[static bool SDLCALL mem_close(void *userdata)
{
    IOStreamMemData *iodata = (IOStreamMemData *) userdata;
    /* LMX C99 build view: the public property stores a callback address
       in SDL's platform pointer representation. Keep null handling typed. */
    void *free_address = SDL_GetPointerProperty(iodata->props, SDL_PROP_IOSTREAM_MEMORY_FREE_FUNC_POINTER, NULL);
    SDL_free_func free_func = NULL;
    typedef char lmx_free_pointer_sizes_must_match[(sizeof(free_func) == sizeof(free_address)) ? 1 : -1];
    (void)sizeof(lmx_free_pointer_sizes_must_match);
    if (free_address) SDL_memcpy(&free_func, &free_address, sizeof(free_func));
    if (free_func) {
        free_func(iodata->base);
    }
]====] _text "${_text}")
    file(WRITE "${destination}/src/io/SDL_iostream.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/joystick/hidapi/SDL_hidapi_sinput.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "c76565e40adc6bc074720dcc439d48c463b0c027ed722bc6c1e203a09b02839f")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[            } right;

        } type_2;
    };
} SINPUT_HAPTIC_S;

typedef struct
]====] [====[            } right;

        } type_2;
    } payload; /* LMX C99: named union preserves representation. */
} SINPUT_HAPTIC_S;

typedef struct
]====] _text "${_text}")
    string(REPLACE [====[    // Type of haptics
    out[0] = 2;

    out[1] = in->type_2.left.amplitude;
    out[2] = in->type_2.left.brake;

    out[3] = in->type_2.right.amplitude;
    out[4] = in->type_2.right.brake;
}

static void HIDAPI_DriverSInput_RegisterHints(SDL_HintCallback callback, void *userdata)
]====] [====[    // Type of haptics
    out[0] = 2;

    out[1] = in->payload.type_2.left.amplitude;
    out[2] = in->payload.type_2.left.brake;

    out[3] = in->payload.type_2.right.amplitude;
    out[4] = in->payload.type_2.right.brake;
}

static void HIDAPI_DriverSInput_RegisterHints(SDL_HintCallback callback, void *userdata)
]====] _text "${_text}")
    string(REPLACE [====[
        // Low Frequency  = Left
        // High Frequency = Right
        hapticData.type_2.left.amplitude = (Uint8) (low_frequency_rumble >> 8);
        hapticData.type_2.right.amplitude = (Uint8)(high_frequency_rumble >> 8);

        HapticsType2Pack(&hapticData, &(hapticReport[2]));

]====] [====[
        // Low Frequency  = Left
        // High Frequency = Right
        hapticData.payload.type_2.left.amplitude = (Uint8) (low_frequency_rumble >> 8);
        hapticData.payload.type_2.right.amplitude = (Uint8)(high_frequency_rumble >> 8);

        HapticsType2Pack(&hapticData, &(hapticReport[2]));

]====] _text "${_text}")
    file(WRITE "${destination}/src/joystick/hidapi/SDL_hidapi_sinput.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/joystick/hidapi/SDL_hidapi_steamdeck.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "fc746697ff17feefafea773104c866c573d743d856095b556a9d1edb5956ee72")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[    SDL_DriverSteamDeck_Context *ctx = (SDL_DriverSteamDeck_Context *)device->context;
    Uint64 timestamp = SDL_GetTicksNS();

    if (pInReport->payload.deckState.ulButtons != ctx->last_button_state) {
        Uint8 hat = 0;

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_SOUTH,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_A) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_EAST,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_B) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_WEST,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_X) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_NORTH,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_Y) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_LEFT_SHOULDER,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_L) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_R) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_BACK,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_VIEW) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_START,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_MENU) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_GUIDE,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_STEAM) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_QAM,
                               ((pInReport->payload.deckState.ulButtonsH & STEAMDECK_HBUTTON_QAM) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_LEFT_STICK,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_L3) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_RIGHT_STICK,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_R3) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_RIGHT_PADDLE1,
                               ((pInReport->payload.deckState.ulButtonsH & STEAMDECK_HBUTTON_R4) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_LEFT_PADDLE1,
                               ((pInReport->payload.deckState.ulButtonsH & STEAMDECK_HBUTTON_L4) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_RIGHT_PADDLE2,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_R5) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_LEFT_PADDLE2,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_L5) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_RIGHT_TOUCHPAD,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_RIGHT_PAD) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_LEFT_TOUCHPAD,
                               ((pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_LEFT_PAD) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_RIGHT_JOYSTICK_TOUCH,
                               ((pInReport->payload.deckState.ulButtonsH & STEAMDECK_HBUTTON_RSTICK_TOUCH) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_LEFT_JOYSTICK_TOUCH,
                               ((pInReport->payload.deckState.ulButtonsH & STEAMDECK_HBUTTON_LSTICK_TOUCH) != 0));

        if (pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_DPAD_UP) {
            hat |= SDL_HAT_UP;
        }
        if (pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_DPAD_DOWN) {
            hat |= SDL_HAT_DOWN;
        }
        if (pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_DPAD_LEFT) {
            hat |= SDL_HAT_LEFT;
        }
        if (pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_DPAD_RIGHT) {
            hat |= SDL_HAT_RIGHT;
        }
        SDL_SendJoystickHat(timestamp, joystick, 0, hat);

        ctx->last_button_state = pInReport->payload.deckState.ulButtons;
    }

    SDL_SendJoystickAxis(timestamp, joystick, SDL_GAMEPAD_AXIS_LEFT_TRIGGER,
]====] [====[    SDL_DriverSteamDeck_Context *ctx = (SDL_DriverSteamDeck_Context *)device->context;
    Uint64 timestamp = SDL_GetTicksNS();

    if (pInReport->payload.deckState.buttons.ulButtons != ctx->last_button_state) {
        Uint8 hat = 0;

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_SOUTH,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_A) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_EAST,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_B) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_WEST,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_X) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_NORTH,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_Y) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_LEFT_SHOULDER,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_L) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_R) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_BACK,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_VIEW) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_START,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_MENU) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_GUIDE,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_STEAM) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_QAM,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsH & STEAMDECK_HBUTTON_QAM) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_LEFT_STICK,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_L3) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_RIGHT_STICK,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_R3) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_RIGHT_PADDLE1,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsH & STEAMDECK_HBUTTON_R4) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_LEFT_PADDLE1,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsH & STEAMDECK_HBUTTON_L4) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_RIGHT_PADDLE2,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_R5) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_LEFT_PADDLE2,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_L5) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_RIGHT_TOUCHPAD,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_RIGHT_PAD) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_LEFT_TOUCHPAD,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_LEFT_PAD) != 0));

        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_RIGHT_JOYSTICK_TOUCH,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsH & STEAMDECK_HBUTTON_RSTICK_TOUCH) != 0));
        SDL_SendJoystickButton(timestamp, joystick, SDL_GAMEPAD_BUTTON_STEAM_DECK_LEFT_JOYSTICK_TOUCH,
                               ((pInReport->payload.deckState.buttons.halves.ulButtonsH & STEAMDECK_HBUTTON_LSTICK_TOUCH) != 0));

        if (pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_DPAD_UP) {
            hat |= SDL_HAT_UP;
        }
        if (pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_DPAD_DOWN) {
            hat |= SDL_HAT_DOWN;
        }
        if (pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_DPAD_LEFT) {
            hat |= SDL_HAT_LEFT;
        }
        if (pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_DPAD_RIGHT) {
            hat |= SDL_HAT_RIGHT;
        }
        SDL_SendJoystickHat(timestamp, joystick, 0, hat);

        ctx->last_button_state = pInReport->payload.deckState.buttons.ulButtons;
    }

    SDL_SendJoystickAxis(timestamp, joystick, SDL_GAMEPAD_AXIS_LEFT_TRIGGER,
]====] _text "${_text}")
    string(REPLACE [====[    values[2] = (-pInReport->payload.deckState.sAccelY / 32768.0f) * 2.0f * SDL_STANDARD_GRAVITY;
    SDL_SendJoystickSensor(timestamp, joystick, SDL_SENSOR_ACCEL, ctx->sensor_timestamp_ns, values, 3);

    bool left_touch_down = (pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_LEFT_TOUCHPAD_TOUCH) ? true : false;
    bool right_touch_down = (pInReport->payload.deckState.ulButtonsL & STEAMDECK_LBUTTON_RIGHT_TOUCHPAD_TOUCH) ? true : false;
    if (left_touch_down || ctx->left_touch_down) {
        if (left_touch_down) {
            ctx->left_touch_x = pInReport->payload.deckState.sLeftPadX / 65536.0f + 0.5f;
]====] [====[    values[2] = (-pInReport->payload.deckState.sAccelY / 32768.0f) * 2.0f * SDL_STANDARD_GRAVITY;
    SDL_SendJoystickSensor(timestamp, joystick, SDL_SENSOR_ACCEL, ctx->sensor_timestamp_ns, values, 3);

    bool left_touch_down = (pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_LEFT_TOUCHPAD_TOUCH) ? true : false;
    bool right_touch_down = (pInReport->payload.deckState.buttons.halves.ulButtonsL & STEAMDECK_LBUTTON_RIGHT_TOUCHPAD_TOUCH) ? true : false;
    if (left_touch_down || ctx->left_touch_down) {
        if (left_touch_down) {
            ctx->left_touch_x = pInReport->payload.deckState.sLeftPadX / 65536.0f + 0.5f;
]====] _text "${_text}")
    file(WRITE "${destination}/src/joystick/hidapi/SDL_hidapi_steamdeck.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/joystick/hidapi/SDL_hidapi_switch.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "bdea6f8261f3951f8040e71f6a5edb6cb09cef54e55b719c516a793cd2cc4970")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[            Uint8 rgucRightMagic[2];
            Uint8 rgucRightCalibration[9];
        } stickUserCalibration;
    };
} SwitchSubcommandInputPacket_t;

typedef struct
]====] [====[            Uint8 rgucRightMagic[2];
            Uint8 rgucRightCalibration[9];
        } stickUserCalibration;
    } payload; /* LMX C99: preserve the packet layout with a named union. */
} SwitchSubcommandInputPacket_t;

typedef struct
]====] _text "${_text}")
    string(REPLACE [====[                if (reply->ucSubcommandID == k_eSwitchSubcommandIDs_SPIFlashRead) {
                    SDL_assert(ucLen == sizeof(SwitchSPIOpData_t));
                    const SwitchSPIOpData_t *request = (const SwitchSPIOpData_t *)pBuf;
                    if (reply->spiReadData.opData.unAddress != request->unAddress ||
                        reply->spiReadData.opData.ucLength < request->ucLength) {
                        // This was a reply for another SPI read command
                        continue;
                    }
]====] [====[                if (reply->ucSubcommandID == k_eSwitchSubcommandIDs_SPIFlashRead) {
                    SDL_assert(ucLen == sizeof(SwitchSPIOpData_t));
                    const SwitchSPIOpData_t *request = (const SwitchSPIOpData_t *)pBuf;
                    if (reply->payload.spiReadData.opData.unAddress != request->unAddress ||
                        reply->payload.spiReadData.opData.ucLength < request->ucLength) {
                        // This was a reply for another SPI read command
                        continue;
                    }
]====] _text "${_text}")
    string(REPLACE [====[    if (ctx->device->is_bluetooth) {
        if (WriteSubcommand(ctx, k_eSwitchSubcommandIDs_RequestDeviceInfo, NULL, 0, &reply)) {
            // Byte 2: Controller ID (1=LJC, 2=RJC, 3=Pro)
            ctx->m_eControllerType = CalculateControllerType(ctx, (ESwitchDeviceInfoControllerType)reply->deviceInfo.ucDeviceType);

            // Bytes 4-9: MAC address (big-endian)
            SDL_memcpy(ctx->m_rgucMACAddress, reply->deviceInfo.rgucMACAddress, sizeof(ctx->m_rgucMACAddress));

            return true;
        }
]====] [====[    if (ctx->device->is_bluetooth) {
        if (WriteSubcommand(ctx, k_eSwitchSubcommandIDs_RequestDeviceInfo, NULL, 0, &reply)) {
            // Byte 2: Controller ID (1=LJC, 2=RJC, 3=Pro)
            ctx->m_eControllerType = CalculateControllerType(ctx, (ESwitchDeviceInfoControllerType)reply->payload.deviceInfo.ucDeviceType);

            // Bytes 4-9: MAC address (big-endian)
            SDL_memcpy(ctx->m_rgucMACAddress, reply->payload.deviceInfo.rgucMACAddress, sizeof(ctx->m_rgucMACAddress));

            return true;
        }
]====] _text "${_text}")
    string(REPLACE [====[    readFactoryParams.ucLength = k_unSPIStickFactoryCalibrationLength;

    // Automatically select the user calibration if magic bytes are set
    if (user_reply && user_reply->stickUserCalibration.rgucLeftMagic[0] == 0xB2 && user_reply->stickUserCalibration.rgucLeftMagic[1] == 0xA1) {
        have_left_stick_cal = true;
        SDL_memcpy(pLeftStickCal, user_reply->stickUserCalibration.rgucLeftCalibration, sizeof(pLeftStickCal));
    }

    if (user_reply && user_reply->stickUserCalibration.rgucRightMagic[0] == 0xB2 && user_reply->stickUserCalibration.rgucRightMagic[1] == 0xA1) {
        have_right_stick_cal = true;
        SDL_memcpy(pRightStickCal, user_reply->stickUserCalibration.rgucRightCalibration, sizeof(pRightStickCal));
    }

    // Only read the factory calibration info if we failed to receive the correct magic bytes
]====] [====[    readFactoryParams.ucLength = k_unSPIStickFactoryCalibrationLength;

    // Automatically select the user calibration if magic bytes are set
    if (user_reply && user_reply->payload.stickUserCalibration.rgucLeftMagic[0] == 0xB2 && user_reply->payload.stickUserCalibration.rgucLeftMagic[1] == 0xA1) {
        have_left_stick_cal = true;
        SDL_memcpy(pLeftStickCal, user_reply->payload.stickUserCalibration.rgucLeftCalibration, sizeof(pLeftStickCal));
    }

    if (user_reply && user_reply->payload.stickUserCalibration.rgucRightMagic[0] == 0xB2 && user_reply->payload.stickUserCalibration.rgucRightMagic[1] == 0xA1) {
        have_right_stick_cal = true;
        SDL_memcpy(pRightStickCal, user_reply->payload.stickUserCalibration.rgucRightCalibration, sizeof(pRightStickCal));
    }

    // Only read the factory calibration info if we failed to receive the correct magic bytes
]====] _text "${_text}")
    string(REPLACE [====[            // Avoid overriding user calibration if it's present for only one stick (known to happen on JoyCons)
            if (!have_left_stick_cal) {
                have_left_stick_cal = true;
                SDL_memcpy(pLeftStickCal, factory_reply->stickFactoryCalibration.rgucLeftCalibration, sizeof(pLeftStickCal));
            }
            if (!have_right_stick_cal) {
                have_right_stick_cal = true;
                SDL_memcpy(pRightStickCal, factory_reply->stickFactoryCalibration.rgucRightCalibration, sizeof(pRightStickCal));
            }
        }
    }
]====] [====[            // Avoid overriding user calibration if it's present for only one stick (known to happen on JoyCons)
            if (!have_left_stick_cal) {
                have_left_stick_cal = true;
                SDL_memcpy(pLeftStickCal, factory_reply->payload.stickFactoryCalibration.rgucLeftCalibration, sizeof(pLeftStickCal));
            }
            if (!have_right_stick_cal) {
                have_right_stick_cal = true;
                SDL_memcpy(pRightStickCal, factory_reply->payload.stickFactoryCalibration.rgucRightCalibration, sizeof(pRightStickCal));
            }
        }
    }
]====] _text "${_text}")
    string(REPLACE [====[        Sint16 sGyroSensCoeffX, sGyroSensCoeffY, sGyroSensCoeffZ;

        // IMU scale gives us multipliers for converting raw values to real world values
        pIMUScale = reply->spiReadData.rgucReadData;

        sAccelRawX = (pIMUScale[1] << 8) | pIMUScale[0];
        sAccelRawY = (pIMUScale[3] << 8) | pIMUScale[2];
]====] [====[        Sint16 sGyroSensCoeffX, sGyroSensCoeffY, sGyroSensCoeffZ;

        // IMU scale gives us multipliers for converting raw values to real world values
        pIMUScale = reply->payload.spiReadData.rgucReadData;

        sAccelRawX = (pIMUScale[1] << 8) | pIMUScale[0];
        sAccelRawY = (pIMUScale[3] << 8) | pIMUScale[2];
]====] _text "${_text}")
    string(REPLACE [====[        readParams.unAddress = k_unSPIIMUUserScaleStartOffset;
        readParams.ucLength = k_unSPIIMUUserScaleLength;
        if (WriteSubcommand(ctx, k_eSwitchSubcommandIDs_SPIFlashRead, (uint8_t *)&readParams, sizeof(readParams), &reply)) {
            Uint8 *pUserIMUScale = reply->spiReadData.rgucReadData;

            if ((pUserIMUScale[0] | (pUserIMUScale[1] << 8)) == 0xA1B2) {
                pIMUScale = pUserIMUScale;
]====] [====[        readParams.unAddress = k_unSPIIMUUserScaleStartOffset;
        readParams.ucLength = k_unSPIIMUUserScaleLength;
        if (WriteSubcommand(ctx, k_eSwitchSubcommandIDs_SPIFlashRead, (uint8_t *)&readParams, sizeof(readParams), &reply)) {
            Uint8 *pUserIMUScale = reply->payload.spiReadData.rgucReadData;

            if ((pUserIMUScale[0] | (pUserIMUScale[1] << 8)) == 0xA1B2) {
                pIMUScale = pUserIMUScale;
]====] _text "${_text}")
    string(REPLACE [====[                SwitchSubcommandInputPacket_t *reply = NULL;

                if (WriteSubcommand(ctx, k_eSwitchSubcommandIDs_RequestDeviceInfo, NULL, 0, &reply)) {
                    eControllerType = CalculateControllerType(ctx, (ESwitchDeviceInfoControllerType)reply->deviceInfo.ucDeviceType);
                }
            } else {
                if (WriteProprietary(ctx, k_eSwitchProprietaryCommandIDs_Status, NULL, 0, true)) {
]====] [====[                SwitchSubcommandInputPacket_t *reply = NULL;

                if (WriteSubcommand(ctx, k_eSwitchSubcommandIDs_RequestDeviceInfo, NULL, 0, &reply)) {
                    eControllerType = CalculateControllerType(ctx, (ESwitchDeviceInfoControllerType)reply->payload.deviceInfo.ucDeviceType);
                }
            } else {
                if (WriteProprietary(ctx, k_eSwitchProprietaryCommandIDs_Status, NULL, 0, true)) {
]====] _text "${_text}")
    file(WRITE "${destination}/src/joystick/hidapi/SDL_hidapi_switch.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/joystick/hidapi/steam/controller_structs.h")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "6217267bfa7e2b446edd6c45ac78e7603ac937960e7585831423d94d2a10c3b8")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[		{
			Uint32 ulButtonsL;
			Uint32 ulButtonsH;
		};
	};

	// Left pad coordinates
	short sLeftPadX;
]====] [====[		{
			Uint32 ulButtonsL;
			Uint32 ulButtonsH;
		} halves;
	} buttons; /* LMX C99: names do not change packet layout. */

	// Left pad coordinates
	short sLeftPadX;
]====] _text "${_text}")
    file(WRITE "${destination}/src/joystick/hidapi/steam/controller_structs.h" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/loadso/dlopen/SDL_sysloadso.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "c9c469de5a581062f2ab1a9be5f7850585bb9941f5a9a9f7b8bf3da547abd9a9")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[                         (const char *)dlerror());
        }
    }
    return symbol;
}

void SDL_UnloadObject(SDL_SharedObject *handle)
]====] [====[                         (const char *)dlerror());
        }
    }
    /* LMX C99 build view: POSIX dlsym address to SDL callback representation. */
    {
        SDL_FunctionPointer fn = NULL;
        typedef char lmx_loader_pointer_size[(sizeof(fn) == sizeof(symbol)) ? 1 : -1];
        (void)sizeof(lmx_loader_pointer_size);
        if (symbol) SDL_memcpy(&fn, &symbol, sizeof(fn));
        return fn;
    }
}

void SDL_UnloadObject(SDL_SharedObject *handle)
]====] _text "${_text}")
    file(WRITE "${destination}/src/loadso/dlopen/SDL_sysloadso.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/stdlib/SDL_qsort.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "edfdd99506d8e71ed7d53ba485daf9240b7669786755f086c58a25245c122760")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[
static int SDLCALL qsort_non_r_bridge(void *userdata, const void *a, const void *b)
{
    int (SDLCALL *compare)(const void *, const void *) = (int (SDLCALL *)(const void *, const void *)) userdata;
    return compare(a, b);
}

void SDL_qsort(void *base, size_t nmemb, size_t size, SDL_CompareCallback compare)
{
    SDL_qsort_r(base, nmemb, size, qsort_non_r_bridge, compare);
}

// Don't use the C runtime for such a simple function, since we want to allow SDLCALL callbacks and userdata.
]====] [====[
static int SDLCALL qsort_non_r_bridge(void *userdata, const void *a, const void *b)
{
    /* LMX C99 build view: userdata points to a typed synchronous callback cell. */
    SDL_CompareCallback compare = *(SDL_CompareCallback *)userdata;
    return compare(a, b);
}

void SDL_qsort(void *base, size_t nmemb, size_t size, SDL_CompareCallback compare)
{
    SDL_qsort_r(base, nmemb, size, qsort_non_r_bridge, &compare);
}

// Don't use the C runtime for such a simple function, since we want to allow SDLCALL callbacks and userdata.
]====] _text "${_text}")
    string(REPLACE [====[void *SDL_bsearch(const void *key, const void *base, size_t nmemb, size_t size, SDL_CompareCallback compare)
{
    // qsort_non_r_bridge just happens to match calling conventions, so reuse it.
    return SDL_bsearch_r(key, base, nmemb, size, qsort_non_r_bridge, compare);
}
]====] [====[void *SDL_bsearch(const void *key, const void *base, size_t nmemb, size_t size, SDL_CompareCallback compare)
{
    // qsort_non_r_bridge just happens to match calling conventions, so reuse it.
    return SDL_bsearch_r(key, base, nmemb, size, qsort_non_r_bridge, &compare);
}
]====] _text "${_text}")
    file(WRITE "${destination}/src/stdlib/SDL_qsort.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/thread/SDL_thread.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "c29ad13d7bfd9f6df94a325696c3ae0ef5aa4b911876655ed66cc0ffdd0a44b0")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[    }
}

SDL_Thread *SDL_CreateThreadWithPropertiesRuntime(SDL_PropertiesID props,
                              SDL_FunctionPointer pfnBeginThread,
                              SDL_FunctionPointer pfnEndThread)
]====] [====[    }
}

/* LMX C99 build view: SDL public pointer properties encode callback addresses
   according to the platform ABI. These copies avoid function/object casts. */
static SDL_ThreadFunction lmx_thread_function_from_pointer(void *address)
{
    SDL_ThreadFunction fn = NULL;
    typedef char lmx_same_pointer_size[(sizeof(fn) == sizeof(address)) ? 1 : -1];
    (void)sizeof(lmx_same_pointer_size);
    if (address) SDL_memcpy(&fn, &address, sizeof(fn));
    return fn;
}
static void *lmx_thread_function_to_pointer(SDL_ThreadFunction fn)
{
    void *address = NULL;
    typedef char lmx_same_pointer_size[(sizeof(fn) == sizeof(address)) ? 1 : -1];
    (void)sizeof(lmx_same_pointer_size);
    if (fn) SDL_memcpy(&address, &fn, sizeof(address));
    return address;
}

SDL_Thread *SDL_CreateThreadWithPropertiesRuntime(SDL_PropertiesID props,
                              SDL_FunctionPointer pfnBeginThread,
                              SDL_FunctionPointer pfnEndThread)
]====] _text "${_text}")
    string(REPLACE [====[    }
    #endif

    SDL_ThreadFunction fn = (SDL_ThreadFunction) SDL_GetPointerProperty(props, SDL_PROP_THREAD_CREATE_ENTRY_FUNCTION_POINTER, NULL);
    const char *name = SDL_GetStringProperty(props, SDL_PROP_THREAD_CREATE_NAME_STRING, NULL);
    const size_t stacksize = (size_t) SDL_GetNumberProperty(props, SDL_PROP_THREAD_CREATE_STACKSIZE_NUMBER, 0);
    void *userdata = SDL_GetPointerProperty(props, SDL_PROP_THREAD_CREATE_USERDATA_POINTER, NULL);
]====] [====[    }
    #endif

    SDL_ThreadFunction fn = lmx_thread_function_from_pointer(SDL_GetPointerProperty(props, SDL_PROP_THREAD_CREATE_ENTRY_FUNCTION_POINTER, NULL));
    const char *name = SDL_GetStringProperty(props, SDL_PROP_THREAD_CREATE_NAME_STRING, NULL);
    const size_t stacksize = (size_t) SDL_GetNumberProperty(props, SDL_PROP_THREAD_CREATE_STACKSIZE_NUMBER, 0);
    void *userdata = SDL_GetPointerProperty(props, SDL_PROP_THREAD_CREATE_USERDATA_POINTER, NULL);
]====] _text "${_text}")
    string(REPLACE [====[                 SDL_FunctionPointer pfnEndThread)
{
    const SDL_PropertiesID props = SDL_CreateProperties();
    SDL_SetPointerProperty(props, SDL_PROP_THREAD_CREATE_ENTRY_FUNCTION_POINTER, (void *) fn);
    SDL_SetStringProperty(props, SDL_PROP_THREAD_CREATE_NAME_STRING, name);
    SDL_SetPointerProperty(props, SDL_PROP_THREAD_CREATE_USERDATA_POINTER, userdata);
    SDL_Thread *thread = SDL_CreateThreadWithPropertiesRuntime(props, pfnBeginThread, pfnEndThread);
]====] [====[                 SDL_FunctionPointer pfnEndThread)
{
    const SDL_PropertiesID props = SDL_CreateProperties();
    SDL_SetPointerProperty(props, SDL_PROP_THREAD_CREATE_ENTRY_FUNCTION_POINTER, lmx_thread_function_to_pointer(fn));
    SDL_SetStringProperty(props, SDL_PROP_THREAD_CREATE_NAME_STRING, name);
    SDL_SetPointerProperty(props, SDL_PROP_THREAD_CREATE_USERDATA_POINTER, userdata);
    SDL_Thread *thread = SDL_CreateThreadWithPropertiesRuntime(props, pfnBeginThread, pfnEndThread);
]====] _text "${_text}")
    string(REPLACE [====[SDL_Thread *SDL_CreateThreadWithStackSize(SDL_ThreadFunction fn, const char *name, size_t stacksize, void *userdata)
{
    const SDL_PropertiesID props = SDL_CreateProperties();
    SDL_SetPointerProperty(props, SDL_PROP_THREAD_CREATE_ENTRY_FUNCTION_POINTER, (void *) fn);
    SDL_SetStringProperty(props, SDL_PROP_THREAD_CREATE_NAME_STRING, name);
    SDL_SetPointerProperty(props, SDL_PROP_THREAD_CREATE_USERDATA_POINTER, userdata);
    SDL_SetNumberProperty(props, SDL_PROP_THREAD_CREATE_STACKSIZE_NUMBER, (Sint64) stacksize);
]====] [====[SDL_Thread *SDL_CreateThreadWithStackSize(SDL_ThreadFunction fn, const char *name, size_t stacksize, void *userdata)
{
    const SDL_PropertiesID props = SDL_CreateProperties();
    SDL_SetPointerProperty(props, SDL_PROP_THREAD_CREATE_ENTRY_FUNCTION_POINTER, lmx_thread_function_to_pointer(fn));
    SDL_SetStringProperty(props, SDL_PROP_THREAD_CREATE_NAME_STRING, name);
    SDL_SetPointerProperty(props, SDL_PROP_THREAD_CREATE_USERDATA_POINTER, userdata);
    SDL_SetNumberProperty(props, SDL_PROP_THREAD_CREATE_STACKSIZE_NUMBER, (Sint64) stacksize);
]====] _text "${_text}")
    file(WRITE "${destination}/src/thread/SDL_thread.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/thread/pthread/SDL_systhread.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "ba2e97d3c86a38ea9f274e4e323bb06ae0daea43420052a31fa8febe7d077b07")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[#if (defined(SDL_PLATFORM_MACOS) || defined(SDL_PLATFORM_IOS) || defined(SDL_PLATFORM_LINUX) || defined(SDL_PLATFORM_ANDROID)) && defined(HAVE_DLOPEN)
    if (!checked_setname) {
        void *fn = dlsym(RTLD_DEFAULT, "pthread_setname_np");
#if defined(SDL_PLATFORM_MACOS) || defined(SDL_PLATFORM_IOS)
        ppthread_setname_np = (int (*)(const char *))fn;
#elif defined(SDL_PLATFORM_LINUX) || defined(SDL_PLATFORM_ANDROID)
        ppthread_setname_np = (int (*)(pthread_t, const char *))fn;
#endif
        checked_setname = true;
    }
    #endif
]====] [====[#if (defined(SDL_PLATFORM_MACOS) || defined(SDL_PLATFORM_IOS) || defined(SDL_PLATFORM_LINUX) || defined(SDL_PLATFORM_ANDROID)) && defined(HAVE_DLOPEN)
    if (!checked_setname) {
        void *fn = dlsym(RTLD_DEFAULT, "pthread_setname_np");
/* LMX C99: POSIX dlsym ABI, with equal-size representation guard. */
        typedef char lmx_thread_name_pointer_size[(sizeof(ppthread_setname_np) == sizeof(fn)) ? 1 : -1];
        if (fn) SDL_memcpy(&ppthread_setname_np, &fn, sizeof(ppthread_setname_np));
        checked_setname = true;
    }
    #endif
]====] _text "${_text}")
    file(WRITE "${destination}/src/thread/pthread/SDL_systhread.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/tray/unix/SDL_tray.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "67dd1c88b80c5b1c2bf6f390e2605780981f244e70f3d0ead824738bf4a7b33a")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[        return SDL_SetError("Could not load AppIndicator libraries");
    }

    app_indicator_new = dlsym(libappindicator, "app_indicator_new");
    app_indicator_set_status = dlsym(libappindicator, "app_indicator_set_status");
    app_indicator_set_icon = dlsym(libappindicator, "app_indicator_set_icon");
    app_indicator_set_menu = dlsym(libappindicator, "app_indicator_set_menu");

    if (!app_indicator_new ||
        !app_indicator_set_status ||
]====] [====[        return SDL_SetError("Could not load AppIndicator libraries");
    }

    /* LMX C99 build view: POSIX loader pointer representation. */
    {
        void *lmx_symbol = dlsym(libappindicator, "app_indicator_new");
        typedef char lmx_same_size[(sizeof(app_indicator_new) == sizeof(lmx_symbol)) ? 1 : -1];
        (void)sizeof(lmx_same_size);
        app_indicator_new = NULL;
        if (lmx_symbol) SDL_memcpy(&app_indicator_new, &lmx_symbol, sizeof(app_indicator_new));
    }
    /* LMX C99 build view: POSIX loader pointer representation. */
    {
        void *lmx_symbol = dlsym(libappindicator, "app_indicator_set_status");
        typedef char lmx_same_size[(sizeof(app_indicator_set_status) == sizeof(lmx_symbol)) ? 1 : -1];
        (void)sizeof(lmx_same_size);
        app_indicator_set_status = NULL;
        if (lmx_symbol) SDL_memcpy(&app_indicator_set_status, &lmx_symbol, sizeof(app_indicator_set_status));
    }
    /* LMX C99 build view: POSIX loader pointer representation. */
    {
        void *lmx_symbol = dlsym(libappindicator, "app_indicator_set_icon");
        typedef char lmx_same_size[(sizeof(app_indicator_set_icon) == sizeof(lmx_symbol)) ? 1 : -1];
        (void)sizeof(lmx_same_size);
        app_indicator_set_icon = NULL;
        if (lmx_symbol) SDL_memcpy(&app_indicator_set_icon, &lmx_symbol, sizeof(app_indicator_set_icon));
    }
    /* LMX C99 build view: POSIX loader pointer representation. */
    {
        void *lmx_symbol = dlsym(libappindicator, "app_indicator_set_menu");
        typedef char lmx_same_size[(sizeof(app_indicator_set_menu) == sizeof(lmx_symbol)) ? 1 : -1];
        (void)sizeof(lmx_same_size);
        app_indicator_set_menu = NULL;
        if (lmx_symbol) SDL_memcpy(&app_indicator_set_menu, &lmx_symbol, sizeof(app_indicator_set_menu));
    }

    if (!app_indicator_new ||
        !app_indicator_set_status ||
]====] _text "${_text}")
    string(REPLACE [====[    gtk->gtk.widget_show(entry->item);
    gtk->gtk.menu_shell_insert(menu->menu, entry->item, (pos == menu->nEntries) ? -1 : pos);

    gtk->g.signal_connect(entry->item, "activate", call_callback, entry);

    SDL_Gtk_ExitContext(gtk);

]====] [====[    gtk->gtk.widget_show(entry->item);
    gtk->gtk.menu_shell_insert(menu->menu, entry->item, (pos == menu->nEntries) ? -1 : pos);

    gtk->g.signal_connect(entry->item, "activate", SDL_G_CALLBACK(call_callback), entry);

    SDL_Gtk_ExitContext(gtk);

]====] _text "${_text}")
    file(WRITE "${destination}/src/tray/unix/SDL_tray.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/video/SDL_blit.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "e85bed91968aba1d1c0e3c3fdfd7f8b6461e358a1b228a1b340acbbd83aa6dff")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[        info->dst_pitch = dst->pitch;
        info->dst_skip =
            info->dst_pitch - info->dst_w * info->dst_fmt->bytes_per_pixel;
        RunBlit = (SDL_BlitFunc)src->map.data;

        // Run the actual software blit
        RunBlit(info);
]====] [====[        info->dst_pitch = dst->pitch;
        info->dst_skip =
            info->dst_pitch - info->dst_w * info->dst_fmt->bytes_per_pixel;
        /* LMX C99 build view: platform callback-address representation. */
        typedef char lmx_blit_pointer_size[(sizeof(RunBlit) == sizeof(src->map.data)) ? 1 : -1];
        (void)sizeof(lmx_blit_pointer_size);
        RunBlit = NULL;
        if (src->map.data) SDL_memcpy(&RunBlit, &src->map.data, sizeof(RunBlit));

        // Run the actual software blit
        RunBlit(info);
]====] _text "${_text}")
    string(REPLACE [====[            blit = SDL_Blit_Slow;
        }
    }
    map->data = (void *)blit;

    // Make sure we have a blit function
    if (!blit) {
]====] [====[            blit = SDL_Blit_Slow;
        }
    }
    /* LMX C99 build view: inverse of the typed callback-address copy above. */
    {
        typedef char lmx_blit_pointer_size[(sizeof(blit) == sizeof(map->data)) ? 1 : -1];
        (void)sizeof(lmx_blit_pointer_size);
        map->data = NULL;
        if (blit) SDL_memcpy(&map->data, &blit, sizeof(blit));
    }

    // Make sure we have a blit function
    if (!blit) {
]====] _text "${_text}")
    file(WRITE "${destination}/src/video/SDL_blit.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/video/x11/SDL_x11dyn.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "ea809192e620366b6b2cfc74a0f3b53ad4c6f46fdc591e1ec3940e1d48e7f8fa")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[    { NULL, SDL_VIDEO_DRIVER_X11_DYNAMIC_XTEST }
};

static void *X11_GetSym(const char *fnname, int *pHasModule)
{
    int i;
    void *fn = NULL;
    for (i = 0; i < SDL_arraysize(x11libs); i++) {
        if (x11libs[i].lib) {
            fn = SDL_LoadFunction(x11libs[i].lib, fnname);
]====] [====[    { NULL, SDL_VIDEO_DRIVER_X11_DYNAMIC_XTEST }
};

/* LMX C99: keep dynamic symbols typed as function pointers throughout. */
static SDL_FunctionPointer X11_GetSym(const char *fnname, int *pHasModule)
{
    int i;
    SDL_FunctionPointer fn = NULL;
    for (i = 0; i < SDL_arraysize(x11libs); i++) {
        if (x11libs[i].lib) {
            fn = SDL_LoadFunction(x11libs[i].lib, fnname);
]====] _text "${_text}")
    string(REPLACE [====[
#if DEBUG_DYNAMIC_X11
    if (fn)
        printf("X11: Found '%s' in %s (%p)\n", fnname, x11libs[i].libname, fn);
    else
        printf("X11: Symbol '%s' NOT FOUND!\n", fnname);
#endif
]====] [====[
#if DEBUG_DYNAMIC_X11
    if (fn)
        printf("X11: Found '%s' in %s\n", fnname, x11libs[i].libname);
    else
        printf("X11: Symbol '%s' NOT FOUND!\n", fnname);
#endif
]====] _text "${_text}")
    file(WRITE "${destination}/src/video/x11/SDL_x11dyn.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/video/x11/SDL_x11events.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "474899f25eef5ddb2edd00b96250a7d111a995b8217a97d26331fa23350bd717")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[    if (!data) {
        // The window for KeymapNotify, etc events is 0
#ifdef SDL_VIDEO_DRIVER_X11_HAS_XKBLIB
        if (videodata->keyboard.xkb_enabled && xevent->type == videodata->keyboard.xkb.event) {
            XkbEvent *xkbevent = (XkbEvent *)xevent;
            switch (xkbevent->any.xkb_type) {
            case XkbStateNotify:
]====] [====[    if (!data) {
        // The window for KeymapNotify, etc events is 0
#ifdef SDL_VIDEO_DRIVER_X11_HAS_XKBLIB
        if (videodata->keyboard.xkb_enabled && xevent->type == videodata->keyboard.mode.xkb.event) {
            XkbEvent *xkbevent = (XkbEvent *)xevent;
            switch (xkbevent->any.xkb_type) {
            case XkbStateNotify:
]====] _text "${_text}")
    string(REPLACE [====[#ifdef DEBUG_XEVENTS
                SDL_Log("window 0x%lx: XkbStateNotify!", xevent->xany.window);
#endif
                if ((xkbevent->state.changed & XkbGroupStateMask) && xkbevent->state.group != videodata->keyboard.xkb.current_group) {
                    videodata->keyboard.xkb.current_group = xkbevent->state.group;
                    SDL_SetKeymap(videodata->keyboard.xkb.keymaps[videodata->keyboard.xkb.current_group], true);
                }

                if (xkbevent->state.changed & XkbModifierStateMask) {
]====] [====[#ifdef DEBUG_XEVENTS
                SDL_Log("window 0x%lx: XkbStateNotify!", xevent->xany.window);
#endif
                if ((xkbevent->state.changed & XkbGroupStateMask) && xkbevent->state.group != videodata->keyboard.mode.xkb.current_group) {
                    videodata->keyboard.mode.xkb.current_group = xkbevent->state.group;
                    SDL_SetKeymap(videodata->keyboard.mode.xkb.keymaps[videodata->keyboard.mode.xkb.current_group], true);
                }

                if (xkbevent->state.changed & XkbModifierStateMask) {
]====] _text "${_text}")
    string(REPLACE [====[                X11_XkbRefreshKeyboardMapping(&xkbevent->map);

                // Don't redundantly rebuild the keymap if this is a duplicate event.
                if (xkbevent->any.serial != videodata->keyboard.xkb.last_map_serial) {
                    videodata->keyboard.xkb.last_map_serial = xkbevent->any.serial;
                    X11_UpdateKeymap(_this, true);
                }
            } break;
]====] [====[                X11_XkbRefreshKeyboardMapping(&xkbevent->map);

                // Don't redundantly rebuild the keymap if this is a duplicate event.
                if (xkbevent->any.serial != videodata->keyboard.mode.xkb.last_map_serial) {
                    videodata->keyboard.mode.xkb.last_map_serial = xkbevent->any.serial;
                    X11_UpdateKeymap(_this, true);
                }
            } break;
]====] _text "${_text}")
    file(WRITE "${destination}/src/video/x11/SDL_x11events.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/video/x11/SDL_x11keyboard.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "12e01c4ea75364e181941e00971a6c263378e4a9ba0894f0613e30c8c49da8f3")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[#endif
    {
        // TODO: Handle groups on the legacy path.
        if (keycode >= data->keyboard.core.min_keycode && keycode <= data->keyboard.core.max_keycode) {
            keysym = data->keyboard.core.keysym_map[(keycode - data->keyboard.core.min_keycode) * data->keyboard.core.keysyms_per_key];
        } else {
            keysym = NoSymbol;
        }
]====] [====[#endif
    {
        // TODO: Handle groups on the legacy path.
        if (keycode >= data->keyboard.mode.core.min_keycode && keycode <= data->keyboard.mode.core.max_keycode) {
            keysym = data->keyboard.mode.core.keysym_map[(keycode - data->keyboard.mode.core.min_keycode) * data->keyboard.mode.core.keysyms_per_key];
        } else {
            keysym = NoSymbol;
        }
]====] _text "${_text}")
    string(REPLACE [====[    int xkb_major = XkbMajorVersion;
    int xkb_minor = XkbMinorVersion;

    if (X11_XkbQueryExtension(data->display, NULL, &data->keyboard.xkb.event, NULL, &xkb_major, &xkb_minor)) {
        Bool xkb_repeat = 0;
        data->keyboard.xkb_enabled = true;
        data->keyboard.xkb.desc_ptr = X11_XkbGetMap(data->display, XkbAllClientInfoMask, XkbUseCoreKbd);

        // This will remove KeyRelease events for held keys.
        X11_XkbSetDetectableAutoRepeat(data->display, True, &xkb_repeat);
]====] [====[    int xkb_major = XkbMajorVersion;
    int xkb_minor = XkbMinorVersion;

    if (X11_XkbQueryExtension(data->display, NULL, &data->keyboard.mode.xkb.event, NULL, &xkb_major, &xkb_minor)) {
        Bool xkb_repeat = 0;
        data->keyboard.xkb_enabled = true;
        data->keyboard.mode.xkb.desc_ptr = X11_XkbGetMap(data->display, XkbAllClientInfoMask, XkbUseCoreKbd);

        // This will remove KeyRelease events for held keys.
        X11_XkbSetDetectableAutoRepeat(data->display, True, &xkb_repeat);
]====] _text "${_text}")
    string(REPLACE [====[#endif
    {
        // If XKB isn't available, initialize the legacy path.
        X11_XDisplayKeycodes(data->display, &data->keyboard.core.min_keycode, &data->keyboard.core.max_keycode);
        data->keyboard.core.keysym_map = X11_XGetKeyboardMapping(data->display, data->keyboard.core.min_keycode,
                                                              data->keyboard.core.max_keycode - data->keyboard.core.min_keycode,
                                                              &data->keyboard.core.keysyms_per_key);
    }

    // Open a connection to the X input manager
]====] [====[#endif
    {
        // If XKB isn't available, initialize the legacy path.
        X11_XDisplayKeycodes(data->display, &data->keyboard.mode.core.min_keycode, &data->keyboard.mode.core.max_keycode);
        data->keyboard.mode.core.keysym_map = X11_XGetKeyboardMapping(data->display, data->keyboard.mode.core.min_keycode,
                                                              data->keyboard.mode.core.max_keycode - data->keyboard.mode.core.min_keycode,
                                                              &data->keyboard.mode.core.keysyms_per_key);
    }

    // Open a connection to the X input manager
]====] _text "${_text}")
    string(REPLACE [====[    const Atom vmod = X11_XInternAtom(videodata->display, vmod_name, True);
    if (vmod != None) {
        for (int i = 0; i < XkbNumVirtualMods; ++i) {
            if (vmod == videodata->keyboard.xkb.desc_ptr->names->vmods[i]) {
                mod_mask = videodata->keyboard.xkb.desc_ptr->server->vmods[i];
                break;
            }
        }
]====] [====[    const Atom vmod = X11_XInternAtom(videodata->display, vmod_name, True);
    if (vmod != None) {
        for (int i = 0; i < XkbNumVirtualMods; ++i) {
            if (vmod == videodata->keyboard.mode.xkb.desc_ptr->names->vmods[i]) {
                mod_mask = videodata->keyboard.mode.xkb.desc_ptr->server->vmods[i];
                break;
            }
        }
]====] _text "${_text}")
    string(REPLACE [====[        XkbStateRec state;

        for (unsigned int i = 0; i < XkbNumKbdGroups; ++i) {
            SDL_DestroyKeymap(data->keyboard.xkb.keymaps[i]);
            data->keyboard.xkb.keymaps[i] = NULL;
        }

        X11_XkbGetNames(data->display, XkbVirtualModNamesMask, data->keyboard.xkb.desc_ptr);
        X11_XkbGetUpdatedMap(data->display, XkbAllClientInfoMask | XkbVirtualModsMask, data->keyboard.xkb.desc_ptr);

        if (X11_XkbGetState(data->display, XkbUseCoreKbd, &state) == Success) {
            data->keyboard.xkb.current_group = state.group;
        }

        data->keyboard.alt_mask = X11_GetXkbVirtualModifierMask(_this, "Alt");
]====] [====[        XkbStateRec state;

        for (unsigned int i = 0; i < XkbNumKbdGroups; ++i) {
            SDL_DestroyKeymap(data->keyboard.mode.xkb.keymaps[i]);
            data->keyboard.mode.xkb.keymaps[i] = NULL;
        }

        X11_XkbGetNames(data->display, XkbVirtualModNamesMask, data->keyboard.mode.xkb.desc_ptr);
        X11_XkbGetUpdatedMap(data->display, XkbAllClientInfoMask | XkbVirtualModsMask, data->keyboard.mode.xkb.desc_ptr);

        if (X11_XkbGetState(data->display, XkbUseCoreKbd, &state) == Success) {
            data->keyboard.mode.xkb.current_group = state.group;
        }

        data->keyboard.alt_mask = X11_GetXkbVirtualModifierMask(_this, "Alt");
]====] _text "${_text}")
    string(REPLACE [====[        data->keyboard.scrolllock_mask = X11_GetXkbVirtualModifierMask(_this, "ScrollLock");

        for (unsigned int i = 0; i < XkbNumKbdGroups; ++i) {
            data->keyboard.xkb.keymaps[i] = SDL_CreateKeymap(false);
            if (!data->keyboard.xkb.keymaps[i]) {
                for (unsigned int j = 0; j < i; ++j) {
                    SDL_DestroyKeymap(data->keyboard.xkb.keymaps[i]);
                    data->keyboard.xkb.keymaps[j] = NULL;
                }

                return;
]====] [====[        data->keyboard.scrolllock_mask = X11_GetXkbVirtualModifierMask(_this, "ScrollLock");

        for (unsigned int i = 0; i < XkbNumKbdGroups; ++i) {
            data->keyboard.mode.xkb.keymaps[i] = SDL_CreateKeymap(false);
            if (!data->keyboard.mode.xkb.keymaps[i]) {
                for (unsigned int j = 0; j < i; ++j) {
                    SDL_DestroyKeymap(data->keyboard.mode.xkb.keymaps[i]);
                    data->keyboard.mode.xkb.keymaps[j] = NULL;
                }

                return;
]====] _text "${_text}")
    string(REPLACE [====[        // Only the shift, alt, level 3, level 5 and caps lock modifiers affect SDL keymaps.
        const Uint32 valid_mod_mask = ShiftMask | LockMask | data->keyboard.alt_mask | data->keyboard.level3_mask | data->keyboard.level5_mask;

        for (Uint32 xkeycode = data->keyboard.xkb.desc_ptr->min_key_code; xkeycode < data->keyboard.xkb.desc_ptr->max_key_code; ++xkeycode) {
            const SDL_Scancode scancode = data->keyboard.key_layout[xkeycode];
            if (scancode == SDL_SCANCODE_UNKNOWN) {
                continue;
            }

            for (Uint32 group = 0; group < XkbNumKbdGroups; ++group) {
                SDL_Keymap *keymap = data->keyboard.xkb.keymaps[group];

                Uint32 effective_group = group;
                const unsigned char max_key_group = XkbKeyNumGroups(data->keyboard.xkb.desc_ptr, xkeycode);
                const unsigned char key_group_info = XkbKeyGroupInfo(data->keyboard.xkb.desc_ptr, xkeycode);

                if (max_key_group && effective_group >= max_key_group) {
                    const unsigned char action = XkbOutOfRangeGroupAction(key_group_info);
]====] [====[        // Only the shift, alt, level 3, level 5 and caps lock modifiers affect SDL keymaps.
        const Uint32 valid_mod_mask = ShiftMask | LockMask | data->keyboard.alt_mask | data->keyboard.level3_mask | data->keyboard.level5_mask;

        for (Uint32 xkeycode = data->keyboard.mode.xkb.desc_ptr->min_key_code; xkeycode < data->keyboard.mode.xkb.desc_ptr->max_key_code; ++xkeycode) {
            const SDL_Scancode scancode = data->keyboard.key_layout[xkeycode];
            if (scancode == SDL_SCANCODE_UNKNOWN) {
                continue;
            }

            for (Uint32 group = 0; group < XkbNumKbdGroups; ++group) {
                SDL_Keymap *keymap = data->keyboard.mode.xkb.keymaps[group];

                Uint32 effective_group = group;
                const unsigned char max_key_group = XkbKeyNumGroups(data->keyboard.mode.xkb.desc_ptr, xkeycode);
                const unsigned char key_group_info = XkbKeyGroupInfo(data->keyboard.mode.xkb.desc_ptr, xkeycode);

                if (max_key_group && effective_group >= max_key_group) {
                    const unsigned char action = XkbOutOfRangeGroupAction(key_group_info);
]====] _text "${_text}")
    string(REPLACE [====[                    }
                }

                XkbKeyTypePtr key_type = XkbKeyKeyType(data->keyboard.xkb.desc_ptr, xkeycode, effective_group);

                for (Uint32 level = 0; level < key_type->num_levels; ++level) {
                    const KeySym keysym = X11_KeyCodeToSym(_this, xkeycode, effective_group, level);
]====] [====[                    }
                }

                XkbKeyTypePtr key_type = XkbKeyKeyType(data->keyboard.mode.xkb.desc_ptr, xkeycode, effective_group);

                for (Uint32 level = 0; level < key_type->num_levels; ++level) {
                    const KeySym keysym = X11_KeyCodeToSym(_this, xkeycode, effective_group, level);
]====] _text "${_text}")
    string(REPLACE [====[            }
        }

        SDL_SetKeymap(data->keyboard.xkb.keymaps[data->keyboard.xkb.current_group], send_event);
    } else
#endif
    {
]====] [====[            }
        }

        SDL_SetKeymap(data->keyboard.mode.xkb.keymaps[data->keyboard.mode.xkb.current_group], send_event);
    } else
#endif
    {
]====] _text "${_text}")
    string(REPLACE [====[        }

        if (send_event) {
            if (data->keyboard.core.keysym_map) {
                X11_XFree(data->keyboard.core.keysym_map);
            }
            X11_XDisplayKeycodes(data->display, &data->keyboard.core.min_keycode, &data->keyboard.core.max_keycode);
            data->keyboard.core.keysym_map = X11_XGetKeyboardMapping(data->display, data->keyboard.core.min_keycode,
                                                                     data->keyboard.core.max_keycode - data->keyboard.core.min_keycode,
                                                                     &data->keyboard.core.keysyms_per_key);
        }

        for (Uint32 xkeycode = data->keyboard.core.min_keycode; xkeycode <= data->keyboard.core.max_keycode; ++xkeycode) {
            const SDL_Scancode scancode = data->keyboard.key_layout[xkeycode];
            if (scancode == SDL_SCANCODE_UNKNOWN) {
                continue;
]====] [====[        }

        if (send_event) {
            if (data->keyboard.mode.core.keysym_map) {
                X11_XFree(data->keyboard.mode.core.keysym_map);
            }
            X11_XDisplayKeycodes(data->display, &data->keyboard.mode.core.min_keycode, &data->keyboard.mode.core.max_keycode);
            data->keyboard.mode.core.keysym_map = X11_XGetKeyboardMapping(data->display, data->keyboard.mode.core.min_keycode,
                                                                     data->keyboard.mode.core.max_keycode - data->keyboard.mode.core.min_keycode,
                                                                     &data->keyboard.mode.core.keysyms_per_key);
        }

        for (Uint32 xkeycode = data->keyboard.mode.core.min_keycode; xkeycode <= data->keyboard.mode.core.max_keycode; ++xkeycode) {
            const SDL_Scancode scancode = data->keyboard.key_layout[xkeycode];
            if (scancode == SDL_SCANCODE_UNKNOWN) {
                continue;
]====] _text "${_text}")
    string(REPLACE [====[#ifdef SDL_VIDEO_DRIVER_X11_HAS_XKBLIB
    if (data->keyboard.xkb_enabled) {
        for (int i = 0; i < XkbNumKbdGroups; ++i) {
            SDL_DestroyKeymap(data->keyboard.xkb.keymaps[i]);
            data->keyboard.xkb.keymaps[i] = NULL;
        }

        if (data->keyboard.xkb_enabled) {
            X11_XkbFreeKeyboard(data->keyboard.xkb.desc_ptr, 0, True);
            data->keyboard.xkb.desc_ptr = NULL;
        }
    } else
#endif
        if (data->keyboard.core.keysym_map) {
        X11_XFree(data->keyboard.core.keysym_map);
        data->keyboard.core.keysym_map = NULL;
    }
}

]====] [====[#ifdef SDL_VIDEO_DRIVER_X11_HAS_XKBLIB
    if (data->keyboard.xkb_enabled) {
        for (int i = 0; i < XkbNumKbdGroups; ++i) {
            SDL_DestroyKeymap(data->keyboard.mode.xkb.keymaps[i]);
            data->keyboard.mode.xkb.keymaps[i] = NULL;
        }

        if (data->keyboard.xkb_enabled) {
            X11_XkbFreeKeyboard(data->keyboard.mode.xkb.desc_ptr, 0, True);
            data->keyboard.mode.xkb.desc_ptr = NULL;
        }
    } else
#endif
        if (data->keyboard.mode.core.keysym_map) {
        X11_XFree(data->keyboard.mode.core.keysym_map);
        data->keyboard.mode.core.keysym_map = NULL;
    }
}

]====] _text "${_text}")
    file(WRITE "${destination}/src/video/x11/SDL_x11keyboard.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/video/x11/SDL_x11opengl.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "17541b6f7f5c45cd23e715131fa60d8f0786acdcb350a17dd515cd22137f8432")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[#if defined(OPENGL_REQUIRES_DLOPEN) && defined(HAVE_DLOPEN)
#include <dlfcn.h>
#define GL_LoadObject(X) dlopen(X, (RTLD_NOW | RTLD_GLOBAL))
#define GL_LoadFunction  dlsym
#define GL_UnloadObject  dlclose
#else
#define GL_LoadObject   SDL_LoadObject
]====] [====[#if defined(OPENGL_REQUIRES_DLOPEN) && defined(HAVE_DLOPEN)
#include <dlfcn.h>
#define GL_LoadObject(X) dlopen(X, (RTLD_NOW | RTLD_GLOBAL))
/* LMX C99: preserve RTLD_GLOBAL loader semantics and POSIX symbol ABI. */
static SDL_FunctionPointer lmx_gl_load_function(void *handle, const char *name)
{
    void *address = dlsym(handle, name);
    SDL_FunctionPointer result = NULL;
    typedef char lmx_gl_pointer_size[(sizeof(result) == sizeof(address)) ? 1 : -1];
    if (address) SDL_memcpy(&result, &address, sizeof(result));
    return result;
}
#define GL_LoadFunction lmx_gl_load_function
#define GL_UnloadObject  dlclose
#else
#define GL_LoadObject   SDL_LoadObject
]====] _text "${_text}")
    file(WRITE "${destination}/src/video/x11/SDL_x11opengl.c" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/video/x11/SDL_x11video.h")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "97a61be6c9b27ff172ffd841bf87ac0fb16befdeae8feca99b421ed12728eb33")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[                int min_keycode;
                int max_keycode;
            } core; // Legacy core keyboard handling
        };
        Uint32 pressed_modifiers;
        Uint32 locked_modifiers;
        SDL_Keymod sdl_pressed_modifiers;
]====] [====[                int min_keycode;
                int max_keycode;
            } core; // Legacy core keyboard handling
        } mode; /* LMX C99: named keyboard-state union. */
        Uint32 pressed_modifiers;
        Uint32 locked_modifiers;
        SDL_Keymod sdl_pressed_modifiers;
]====] _text "${_text}")
    file(WRITE "${destination}/src/video/x11/SDL_x11video.h" "${_text}")
  endif()
  if(name STREQUAL "sdl3")
    set(_file "${original}/src/video/x11/xsettings-client.c")
    file(SHA256 "${_file}" _sha)
    if(NOT _sha STREQUAL "cabb80e4b4fb95da92e1d60619e0cc0c9b3c13e48ad2086d5284120e02a50c71")
      message(FATAL_ERROR "Pinned C99 adaptation input changed: ${_file}")
    endif()
    file(READ "${_file}" _text)
    string(REPLACE [====[          break;
        case XSETTINGS_DUPLICATE_ENTRY:
          fprintf (stderr, "Duplicate XSETTINGS entry for '%s'\n", setting->name);
          SDL_FALLTHROUGH;
        case XSETTINGS_FAILED:
          SDL_FALLTHROUGH;
        case XSETTINGS_SUCCESS:
          SDL_FALLTHROUGH;
        case XSETTINGS_NO_ENTRY:
          break;
]====] [====[          break;
        case XSETTINGS_DUPLICATE_ENTRY:
          fprintf (stderr, "Duplicate XSETTINGS entry for '%s'\n", setting->name);
          ; /* LMX C99: label must precede a statement before the attribute. */
          SDL_FALLTHROUGH;
        case XSETTINGS_FAILED:
          ; /* LMX C99: label must precede a statement before the attribute. */
          SDL_FALLTHROUGH;
        case XSETTINGS_SUCCESS:
          ; /* LMX C99: label must precede a statement before the attribute. */
          SDL_FALLTHROUGH;
        case XSETTINGS_NO_ENTRY:
          break;
]====] _text "${_text}")
    file(WRITE "${destination}/src/video/x11/xsettings-client.c" "${_text}")
  endif()
endfunction()
