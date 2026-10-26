Final whitespace-clean canonical patch replay, separate from the executed-source patch.
Base d1fd3b53c3749723d6874d5790277f37c7b463b4.
Existing base229.tar selects old recipe, maintained harness and runtime.list.
GNU tar --force-local -xf pins/base229.tar -C pins/from229-final02-replay03
GNU patch --batch --fuzz=0 -p1 -i pins/from229-final02-u0.patch
GNU sha256sum --check pins/canonical-final02-4.sha256
All four final hashes match, exit0. No compiler/test run or worktree created.
