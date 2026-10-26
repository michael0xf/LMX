External exact-base patch replay, not a compiler/test run or new maintained runner.
Base d1fd3b53c3749723d6874d5790277f37c7b463b4 (Verified229).
git archive selects only old recipe, old maintained harness and runtime.list.
The source patch adds ordinary-L2 helper and updates those three files.
GNU tar --force-local extracts the archive into pins/from229-replay01.
GNU patch --batch --fuzz=0 -p1 --input pins/from229-u0.patch.
GNU sha256sum --check pins/canonical4.sha256 from that replay root.
Output pins/from229-replay.log; no branch/worktree or old WIP is changed.
