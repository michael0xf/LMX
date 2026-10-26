Actual frontend-record.txt invokes L1 translator on
declcold02/boot-quick-01/frontend/frontend-source.lm1.
The artifact manifest binds declcold02/src/l2src/l2trans.lm1.
Both full files SHA2331696CC93AAB823CD5D6421C73C2FE0AF76D4FFBA68D8733CA0097C75EE2A9.
Independent GNU cmp -s between those explicit paths returns0.
Thus the bound source bytes are the bytes read by the recorded backend,
not a hypothetical frontend/frontend.lm1 path from the first failed list.
