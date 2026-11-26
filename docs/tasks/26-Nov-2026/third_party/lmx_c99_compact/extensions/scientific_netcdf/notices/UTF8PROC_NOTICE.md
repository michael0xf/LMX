# utf8proc embedded in netCDF-C

`vendor/netcdf/libdispatch/utf8proc.h` declares utf8proc **2.9.0**.
The accompanying `utf8proc.c` and generated `utf8proc_data.c` provide the
normalization implementation and derived Unicode data used by netCDF-C.

The unmodified upstream license for that version is retained in
[UTF8PROC_LICENSE.md](UTF8PROC_LICENSE.md). It includes both the MIT licenses
for the code and the Unicode data copyright/permission notice.

- Source: https://github.com/JuliaStrings/utf8proc/blob/v2.9.0/LICENSE.md
- Exact download: https://raw.githubusercontent.com/JuliaStrings/utf8proc/v2.9.0/LICENSE.md
- SHA-256: `3b510150d34f248a221bb88e1d811238d6c6c18b51231822c42974c39bb07256`
- License expression for this embedded component: `MIT AND Unicode-DFS-2015`.

The netCDF-C distribution prefixes these utf8proc symbols and types with
`nc_`. This integration preserves the netCDF-C 4.10.1 vendor files unchanged
and adds the missing standalone notice here, outside the vendor tree.
The derived-data/modified-data statement remains in `utf8proc.c`; the full
Unicode terms are reproduced in the retained upstream license.
