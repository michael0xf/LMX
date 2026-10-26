Get-FileHash SHA256 for G2 executable and selected boot-quick-01/lmxtool.exe:
both48030c0ee640193cac787824b704b9a3971dec4872d78e2f8ebfd64f54085b40.
Independent GNU cmp of the two absolute paths returns0 after whole terminal.
GNU sha256sum -c original pins/g2-expected3.sha256 from STAGE returns0,
all3 L1/C/object. One earlier cmp used repo-relative paths from STAGE and
returned2/No such file; its guard prevented the subsequent verifier. That
invocation checked no bytes. Corrected absolute-path readback above is0;
no compilation, source change or bootstrap retry occurred.
