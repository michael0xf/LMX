Actual G1 cc23aa03 command, session6671 terminal0:
G1 0 entry 0 -- verify STAGE/pins/cold78.raw.sha256 STAGE
Result VERIFIED78files0failed; driver13checks0roots.
Launch cwd was accidentally STAGE, although runs/g1-verify-cold78-01 had
been created. This command therefore created/truncated the driver's
protected launcher basename there. It was not read/listed/hashed/copied/
staged/deleted. Repository-root protected contents were not involved.
Do not repeat this verification solely to change its cwd. All following
L2 CLI workdirs must explicitly be fresh STAGE/runs/<label> directories.
The original cold78 source bytes and manifest remain unchanged.
