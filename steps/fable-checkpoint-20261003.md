# Fable RED development checkpoint, 2026-10-03: manifest

This file belongs to the [continuation ledger](fable-continuation-20261003.md#checkpoint).
It lists every path of the sandbox dependency closure committed by the RED
development checkpoint, with the SHA256 of the committed bytes, and the exact
rows the generated harness left red on those bytes.

It is not a release, not a green kernel and not a ticket closure. The stable
copy `l2src/` is not part of it and was not edited.

## Paths

345 paths. By origin: fable-changed 32, fable-new 1, inherited 164, inherited-new 148.
By gate that staged the same bytes: - 30, harness 272, harness,kernel 2, harness,kernel,l3 19, kernel 21, l3 1.

Columns: SHA256 of the file, Git status before the commit (`M` tracked and
modified, `??` new), origin, gate, path.

- `inherited`: byte-identical to the uncommitted tree received at the takeover
  of `main@4114628c`; `inherited-new` is the same for a file that was not yet
  tracked.
- `fable-changed`, `fable-new`: changed or created by this continuation.
- gate `harness`: the same bytes are in the stage of `fable_full_04`; `kernel`:
  in `build/l2src/fable_kernel_01`; `l3`: in `build/l3_selftest/fable_l3_01`.
  A file may be in several stages.
- gate `-`: no gate staged the file. For the 26 fixtures this means UNGATED:
  no harness row names them, and their inherited edit (the removed `L2:`
  wrapper) was not executed by any gate. Of the four tool files, three ran
  the gates (`tools/l2_harness.ps1`, `tools/run_l3_selftest.py`,
  `tools/l3_type_budget.py`); `tools/test_l2_walk_graph_facts.ps1` was run on
  its own (21 controls, GREEN).

```text
e30b6004ccc89193b3cbbcf1825a234eb79d24b5849f093e346cc4740b0405ba M  inherited     harness           dev/l2src_sandbox/harness/l2_eternal_driver.lm1
cb15d7817fab71b3bc5920e47b920757b36d179d358d76186eeae393362b3b58 M  inherited     harness,kernel    dev/l2src_sandbox/l2_application.h.lm1
d7807f2a3e85860c8bf96e7d706bdc3f44f1f5b1489a2d6ecf22a06435fef70a M  fable-changed harness,kernel    dev/l2src_sandbox/l2trans.lm1
1117a56daa3bf29553565fbc79e962a003ff8cc27ff84fa61eb9c8847b81ecf0 M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx.h.lm1
1c618ce617a6811cc2b703af085742ed366e1b4d33075afeb3e5955ed95ea6db M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_child.h.lm1
f46e1599a3848dd8e6d11cfc410e6fc16f5ce8272468a1e5007ef18cfe21c6dd M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_child.lm1
5670882d82c205cd69e28fc703ed1e6876ebf80018bd196d44893880f44fcd8d M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_gc.lm1
37a4d569b34c9eb1c413f1d083fec8e53e71c335b93f6dd7f24442e4b272c7da M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_graph_copy_owned.h.lm1
943e434e47d583c2cf1b3220d0cc18093aed02c9226d06e347696fbc3f8282e3 M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_graph_copy_owned.lm1
00aee6395e5c7590cb468489760ddb1a1d2a9c7d581a35027331f857b75e6b0f M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_implements.h.lm1
06ea56978aa87568dea60ab7ab15be9b7c340f50d4d2ff301df865996fababfe M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_implements.lm1
1c15c1bdc34ef33d82b3803c389dd1625fd665eb53490820448ea620de350f6f M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_merge_owned.h.lm1
96bfebd2ce745dadea461d473825d3f21edf1f458f25fd0327e55578d2b4ecd2 M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_merge_owned.lm1
543d53259bb8d3c51bde9898d5e4fc80ff1d6e69eb59ba44464f366a03b76a4b M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_range.lm1
df0d66f76b2d3c6f4fc5ed84e50dccefe37daa2232391223a6282e385675472c M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_root.h.lm1
1d91bc80c6836c2ab7e5cd6b03f30ce35a08cfbfb9b7532d06cfd610b7776e67 M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_root.lm1
ed4caeae72fb676604dcb9b35b824d972de61dfcd4298d6939d70cd7fc5ddb79 M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_thread.h.lm1
3b1c4727703fc1e675b5e2d281c2e1a1d487d96d46cd0250f03fc8935d6ffa61 M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_thread.lm1
3ddfd7c9db708f5f27f2b4c55785ca6c9c140ee54f213e01ff83f0b33106cf38 M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_walk.h.lm1
61bed7074e575b44c410a4d805024693a5b3b496b4d89a36a59ac089ad6e3918 M  inherited     harness,kernel,l3 dev/l2src_sandbox/lmx_walk.lm1
d9493e58f5c7a10acaa8fa6c0d6b2651cd1fb7466f059b5c1813b730cba82060 M  inherited     -                 dev/l2src_sandbox/tests/add.lm2
09db2c6dd085727bb5cb5409c77fda2965faf844c7b1044667594bb6793ca4be M  inherited     -                 dev/l2src_sandbox/tests/entry_add_ret.lm2
476487f6c64d1aee31a3c11cbf244f9e1ece84208bfaede632870311b8bf6e94 M  inherited     harness           dev/l2src_sandbox/tests/entry_argc_bad.lm2
7302d357bb28b037fed947f5cdaf0f4482e6d3124a37c8e41d468b6df1e615f3 M  inherited     harness           dev/l2src_sandbox/tests/entry_argc_dup.lm2
93bcb4d4248664194d34a618ee5d3e873f6c427d9556ed98e843fbedb633c36d M  inherited     harness           dev/l2src_sandbox/tests/entry_argc_if.lm2
49a16e3afbec5de08282e3fb93ab31853a4aaa2806557f3503f8b8f930c69682 M  inherited     harness           dev/l2src_sandbox/tests/entry_array.lm2
d8209baef933325ec7c6774fd8e3b6f2e36f7107072ae9d5e80ab4466a52e464 M  inherited     -                 dev/l2src_sandbox/tests/entry_bad_arity.lm2
2bce760d6d1b4fb29522b1e99cd9a4641cfa9e54ee2b6d202a5a6c3592e2b595 M  inherited     -                 dev/l2src_sandbox/tests/entry_bad_body.lm2
aed80795b6e8c6d80a39386b2231798d24322f9596c6d5e2e2270b4c87c6821b M  inherited     harness           dev/l2src_sandbox/tests/entry_bad_sig.lm2
270507ceea2df80356ac6d7b04d19b849859338b3f7faefacb87ba8709da355c M  inherited     harness           dev/l2src_sandbox/tests/entry_dyn_array_index.lm2
6ec25fd1c0681b98efb310ae60902a9d20f263e40edca01d60b79a012ebda1a4 M  inherited     harness           dev/l2src_sandbox/tests/entry_dyn_array_index_int_refused.lm2
bd8284dd6e13862e6e6ba34d3f7c57e204bd2338f46d1367c5314d41abbabf61 M  inherited     -                 dev/l2src_sandbox/tests/entry_fputs.lm2
db735044a3968b8e1f19d55fc71c15b8859d9eece7b5f5c0e599f617eff18358 M  inherited     -                 dev/l2src_sandbox/tests/entry_hex.lm2
6589b28b4bb852f8e3ac885fea7742b343b94a2d1d66cfd85a5fb6401536495e M  inherited     -                 dev/l2src_sandbox/tests/entry_immut.lm2
781b77266fde641d0188f8b0ec5ba0971390a8a52c956b786ee1ab8bb0aca70d M  inherited     -                 dev/l2src_sandbox/tests/entry_int_max.lm2
9a1313efbdb503993354bb671992c435cd43b7f5dbbef01816334dd632edecd0 M  inherited     -                 dev/l2src_sandbox/tests/entry_local_types.lm2
50af097e90e6f4c2e1df5ccdafdcac1cd36ee4afed39eab01904809f50477097 M  inherited     harness           dev/l2src_sandbox/tests/entry_nul.lm2
cc2aecf115db1bb7f52c26da6b2e0f38069c5276a0d6710a7de99fa6465c53a0 M  inherited     -                 dev/l2src_sandbox/tests/entry_os.lm2
5166c2c2b20b129bb7ed6cb5d17754e0cb0cf24ebc9ff80bbafcf587480dea29 M  inherited     -                 dev/l2src_sandbox/tests/entry_os_body.lm2
c50338166a3fbe281d9da8b1738cdda43120c02fb8da99ccadc62c5f5941e062 M  inherited     -                 dev/l2src_sandbox/tests/entry_os_mismatch.lm2
ba907ae793e82fae00a5655705f5f4470ce3e0b7efacc916afeed0147a050842 M  inherited     -                 dev/l2src_sandbox/tests/entry_os_params.lm2
42b485215b31cdd70b767648c2b94f660a1891a21b98541e3c819da87cc29efb M  inherited     -                 dev/l2src_sandbox/tests/entry_os_ret.lm2
6d1618ddb7e1ad06bd99bb548eb07913a58551e439cc797754c426ddcea6826b M  inherited     -                 dev/l2src_sandbox/tests/entry_os_ret2.lm2
4e3f31d5dd3ac289e9dfb207a71ade0792463d295c95cd01a30fe09b00a7830c M  inherited     harness           dev/l2src_sandbox/tests/entry_overflow.lm2
fca1dd4a947976a04c9c475c2b93b14dddcea80048b6da6f91975d82c5eb668a M  inherited     -                 dev/l2src_sandbox/tests/entry_predef.lm2
2ff17b0f9873d0f2eb0c4d22e35d68c4d5e475f4d49b81596961a7384482e4b6 M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_after_return.lm2
fc0501160c5f0697fdfdeb7ffed272f46fa8aae559af78e8937350df5304e14b M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_bad_arg.lm2
1965842a888936ceed0fbf645f41b09145c27226a8a8c904405f6c090649db1a M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_empty.lm2
dcf35283ea87de6288faaed0cd58a5dfe012ea980b9932df06421d7ac4b24679 M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_esc.lm2
80e93c8905a6c2a961748976753ebba569fbadec283b04ef3f8d7ab8c5f55c4e M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_extra_arg.lm2
57ce8ae4624abe9f08a20ecae16d77be1b3fb03c057083a0690d7c80b4ce3b0e M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_hello.lm2
b1bc1db0695189b8fe421913a4db07577e6a7fb5ab1fea8b0e1dd801bcceb45f M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_nested.lm2
09ef0b386397e306ce2b15586716296ef4fd3f67577753032b91093eccdc422f M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_nl.lm2
ddb4a4eeea61b1d66d8da82d7d5a96fed53606e4743b0e2d51efd1baa3d144d4 M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_seq.lm2
20714182d1e06230fa345ffd33f40a5f18198ac6930ceeaf4a55c5b017016657 M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_triple.lm2
df5d7e829dad81d4f614f73467f56fb2e2d246493752250f697b2a61c8ffcd7c M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_triple_lead.lm2
76053bf15a040e359fe3bc2bdf9f8c240075480ecb41dc8731618e9e17455adc M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_triple_lead_sq.lm2
feefde743d4399a7866220206543110d96d5b0278e2d05dfb93afab3ef52a909 M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_triple_long.lm2
efdb259e27a36dd119247a7ba2ef8fa5ba6364cb80c555c8b8fe25a6a95f4caa M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_triple_runs.lm2
f2a0802ae5bfea861a35d55a078175acc9dfa3c94509364a3b93656a6fe698e0 M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_triple_seven.lm2
58c17bd6cc3672fb9b48347ca67b419062702ea43fde802c7238d48daad6b177 M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_triple_seven_sq.lm2
668a9ba0e017f796d054b2f677cf60ac507e38402ce58dca1eb38938a3c069db M  inherited     harness           dev/l2src_sandbox/tests/entry_puts_triple_single.lm2
d0339ecd09cbeca1ae7d70c7122e101bd8e9b4eaf3d0e6695d64ea38ad4ca6a3 M  inherited     -                 dev/l2src_sandbox/tests/entry_return0.lm2
3e52cf10c268d29dd60780177b08983eddb1a252dd8de8384ff5819d8e077d44 M  inherited     -                 dev/l2src_sandbox/tests/entry_setvbuf.lm2
2b1bd642f032628ffddff733ab1b449013f328ac78bac91fd2e727535d996855 M  inherited     -                 dev/l2src_sandbox/tests/entry_trailer.lm2
9e9b307b98cb1d5f01b815e460baf588a04e4e654f167a3b780d682f3d199926 M  inherited     harness           dev/l2src_sandbox/tests/entry_two_main.lm2
a2a1ee6c7c2be79d0ec729f566edc29ab7a4ba5ab9f0f6507be521f52f164ae3 M  inherited     -                 dev/l2src_sandbox/tests/entry_unknown_method.lm2
289f01a3700fc82110b5452f6d50fe7c3c73704f7a5548062a8025d0828cc809 M  inherited     -                 dev/l2src_sandbox/tests/entry_unresolved.lm2
f84fa6d7859bc237c7d5f7c53d6791f706c94821853b79e546b11e299181b5a5 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_app_min_selftest.lm1
6af93f30e65a15cf78004d3c170049af25774f05c1b4869c516358f56df15cd0 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_argv_letter_selftest.lm1
03a55b6b45c7bc5a4583466c636b4d3a1c2fe766f2801ecf25f5d3c253ff8d70 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_child_selftest.lm1
fb5e4cec0d452938f04472b26db2eadc4207de24295c1ccc236252d999780912 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_gc_selftest.lm1
652c183557c35570b1d5817e87ab88b51b32f8186a4a57bc9dd2c234b856dcde M  inherited     kernel            dev/l2src_sandbox/tests/lmx_interp_walk_selftest.lm1
63e3168974f5824ce900af1b8ba2c5f80c2ad016870e5525674f2b0b97da404c M  inherited     kernel            dev/l2src_sandbox/tests/lmx_primitive_selftest.lm1
f1eebb49288f30e3ac0db1da8bc04cfd8aaa956537d6f04baa81a9417fed75c5 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_primitive_thread_selftest.lm1
7e10906bcbb622bd91449b334f924b1243079d96f71104338389a590aec3c9d3 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_qualified_range_selftest.lm1
d2ec7aed3c2ed28dba2c84b6507887cfc2ae2c53f7c3d8a78ab6e7684b14efa0 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_root_host_selftest.lm1
acdc607d8a5a91034da96bc1879ade43538c0ac505a5b7a0ceb7902900bd1dad M  inherited     kernel            dev/l2src_sandbox/tests/lmx_root_selftest.lm1
8ea4aaf7c064dca8c752da363b3462ab9e8fcb48505fe250d2f646c2cb07e8f2 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_runtime_implements_selftest.lm1
6f0deb19b358e3827e0b162f735c36bd037ccc4f2b374dcf4b395af948055a4c M  inherited     kernel            dev/l2src_sandbox/tests/lmx_service_selftest.lm1
244a22cb9ec92571bf5b16e61e67d0c7cb0556125bb31b646710a9458460f93e M  inherited     kernel            dev/l2src_sandbox/tests/lmx_settle_mail_close_refusal_selftest.lm1
b6f0248bd8ac4d19fedfbeac64b405cc9411ddd3bb7b3666a265cf7a582047f2 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_settle_selftest.lm1
3ef33735150b4b9c7b37c8168a5933571a1ce210a6d621e68c77d5daaa18ab73 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_thread_children_selftest.lm1
5fe54a8fd253670fd2b3cd2a79ae67547437992fb1a5c9d672192ccab504d6bb M  inherited     kernel            dev/l2src_sandbox/tests/lmx_turn_selftest.lm1
c0426161b41cc1cca7cfa84b8f28286304ff8ba2766f7784ab281ccee45dec98 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_walk_admit_selftest.lm1
2e513d6eb1be7f670a7c6fe7e81f5cbdeddbad28ef21be6cf2b960ff32db59d5 M  inherited     kernel            dev/l2src_sandbox/tests/lmx_walk_selftest.lm1
4e07189f7f61761ff690124527f2107d141b58436df54c21d4688456dd30c94a M  inherited     harness           dev/l2src_sandbox/tests/unit_admit_letter_extra_field.lm2
4c259cecfbdc513cddd7928f085aa8319c22041d6a271d451a0e56ed3a3c4379 M  inherited     harness           dev/l2src_sandbox/tests/unit_admit_letter_not_model.lm2
3412d2607754e4779aaa00d70f204b01779ab93286ed460a0fdc376f97246c91 M  inherited     harness           dev/l2src_sandbox/tests/unit_admit_letter_typed.lm2
b10ebff00c9d92dd0a9d2b48b546bc99ab842fa988ca8b217f91404ab2701f42 M  inherited     harness           dev/l2src_sandbox/tests/unit_bind_method_formal.lm2
0209a64551513759f266ca9f2586bb77adf586c718f6de49aba8664bc101a94c M  inherited     harness           dev/l2src_sandbox/tests/unit_bind_method_ref.lm2
8e218c20afe89e7ee8697fa5c52e9c8d54dd7cf6d45121990f095821fadd2a71 M  fable-changed harness           dev/l2src_sandbox/tests/unit_bind_method_thin_other.lm2
766dcd7754faef63742fb975dd1cc25e293d817c7ef740eab5bd0d5b09e20ece M  inherited     harness           dev/l2src_sandbox/tests/unit_body_path_deep.lm2
4935624deb0e35a2d2d18fab42e15cdd74cb8d48fdb54e0afe04034f87fec78d M  inherited     harness           dev/l2src_sandbox/tests/unit_c_member_struct_control.lm2
5842a64ee2e65efd56763126e3443943fcc2deb0d6aca6865ade4ef0885c83ff M  inherited     harness           dev/l2src_sandbox/tests/unit_cache_struct_ref.lm2
0cb2d00e680cfc251f218dfa6cc4bb6bcf5341d490fd7a5cdf67e799eead68f1 M  inherited     harness           dev/l2src_sandbox/tests/unit_capture_struct_call_arg.lm2
dba58c165082690d68fcdc14ef9149f6cb0d3ca6ea6ef2bd3c03c99af4510c82 M  fable-changed harness           dev/l2src_sandbox/tests/unit_capture_struct_own.lm2
ddca7ffd428a6ba21110125d32352d0f2f4cd57612aa74d40fbb42d8ea268e02 M  fable-changed harness           dev/l2src_sandbox/tests/unit_capture_struct_write_only.lm2
da54df27eb52d9758dda9c7435dfa75b1e8e3cc48635f28bc40ceeffad9b02b9 M  fable-changed harness           dev/l2src_sandbox/tests/unit_capture_struct_write_root.lm2
9c95d8bb65bb324e27c29538db189c275907aa6bb1b42b79ff343921d18b0803 M  inherited     harness           dev/l2src_sandbox/tests/unit_char_own_publish.lm2
cbb22b945f6309f34b75306e396217a0ba99fcc5a6c5bbd4b72a1e554ea98293 M  fable-changed harness           dev/l2src_sandbox/tests/unit_colon_method_dynamic_precedence.lm2
c159db978827417b91af8b12bd31f93f066feaae5c200b6598aa0153a64eac23 M  inherited     harness           dev/l2src_sandbox/tests/unit_colon_method_fresh_per_activation.lm2
6004da1642a59f6a55670c6b6e500d3320462173d53ca66d3ddb51157dddb1cc M  inherited     harness           dev/l2src_sandbox/tests/unit_colon_method_lexical_model.lm2
2e39fb890a29513b74de3df0bfc4455fdb3c1fe7ae33867980049bf86ef83494 M  inherited     harness           dev/l2src_sandbox/tests/unit_colon_undeclared_refused.lm2
25d1b0e3de5d7773e950ef463486b31298963ed4227a9a2ca5fc25c823d01d11 M  inherited     -                 dev/l2src_sandbox/tests/unit_const_char_return.lm2
0677ce7abb5eae557cb6284d826930e158e6f1b353da1d3ea5d9bda91da21743 M  inherited     harness           dev/l2src_sandbox/tests/unit_d101_struct_result_value.lm2
c94a737c8f221e6bf0248e63460755f6c2657a85e97f5a224ad06f14e1950d1e M  inherited     harness           dev/l2src_sandbox/tests/unit_d105n_arg.lm2
d12c115e58b66ffdca384cba6ffee339381e03add0767a12026d9ca087d34ef9 M  inherited     harness           dev/l2src_sandbox/tests/unit_d105n_mixed.lm2
d90a3d0d7eb0bf55164e3179988ae9e9964d5ec9ccd98109a31e0f9d9233e9fa M  inherited     harness           dev/l2src_sandbox/tests/unit_d105n_passon.lm2
a421c4aa3e903d9eae54773a03403c76ec151a0d365b06a74799c2d0bb84f97b M  inherited     harness           dev/l2src_sandbox/tests/unit_d105n_passon_other.lm2
a31fede13c98aaf56df4da0423e6546e3b54b1ffee07d05031956613590efa4c M  inherited     harness           dev/l2src_sandbox/tests/unit_d105n_write.lm2
e982a022f8dcca1c22682bf1336ad1b81fd2acf15f6ddbaf3bbd1995978166d0 M  inherited     harness           dev/l2src_sandbox/tests/unit_d105r_chain.lm2
f06ad31d1929afa0a736d89c34df200daaf61d871bb5f6dd13eff3ed573e97da M  inherited     harness           dev/l2src_sandbox/tests/unit_d105r_edge_refused.lm2
f6beeee10254467446fe0582531f677e425a19d119c786d32081eeb24698903c M  inherited     harness           dev/l2src_sandbox/tests/unit_d105r_formal.lm2
fe46b682034057e8496d9cadb45db745d182bf9ef2452902bfe4e01716f0b8b3 M  inherited     harness           dev/l2src_sandbox/tests/unit_d105r_return.lm2
0297469925f7050e227f6db568702ca5ef2e92fde2961a78e0e5cb0ba7a25f93 M  inherited     harness           dev/l2src_sandbox/tests/unit_d108_nested_throwing.lm2
68445169375cdabf636a081746e0563956472ea0aeb8b8822e9401f5d0ee8c3f M  inherited     harness           dev/l2src_sandbox/tests/unit_d109_uses_refused.lm2
774dfd5d2c4a3a030958edfb301eb39afd63b89764acc6232430125783808351 M  fable-changed harness           dev/l2src_sandbox/tests/unit_d112_nested_return.lm2
a530aa7968e92393a4af4754e785dff410a60eabe05b47d80ce1f2a97bd0db1f M  fable-changed harness           dev/l2src_sandbox/tests/unit_d113_nested_expr.lm2
e5651b6576a57ad61b3a04bd52b0141a5e6d337b59df19083bf4d332f3da93db M  inherited     harness           dev/l2src_sandbox/tests/unit_decl_literal_refused.lm2
3b4cb41e5d7b4d7b97c3ae0b815bf12522052b3aa8ab767e0bbda01c8575cec9 M  inherited     harness           dev/l2src_sandbox/tests/unit_decl_unknown_type_refused.lm2
1568e188f02f9a934536d31c5609567069270007b8420ccafa0811fff40cfad6 M  fable-changed harness           dev/l2src_sandbox/tests/unit_discard_calls.lm2
9b09e82ab993f5995e6e7b39e0ea8e4b1bef3963423b6c593a25c25359454ebb M  fable-changed harness           dev/l2src_sandbox/tests/unit_empty_type_call_method.lm2
12f50bd5cdaa3b99ff542614bd2adf9a31117c939a0bc63fefd6225f089bc404 M  inherited     harness           dev/l2src_sandbox/tests/unit_entry_args.lm2
a458b0434b14ca5cd56b76cb694f3c9166104d1ed6c07cd1803c72836a4b1520 M  inherited     harness           dev/l2src_sandbox/tests/unit_field_path_formal.lm2
53446e91e941c320c910dc2aa870157d34a0018c370580bebe2c4c2c67711599 M  fable-changed harness           dev/l2src_sandbox/tests/unit_field_path_nested.lm2
b12e295451e3157514f97107c54798a3f8cb35000d8c79c314bbea2f9c912972 M  fable-changed harness           dev/l2src_sandbox/tests/unit_field_path_nested_two.lm2
ebc278038be2c1f3f86e5ee67b8041b076aa16ad2854057acb979fb70f530780 M  inherited     harness           dev/l2src_sandbox/tests/unit_field_path_own_write.lm2
7c4c82dbf672ff73e62fbb60b2339591a4aab28eac8019da15f071a48d1ea2d7 M  fable-changed harness           dev/l2src_sandbox/tests/unit_field_path_struct_rebind_refused.lm2
5ff53b6957fc8261889cfcc8cb9611fe8abec0d9fddccbcbca22633751904977 M  inherited     harness           dev/l2src_sandbox/tests/unit_field_path_terminal_checklist.lm2
66ab24061ba254e978a83727a4ba1342c62516a28a6519cd1e53ca6adca58055 M  inherited     harness           dev/l2src_sandbox/tests/unit_field_path_unknown_refused.lm2
33bf65a4486b1095f5c2c7d588885dfe6235d1a10cb3f27f0a3cd6636a2ac3e4 M  inherited     harness           dev/l2src_sandbox/tests/unit_formal_shadows_struct.lm2
9027787423aae4f6ea3d0ebed75c3493b609b73ba6a149fa40d9423a6204316f M  fable-changed harness           dev/l2src_sandbox/tests/unit_formal_spelling_rebind.lm2
166051dd506edab00aec57a08c818c8351c9448a92222a38211b777d99926221 M  fable-changed harness           dev/l2src_sandbox/tests/unit_formal_spelling_rebind_other_refused.lm2
4a8c4bf80ea56494996a626600cc93c28db34166044db670fafa94e3b8e6c32c M  inherited     harness           dev/l2src_sandbox/tests/unit_formal_thin_other.lm2
697ab533608453e56d06e8c6b151983b3e2fcd2bfabd192074a18ede1b02a0b9 M  inherited     harness           dev/l2src_sandbox/tests/unit_formal_used_other_refused.lm2
f5f5bb527a50581f7653bc714ee460cbddb65df23e4d627b1d731bafa11dbe74 M  inherited     harness           dev/l2src_sandbox/tests/unit_free_write.lm2
ee6dff80ef533e8d8bb42c3f21c7bc6b7c89d086dbbd6b943d764df6159811b1 M  inherited     harness           dev/l2src_sandbox/tests/unit_free_write_literal_refused.lm2
b69a8403d55c884fd012a2c1e45e957bc6db5cf9ac3c5197edaff78d7e84d1f7 M  inherited     harness           dev/l2src_sandbox/tests/unit_local_model_arg.lm2
3de2db4ef08f7fbb72cd83f10c66a804efdb016ab1c8b81f7be3b9ca9349030b M  inherited     harness           dev/l2src_sandbox/tests/unit_local_ns_fresh.lm2
6a54d3b37883f30a09661e6ecf0b71d1993d80a3603b066bb307c868a9cfe930 M  inherited     harness           dev/l2src_sandbox/tests/unit_matrix_absent_arrayish_refused.lm2
528c9a4fef0084c645cb17f1a1e62c7d9c36d2ab51528ec9775205f2fbfc6f72 M  inherited     harness           dev/l2src_sandbox/tests/unit_matrix_absent_prim_refused.lm2
b54642c16636959abe58e5e0594df64cbb3607395bda3376d43f35d1046f3304 M  fable-changed harness           dev/l2src_sandbox/tests/unit_matrix_noncall_struct_rebind.lm2
17532485eb06c8fa9bd0037cb4ddb4e7a2392e9098031b1f7ec5468781c2af39 M  fable-changed harness           dev/l2src_sandbox/tests/unit_matrix_path_struct_rebind_refused.lm2
873c84c266fd6e9a387eeccfaee9bd46d18a8f8465e6258783d435b587bcf100 M  fable-changed harness           dev/l2src_sandbox/tests/unit_model_fresh_synonyms.lm2
6f21827817e560fde8757edce62299b1b1deeb1d4d84023d88303e4ff8b8c0f4 M  inherited     harness           dev/l2src_sandbox/tests/unit_model_var_call.lm2
28ba93f939a230446679563e445afdfffa6029c92179e86de9730104ceaaf1fc M  inherited     harness           dev/l2src_sandbox/tests/unit_named_struct_exec_instance.lm2
59b9fb48c3644657a4ac0304f3bdeb52c9932cc10dec8e059d38205eb0a8b2a3 M  inherited     harness           dev/l2src_sandbox/tests/unit_named_struct_exec_two_types.lm2
711a3fcfbe7944b3834393a7ea3e9f15d4a85f664cd9267b596fc04556450025 M  fable-changed harness           dev/l2src_sandbox/tests/unit_native_activation.lm2
4406d0feb28fe52df6a8fa017f3cdb87b1f74259ecefe88edfa56e220db5abd4 M  inherited     harness           dev/l2src_sandbox/tests/unit_native_typed_receive.lm2
6c5631d4baedaa6f73e4077eb440529007873867b7513719fccbd3388e97f482 M  inherited     harness           dev/l2src_sandbox/tests/unit_nested_body_else.lm2
66b13de35e0ff1f197b6e400dab1de99f9fcfa56b71764328b9be7cf447dc67a M  inherited     harness           dev/l2src_sandbox/tests/unit_nested_body_for.lm2
8e40c90296603f47c5d627abd902ae8886b37d983f3446491f6d6f035ca9d51d M  inherited     harness           dev/l2src_sandbox/tests/unit_nested_body_while.lm2
b28f5c95c4aa6c1b1c6797710a144ad0ca1bb932dc1b5d96c5ada6c54d0c7d4e M  fable-changed harness           dev/l2src_sandbox/tests/unit_ns_ref_field_general.lm2
5240cb42c78127c4e3392819f323728a7beb69e13f2f825c14a2755f2e605a70 M  inherited     -                 dev/l2src_sandbox/tests/unit_own_pointer_fields.lm2
4182ff09b3093539298611ed475c32291d4f61b2bc92b3de6a9348f7a38e740f M  inherited     harness           dev/l2src_sandbox/tests/unit_path_chain_method.lm2
1abe82704c87d533269c116e7a4ebf7f43fb74035a794448808aec7ffcc5dd77 M  inherited     harness           dev/l2src_sandbox/tests/unit_path_lit_overflow_refused.lm2
28fb27b4929117a3a6bfbbd19346ac7b3e1b0a7d55822feea79fdd0495dd267d M  inherited     harness           dev/l2src_sandbox/tests/unit_pathconv_ok.lm2
24df65d86d53b7ccce07e1b82e386c33e441c020e5da521c38d4b9ce048750a5 M  inherited     harness           dev/l2src_sandbox/tests/unit_pathconv_range.lm2
6149b695e60be929363a81f395b2347ca1b5b46569d1459459cea54d6f6c532f M  inherited     harness           dev/l2src_sandbox/tests/unit_pathwrite_cell_kept.lm2
62236472c2c8cf2915c439a4ef3d68880cf96a23bf82dac99b7def638c29ba0d M  inherited     harness           dev/l2src_sandbox/tests/unit_pathwrite_ok.lm2
cb030f6586224d8496b2c23697c6230e34be7cae024d99b5dddae1c856e126b6 M  inherited     harness           dev/l2src_sandbox/tests/unit_raw_root_formal_compound.lm2
a2201283401303e8bd044207810052568253c6f2a423eea5a67644d7efaef111 M  inherited     harness           dev/l2src_sandbox/tests/unit_raw_root_model_compound.lm2
ce057316b89c382a21552ff4affa5aa62fd274861bc9bac41026e2f3abdbc3fb M  inherited     harness           dev/l2src_sandbox/tests/unit_recursive_model_slot.lm2
e03f6d04730e4f0db57d7c383e6783a1746006d2b549557a5db9e9aee11b0434 M  fable-changed harness           dev/l2src_sandbox/tests/unit_ref_field_path.lm2
90c5bcd8df980f4ae1699800c3aff34037a9031cae32304eb03f45d4ae3ff3df M  fable-changed harness           dev/l2src_sandbox/tests/unit_ref_formal_path.lm2
e7529054f83ce26615563ad145f95724b5a9c1ad7a3fc825fd4f65ff36439eca M  fable-changed harness           dev/l2src_sandbox/tests/unit_ref_formal_rebind_other_refused.lm2
3b73fee06aa2d7155f52b2be117292cf44899c3910a259e7520ed954b669b1b2 M  fable-changed harness           dev/l2src_sandbox/tests/unit_ref_formal_rebind_same.lm2
4e8368d2964ff4ff69bf10dc9f970fa823037e81e1cdaf71c8572f14242abc43 M  inherited     harness           dev/l2src_sandbox/tests/unit_ref_local_path.lm2
cc804ac0bdc23f76e6d685fa45860452d2249041737245be07657f6aa3672613 M  fable-changed harness           dev/l2src_sandbox/tests/unit_ref_rebind_other_refused.lm2
ff7e6985ef7981e11b059a53c07c438c401b355ddcf419502394bca159fcbed1 M  fable-changed harness           dev/l2src_sandbox/tests/unit_ref_rebind_same.lm2
1c5e1ec0414ed05c2a5ddc0df764c1c4af011d37979b0750d0e7966cfd303a15 M  inherited     harness           dev/l2src_sandbox/tests/unit_root_div_zero_refused.lm2
b46e72d38cedb0d76ba51e4ba9e2da8f8cad7be861c6faa35df6220d720c7de9 M  inherited     -                 dev/l2src_sandbox/tests/unit_root_field_bad_init.lm2
4c4d0281ba3efe20f036a74f522e3ea122f94e4d1e63017dd62574a8ebc627e6 M  inherited     harness           dev/l2src_sandbox/tests/unit_root_field_duplicate.lm2
3a8666b890d1e68609c8de4a11d6883e90388617fc97aad20b758c0db79257ba M  inherited     -                 dev/l2src_sandbox/tests/unit_root_field_method_collision.lm2
0d40657b6bf343d4abd92445d30abe4b6565bb1016b75ddac2c34da662bed9bc M  inherited     -                 dev/l2src_sandbox/tests/unit_root_fields.lm2
f5f49941e8d7291d35b88fe153dfe3bce95dbd191feaf265d501da7e258e6274 M  fable-changed harness           dev/l2src_sandbox/tests/unit_s7_nested_ok.lm2
ffb753d52d2ba48691eecf475b1ddf6ffe4e96783da357642cb892f55bfad91b M  fable-changed harness           dev/l2src_sandbox/tests/unit_s7_nested_shape.lm2
1a5a6705063b3997e2a286ca40ebcee8343f965ac40ed87487613232c9395ccb M  inherited     harness           dev/l2src_sandbox/tests/unit_site_layout_local.lm2
3a3a8642b67a098f795295bb898a9b296679a477b212668d46dd943b551abc89 M  inherited     harness           dev/l2src_sandbox/tests/unit_struct_int_field.lm2
cfcaafde27d40a4ad84dc9d67991cb3187e3e4a99e738da714414a3cca2906a7 M  inherited     harness           dev/l2src_sandbox/tests/unit_struct_return.lm2
1c9c6f161c5744359226d20f80e0ab46b4741ddb56228223119e1c531b7865d3 M  fable-changed harness           dev/l2src_sandbox/tests/unit_struct_return_ref_admit_refused.lm2
7435f5d20daf7cee41db87b6827bc9789830a6677bdef11fa08f02a2b4a387d8 M  fable-changed harness           dev/l2src_sandbox/tests/unit_typed_decl_vertical.lm2
6a1cf0ed6a3538dc407cca22584544e727e801c2db30526c4d18c0be9809bbd8 M  inherited     harness           dev/l2src_sandbox/tests/unit_universal_absent_colon.lm2
41e41a14e0429b447a862c7ea6c44fd3ea15096b58584c0e9e368a2874d270ab M  inherited     harness           dev/l2src_sandbox/tests/unit_universal_absent_paren.lm2
0e3ee6878f65503c06d339022ab3cc2784288cca8cd246b1efe859bb018928e0 M  inherited     harness           dev/l2src_sandbox/tests/unit_universal_absent_vertical.lm2
2db9a950e54662aa520c774c5e3390562cab0c5138e503e5b635f90da41bb86a M  inherited     harness           dev/l2src_sandbox/tests/unit_valkind_ref_ok.lm2
5842a64ee2e65efd56763126e3443943fcc2deb0d6aca6865ade4ef0885c83ff M  inherited     harness           dev/l2src_sandbox/tests/unit_walk_cache_struct_ref.lm2
f5f5bb527a50581f7653bc714ee460cbddb65df23e4d627b1d731bafa11dbe74 M  inherited     harness           dev/l2src_sandbox/tests/unit_walk_free_write.lm2
61cf076c692b291d8c2c58415e58e7c7f8183062dd162ffa2914004bb06552d8 M  inherited     harness           dev/l2src_sandbox/tests/unit_walk_free_write_literal_refused.lm2
b1dccd6b251fbcf0fbfcede1b637136aa83a272bffe75fdf8e6a59f1c7f5ad19 M  inherited     harness           dev/l2src_sandbox/tests/unit_walk_local_ns_stmt.lm2
2c94b2da248e07c65a774eb2bae662ed6f0923a4a2f5899b843c2abacc040dfc M  inherited     l3                dev/l3_interp/tests/l3_n9_walk_selftest.lm1
f30f7dc5896168abdc4588cb89bf6f37265d9dfd1b5e74d5060467ba94cd23d0 M  fable-changed -                 tools/l2_harness.ps1
bb3545c213c543d398aa3d6601fb643d536a1047fc9323a0a0b61bec787d444b M  inherited     -                 tools/l3_type_budget.py
e81aa351c029b3e4cde1ae3ea1ff6a28f68fce5fc010dd4d7b763fad1a0f0e72 M  inherited     -                 tools/run_l3_selftest.py
fd7a0356128fca23d7cee6ab747852c8866ac7f9ced4f97baf08f8a72330e031 ?? inherited-new harness,kernel,l3 dev/l2src_sandbox/lmx_source_names.h.lm1
3171044c201638888d0786b27b6e1cb80cc61de5a63cb90c2a281e9c5fdc4771 ?? inherited-new harness,kernel,l3 dev/l2src_sandbox/lmx_source_names.lm1
bf97096e2ca183571b6e8852b0fc48bd2d5fef505279453e9681ee15ff0add31 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_array_place_selectors.lm2
e87a6562b2628e6b8bb7e8dd4ad22da645483d76320025cdd0f2fb5b5c6d23f0 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_assign_occ.lm2
3e683a9b682bcf2e0138ceab8078459ccab08c3a1387eb440adc456d7ff4734d ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_call.lm2
7a8cbe8370ca11d0afaf6ae852c228feb7c037df386b3991517eb48ee904ec1c ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_call_paren.lm2
8dc989d13bcca74e124c8c30a9c6e65d0ef4781e587991fe95e9352112bc7587 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_callable_formal.lm2
bd384d5ec086ace2cd16326e99cf43a856b8109d649ff31ddad742fb53c34049 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_callable_own.lm2
70ad0fb6a475f9b51b161b33f34560f528b99683f371bb4d11a18477e2b5d707 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_callable_own_init.lm2
08c1810dedb8c1093d074c0392800952f67892a161117960949c6512ec3dbe3b ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_callable_own_site.lm2
6e595644c1d5b0ff1db6c73d5bd111864ce15932785d055f76a271c4f51446af ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_copy_field.lm2
3f0585b90c0e5d647fba33104d1d46754ffeceb8dbeaba78ed60226993d521a6 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_decl_carry.lm2
101a1a15d2d3d6f16619702cf09c39ff59764baeced234de4b51d8a8b2bfe352 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_decl_exact.lm2
7fa4c497bcee4eb845ef583b62474f368aa586860e2f62f2f122c076a23dd0f4 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_decl_init.lm2
bb12aed101c365dce87d231629542fa3c2fdc93fb2ecd03ac0472b7430e34aa1 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_depth6.lm2
adcc0a414eac24982c5cc2f02bef82fc7c0baa4e47401f1ca69b66aada07cf0b ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_discard.lm2
50bc5b88a1145e0f239c5352223194921157b300ea3241b79c5cebea96a6fda7 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_dormant_return_occurrences.lm2
18e6c73d81afd6a2b60401f04a38bb302167863ee5c7758a6702ddabbe99477a ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_dormant_zero_divisor.lm2
8c45f2ecf6e587c55639b0925119f80336e1bf48c8c0a2b802a418a2863cc88c ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_else_method.lm2
8423cd8abfaf920c999c15f0f7d6f88bb5684ad09a9a10572a2f4513e6754368 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_else_source.lm2
051451e5f21de95ae8519a143b18f3443100839a076071b632978c200b35cc9b ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_external_operand.lm2
2ab9327450dc1c91f0d1a35812a99ba8d5b1d26ed7221251cc729025dbb3ead6 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_external_predef.lm2
32c4421f88cb14f2a0625387dac21531a7e6077906821046baf42a856ccde853 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_external_raw.lm2
d90fa8d1eb322e0817ce1641eead9328d4fb31f714d042359a59e5f830d7ff2c ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_fields.lm2
b7d780efc188ae05eaea1ba0fb17c40b733cb498136df5ba5605833f7fd3ec8f ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_for_body.lm2
2ab18ead54b110bccfc4f0ea815769c284fe63965197e45535a29ce502a7b607 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_for_no_init.lm2
06ab502ef4f689a9975dd1eeab712f516bbfeb3a62ef46cfff9189b04565bb34 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_hosted_atoms.lm2
0219a87ffbc350e92dbaac099723a7fcbf4e2b5bb48a00a9e9e3457316c95cc5 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_hosted_fn_field.lm2
e5c223a24685697fcf29cb089672352c35495d6aba078d153fb66c2fc7f2e448 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_hosted_use.lm2
2411f1f0ca482cf2677d37c2c9e5f854f9e3be77fd6be477f53fda986642cbbb ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_if_body.lm2
62a48e3174852d8d9af03bf4e8e0b0aa11a69fd039fc8c9aff797132d623d66c ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_inert_after_return.lm2
a77ce1efb62e3c657b6885b910b665c5f4e2d120ef0e135a3764293c1ebb1d1e ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_inert_control.lm2
5a27d48c8702e6e2cda304fd4e8b08f83a65c9c1240e84bc82ed625c234f09bd ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_inert_deep.lm2
2a646c9476240ec997640bda3f85535166683a2017b3d7e6f35609cdcddba70c ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_inert_mixed_body.lm2
e8d1520dd345dfe1bca1ec3239c2739778664097179d5ad15ba450b56d0d9043 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_inert_multi.lm2
c2c8f57c7734465b18891ad75026099605edd26ba2e5df81feb2d041941c0911 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_inert_multi_method.lm2
ad54690da87273744b7c9466b3ea6788240021da5ad09eac4559f96b87e34ca7 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_inert_pap.lm2
c0c35524b1bd7b72fed0b98462cba4cf495659685eab11fba7f43c005f485e9c ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_inert_t7.lm2
5f7b1317bbe21b48a064dd48c3310c87db8238c3228f439a987a21e872905dcc ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_keep.lm2
deb032e1a8846362264d6b1dc6f41f16c8531cb04e99ee5b3483cabbc3c5b975 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_known_atom.lm2
5afc10f379155e3ac6f55e8990aba087bd3c5cc4902f2c00cb4596464c4e9d15 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_machine_cast_bindings.lm2
77eefbfabacdae7302d4e4f7c96ad305577167f0a6552c28fc0b9444b83639c6 ?? fable-new     harness           dev/l2src_sandbox/tests/graph_shape_machine_local.lm2
afce6f9375f2d52e81b81c8dfa6ba9bd060a8238525d864ffeaaf0cee6aaf99c ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_arrarr.lm2
68b11e7acd22ce9630f0fdc159ca63137b3b43acc276e47fd3bf373e152d99d6 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_array.lm2
9dcc06bc17f89d85e658e73c64f1b5d27e857e84b183e3c7bfae7217b9fa7377 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_atoms.lm2
d62d17810da186aeaa53ceff523d7831c3b8ee42f8c336b4e80fe6c6172a2430 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_deep.lm2
e58f2de8ce8e999ad24308c224b64bfdf1100060f7b9846975f1d147950013cf ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_explicit_copy.lm2
1f208ff75a18fa20d7d8a7b6685afdd0bdc69759de5b0a5e7c5968e942658d19 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_fields.lm2
4c3bd21a1a7dfc7116d47afd89eba86f385c02137d7b48249e12c75ac0817cb5 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_fn.lm2
95fdc6b13c73c41143c05e71d667946954bad9cb0570fe550fc737f762f6b121 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_if.lm2
c7d9516706196e28b57c69b03e4e1c5a55ac04b86202973b0a08ae525ca31875 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_nest.lm2
63e92ab77c314566f3e078c1be30a163f07e4e228a4993ce279c4160ef3b25c0 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_order.lm2
bbef3edc95cd730ae3f5916456aa411e52a96a82148a1513e6d529dede440524 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_method_ptr.lm2
17d61cda54030bd47ac99f3a90ca999d9f95370321e3a3473390b8cc26d91e99 ?? fable-changed harness           dev/l2src_sandbox/tests/graph_shape_method_ref.lm2
c41a9b92e71dd64a8de1b9abf0cf590ded78a6ab2a231ab36d5e27ab129013b1 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_mixed.lm2
05d47c11b54e6b563a6d8a8209510c365df13bdd18fb37d94e3b8144eb73d680 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_mixed_decl_order.lm2
bba83bdf16dfa0c90e4c2f57768940bd313114126581cc417f437383d92f40c3 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_mut_empty.lm2
a2362a9bb9960efeaa430e55b0359ca69b0104760d99453d1d7a7bc09aaafba7 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_nest2.lm2
12e8694df0c044928477e018e2ede295aa47bbcc5b456054fe95677ea7b95034 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_array_read.lm2
fca3fef69f9bd82a20349e1136e19815155dcf40db59b16a8b8203f3ccdc55f8 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_bare_array.lm2
0399d944bb1004373567dd03833636fe894ed153fb1063c855801c520d2a4c59 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_constructors.lm2
3fc695d321d5dffee3ffec8b3cffba5233a22bf63bc7c294177eebd9e871b701 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_dormant.lm2
23d9ce3c038b7e2325f5493154b77a8df543c845cac4009cb1e0ae8f461a46cd ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_nested_called.lm2
fd0782a07f02290184dd7669f7334a07b44c96a39db3a83bc52ab6badc39b31f ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_nested_copy.lm2
befbf9db331701e142f0f3a2579c8e449c7bb72e7566db84e64995649f402d42 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_nested_dormant.lm2
069d92e08dee1ad9b6b7d8c53e53c67de574b0da56a05bd0a7f19aeb68751a89 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_nested_node.lm2
6185e71078c3c352e7545cc0e6df7de54ed4c8bd3a808a4f0a90abd76ea8cb31 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_nested_siblings.lm2
7232894fbdb5556b2b5f9902aebc7ff43ce0224e889bbdc1f805c8359a0da119 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_order.lm2
228b856b1aac857bf43c0f918af58f26fb112c14dcb1016c7c45bfe918902875 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_pointer_depth3.lm2
d9ea98d1391e945d78c3bb2506d72eadfa0f7abe15f40f989c6553a1ac36ad02 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_repeated.lm2
a3907523c23a5210f8f3de656d2a043cab5eedd8a09511dcd8bb4442f17ae9d9 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_ns_source_trailer.lm2
644756439aa2951c5689418713a65a09d920c1b450592c960050263e31ae89dc ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_occ.lm2
116d7f002d3df157ea1a565efea839ed712954895921a219d620e1308ab8b548 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_occurrences24.lm2
d7ec8c84993112873eb4040db7d54f966049cf068582fe66aca16f38d39e45ed ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_pointer_index.lm2
18759e9bde788129fabb84d141f6376647ed3963224c16670ba7992ab695b5a6 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_profile_name_root.lm2
2120385dcf4daa6ac9b7322925fa728f8cd79657391989d4e0f88169a6d949a0 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_reenter.lm2
5b1970d04d07affe394443f1dde42d2b37c35696572df403d679c0aa27ceebc3 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_repeat.lm2
25b8388fc596df9fe2b5038e6ca443012a8f6aa707fc598c771c97495039dc31 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_repeat_use.lm2
15a228940b0462d75cb5fe0bf2f748707786756da638354eece369d657e4a7cc ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_return_first_body.lm2
ce1ec1b93abbd0b2ebe6bff74292931cc87dafe1d4c09c755742ded4fa8c0d2f ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_return_occurrences.lm2
14febefd1fa066ca94ed83bd48a9637c5b4d2c8485414d8fff0c049044700f1e ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_root_definition_order.lm2
f0183fab8f06631f6b79182e329794d3b01169a3f4b0d89f93e7c12017b6abfc ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_root_method_order.lm2
9504b85aa1540c7ca0037f635324f5be9490ca0a06875fe56fc029952713b85e ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_source_boundaries.lm2
b48df4b2eb1181f8901d3c5168120a0aebbefbd8e02bbe60971a2c92fb840492 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_t7_local_callable_field.lm2
47889f7bf84c00ea22ab5415d47a2306a14b374470b545bedb132fc5134af3ca ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_t7_local_definition.lm2
11a65fc6d5699d5cdea8df4131b32029f2da1902152a1d1d28b239eef25f3f4c ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_t7_owned_body.lm2
e54a577a03d3b78c24dbc6ced217d32b5e0d9e7d787bfad9206fb7771e4c6af0 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_unit_order.lm2
124e2bfe4ecaa4e24b4935fa9f96ae6388165f6d28596bc4fda3e3529608bd49 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_unknown_empty.lm2
9417a5c202779e60373a96497ca0780f9f261a2fccce1179458f6ef38b9627ff ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_unknown_nest.lm2
8a5b55fea33327358bf33b72fc96c658a6b5bd814fac0394d87e3f3700d7ab7d ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_unknown_paren.lm2
aa46a79e3dde727816e114365a4cacb80b0b5453191ffe31acf199d6781252f9 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_value_order.lm2
673c6f3df009ede38bf22908999d2916f5a2a51a44c6d05e8bf12a97f2422d05 ?? inherited-new harness           dev/l2src_sandbox/tests/graph_shape_while_body.lm2
10074065c8da1844aa3465ee076624391aba5d56d5a3527f5fc681c75d25435b ?? inherited-new kernel            dev/l2src_sandbox/tests/lmx_merge_root_identity_selftest.lm1
d868decf5597f774b8236939ebc60ed6d2f80751281500ce36aa62a4e31fdb66 ?? inherited-new kernel            dev/l2src_sandbox/tests/lmx_source_names_selftest.lm1
c2ec23a13990dc33af07e1309db31626ef2c28371cc3e55bfd1c7491b8633d00 ?? inherited-new kernel            dev/l2src_sandbox/tests/lmx_walk_output_place_selftest.lm1
0bb043303a30af2972656d8897ed9302269a21236c79f29507789677ae4ace3c ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_catch_pt.lm2
81bd3526d98a43b28136db0b045288de1f92f5f084bf623cacc6d88c84b1016b ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_else.lm2
92eff435c3acb3dade6d0ee63a20a28801e336f0a11f03cffdd5894b53e18243 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_else_for.lm2
1db804a4494ade5e2d6204f99183dfeae40346137aa118143eb1f6b4313de313 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_else_unwalked.lm2
c82d6f18094c32c5b241655ac38eefe90dea3ca6490185c9be3d3cc00f754572 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_else_while.lm2
60905cad95b44887f954b934c0bf5f112bb3ebe56b5075fb72513d9f465d9c44 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_else_while_pt.lm2
3b45cdbc91ed15505d306b7d4cdfcc4e1d8a91181bb9cb2f71649dd7d6bdc312 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_for_else.lm2
4a1a8d5858f85ace8124ac81439733e00f480bbcac38a2edb3b1f686229789d0 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_for_pt.lm2
0b94e1029bc113c7b867f6f174e5807ea54526eb11008ca54b2183b28cb0f10e ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_if_pt.lm2
498c65c9a6825ef9f92e36eb6fcbba3a4eafca93b3fbacf810a71b573d038e4c ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_merge_pt.lm2
e80b648a583845a06d829249c86a3fe8a5247f221e9dcc7f3561db0df7a2364b ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_until_pt.lm2
c8824a71b54b01a7b8bcf98c7bfa110ebef8c5ba36b88961ed7d65ee8070e354 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_while_else.lm2
8414daec54edca57f3f18af7b03b1c3db9531b2f693db864a4f8d2bbbd70ebc2 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_body_path_while_pt.lm2
8dd5bfb36af843ea3f55746797356891eaa8e5424038c94aa6983c80059ae472 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_graph_formal_literal_binding.lm2
7db4c5515a88db60fbf8356963370557b2b0b58c754a4c0330821dc5d0f716fb ?? inherited-new harness           dev/l2src_sandbox/tests/unit_graph_hidden_literal_binding.lm2
36c58290828699a7f6be7b18cdb21014b37cade9576549923bd53abb9c7a35b6 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_graph_hidden_literal_no_field.lm2
f16f0a9302f1a7478fd8594698313080468a88bcccf96daba036553806f1e367 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_graph_predef_shadow.lm2
bb50fa4d18b4f45e1b42dafa405e917dfed5f36122a6a9a9f95ff3678d523044 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_held_nullary_source_field.lm2
a4babfc747f9babb5be11b64c1e8e14701f51a068858f328b3a102658723c659 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_local_callable_explicit_copy.lm2
d1a5c75355969d99182230d67ddd72a156c9b55b3ce2d0abfded19c4265c798e ?? inherited-new harness           dev/l2src_sandbox/tests/unit_local_source_binding_context.lm2
a27f033a56aa8063b2f439f0657db44b3c5729e01f37eab42db0b3579647441a ?? inherited-new harness           dev/l2src_sandbox/tests/unit_local_source_layout.lm2
791ae9328d4adb5752d7f855629af300f45557537a9f845387bd15043334e54f ?? inherited-new harness           dev/l2src_sandbox/tests/unit_local_source_merge_context.lm2
540d551d060464776a31488dd692bbb9eda04383acc46bc00e56b9f9b3da2170 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_merge_future_decl.lm2
1adaae3c5dd855c8f2ce9393fe59f34d781ffdb8f1f45ac594b32f082bd16c8a ?? inherited-new harness           dev/l2src_sandbox/tests/unit_named_until_canonical_copy.lm2
efa068cca76e5534e9f412ab1df866daf1f712698ed2313b00ff6c574bc7596f ?? inherited-new harness           dev/l2src_sandbox/tests/unit_named_until_copy_call.lm2
81356e6c538272a934e637215df3a464ee0fb252cb76c19c44f0b695481b67bc ?? inherited-new harness           dev/l2src_sandbox/tests/unit_named_until_field_place.lm2
b34b5c7a2e849fc8fb9ec1b94df791a09a5a377eb8b919757f9857f2908a012d ?? inherited-new harness           dev/l2src_sandbox/tests/unit_ns_reference_first_other_field_refused.lm2
6c8f2af881a325d715000b4e382006d15ac63614b72bb6cb5d96f207704e2aa5 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_ns_reference_last_other_field_refused.lm2
6db4d5e4aecf9e7db3b8dd351e1087f064a269249de3164f0956f99d5b69ec7e ?? inherited-new harness           dev/l2src_sandbox/tests/unit_ns_reference_occurrence_contract.lm2
4d8df2739bd5a2be1962417372fc91b9052a8cf5a49e2d4577307cb3dc4cd01a ?? inherited-new harness           dev/l2src_sandbox/tests/unit_ns_source_trailer_value_refused.lm2
3e347e9ebbf375ec24899fa992b2b43e1b5c47506b2054b0a3ecca035219e02f ?? inherited-new harness           dev/l2src_sandbox/tests/unit_opaque_reference_ordinal_flow.lm2
cf86d767495172302b15324a5538ea82522df7efa583f7ddaa8bd484c731e437 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_opaque_reference_source_chain.lm2
3bfc57c00f56db33bbce6aa35e2fb1ec50051eb584dc26e3b0451511b8b6a142 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_output_future_decl.lm2
e92df25ef368ba26e1ff993d34598674ba3669924bfdc7ac16ac37165416bef4 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_output_future_decl_method.lm2
a86e69e3a989fed89c0f1d951390e150591eadbd53aa7b6f7f9880b5b7ad214f ?? inherited-new harness           dev/l2src_sandbox/tests/unit_output_nested.lm2
3b341add332f26ee2192f6cdbdb93605cbec82cfaac20faecb693ba738a3febc ?? inherited-new harness           dev/l2src_sandbox/tests/unit_output_repeated.lm2
d3460f2cc0e7d662f568d35cee3d4c512fdcfd982ebb3609ecf34ce30eca7121 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_output_typed_target.lm2
85cb5a325dce9829716f978a96755d97d084974d97c8d43a7e8cd412600b96f9 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_profile_spelling_l1.lm2
65ffa626f364486e7fd0c0713b79ab679bf8f11465e82cc24dd5e6bbd7788737 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_profile_spelling_l3.lm2
bb939bc0c29c62df1a79cb3b624bb993ed4e2bff2a288267b92075b1914f86af ?? inherited-new harness           dev/l2src_sandbox/tests/unit_raw_pointer_index_chain.lm2
6dc6e170dee7860f95589fccd7293d8d03d14a8a4803edf0e7ff699c9715ee9c ?? inherited-new harness           dev/l2src_sandbox/tests/unit_raw_pointer_index_expression.lm2
a8199a0d22c24b2040e9ea1db3c095a3b0fea2b0778ebf9baf444ef2a9881d7c ?? inherited-new harness           dev/l2src_sandbox/tests/unit_raw_pointer_index_types.lm2
b6de16b55b4174bc123916e156de78d33e13482585b016f3fe35986120b30ef3 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_receive_else_body.lm2
cbf469c0cf97978783e6c9566f460a01c84b77ae7c732f776811ece2f0a91050 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_ref_absent_at.lm2
a4273e86580e75c1f1754d3d50595677e10a348800403685a2145d31781a496f ?? inherited-new harness           dev/l2src_sandbox/tests/unit_ref_absent_colon.lm2
d3e4981b5f2bcf752c98887c6c485c1857626b11e39dcd4f5b8550ba97e7756d ?? inherited-new harness           dev/l2src_sandbox/tests/unit_return_fn_level.lm2
f84e55cbdb17d4554e8029162ac4e5a14264a80bf6248ce2dd5159111b11dc4b ?? inherited-new harness           dev/l2src_sandbox/tests/unit_struct_call_refused.lm2
6e6ff1461ad41667d613dac29fb9945d62f1f0c023b1369fff4ff9e829121882 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_walk_body_path_else.lm2
42d8ddab736a1a3b7c3db8f0938acdb2a7a87582ce09e0efdbcf45d96bfedaa5 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_walk_body_path_else_for.lm2
cd95ef38eb798ccafca943516a1b1d8fc0043b1fe165c220b75e87d868654337 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_walk_body_path_else_while.lm2
705075c5c6b84297b4b7b4ebfabbea94ca3c2bb93cb16e0bb8f6a88a407ff360 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_walk_body_path_for_else.lm2
84dc2c7e3adc353c22ece2e770f94b0bcbdaf516beb56fff180e592e2e1ff2d9 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_walk_body_path_while_else.lm2
4182ff09b3093539298611ed475c32291d4f61b2bc92b3de6a9348f7a38e740f ?? inherited-new harness           dev/l2src_sandbox/tests/unit_walk_path_chain_method.lm2
b6de16b55b4174bc123916e156de78d33e13482585b016f3fe35986120b30ef3 ?? inherited-new harness           dev/l2src_sandbox/tests/unit_walk_receive_else_body.lm2
89d4c15a6c2f570bbf7cd6d2e0522470fc38915979918e04f47447412a11b801 ?? inherited-new -                 tools/test_l2_walk_graph_facts.ps1
```

## Rows left red by `fable_full_04`

70 rows of 1401 targets. The grouping by mechanism is in the
[ledger](fable-continuation-20261003.md#remaining).

```text
unit_uniform_foreign_results	l2trans produced no L1; see the log
unit_uniform_aggregate	l2trans produced no L1; see the log
unit_indent_stack_field_index	l2trans produced no L1; see the log
entry_array_leading_zero	l2trans produced no L1; see the log
unit_receive_letter_model	l2trans produced no L1; see the log
unit_send_ref_method	l2trans produced no L1; see the log
unit_send_ref_driver_tap	l2trans produced no L1; see the log
unit_next_message_word_refused	l2trans ACCEPTED a fixture that must be refused
unit_arr_path_read	refused, but not with "L2 operation outside a method body"
entry_arg_len	l2trans produced no L1; see the log
entry_index	l2trans produced no L1; see the log
entry_strcmp	l2trans produced no L1; see the log
unit_l2_puts_library	l2trans produced no L1; see the log
unit_charpp_return	l2trans produced no L1; see the log
entry_parse_min	refused, but not with "L2 operation outside a method body"
unit_arr_path_variable_index_refused	refused, but not with "an indexed field path needs decimal literal indices"
unit_arr_path_inner_value_refused	refused, but not with "an inner Array is a value only inside length()"
unit_arr_path_three_refused	refused, but not with "an indexed field path needs decimal literal indices"
unit_asgn_fallback	refused, but not with "unit_asgn_fallback.lm2:21:1: unbound dynamic input x"
entry_ret_tr_bad	l2trans ACCEPTED a fixture that must be refused
unit_eternal_shape	l2trans produced no L1; see the log
unit_make_adder_activation	the generated L1 lacks "lmx_arena_ref_store(l2_madc, 2U, l2_mad_cell)"
unit_capture_struct_own	l2trans produced no L1; see the log
unit_capture_struct_whole_refused	refused, but not with ":21:5: a callable merge needs a walkable body: it can throw (a throwing method stays native)"
unit_capture_struct_call_arg	l2trans produced no L1; see the log
unit_t7_convert	l2trans produced no L1; see the log
unit_rhs_compound_admission_refused	l2trans produced no L1; see the log
unit_rhs_reference_admission	l2trans produced no L1; see the log
unit_bind_method_thin_other	ran under the driver, exit 1; see the log
unit_named_struct_exec_instance	l2trans produced no L1; see the log
unit_callable_sub_transport	l2trans produced no L1; see the log
unit_callable_forward	l2trans produced no L1; see the log
unit_callable_nullary_forms	l2trans produced no L1; see the log
unit_callable_returning_two_contracts	l2trans produced no L1; see the log
unit_occ_selector_last_refused	refused, but not with "implements is false in function argument"
unit_d112_nested_return	l2trans produced no L1; see the log
unit_d113_nested_expr	l2trans produced no L1; see the log
unit_named_struct_exec_two_types	l2trans produced no L1; see the log
unit_model_var_call	l2trans produced no L1; see the log
unit_root_model_field	the generated L1 lacks "@: Lmx l2_rw2 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw0, c.LMX_WALK_OP_PRIM_PUB, 4U)"
unit_arg_addr_dyn_types	l2trans produced no L1; see the log
unit_empty_type_call_method	l2trans produced no L1; see the log
unit_held_nullary_source_field	l2trans produced no L1; see the log
unit_puts_main_beside_method	l2trans ACCEPTED a fixture that must be refused
unit_colon_hidden_update	l2trans produced no L1; see the log
unit_array_value_projection	l2trans produced no L1; see the log
unit_address_array_descriptor	l2trans produced no L1; see the log
unit_array_index_shadow	l2trans produced no L1; see the log
unit_field_path_unit_colon	the generated L1 lacks "c.LMX_WALK_OP_PUT_OF, 4U)"
unit_addr_slot_structure_projection	l2trans ACCEPTED a fixture that must be refused
unit_addr_entry_name_collision	l2trans ACCEPTED a fixture that must be refused
unit_addr_own_array_element	l2trans produced no L1; see the log
unit_addr_own_array_arith	l2trans produced no L1; see the log
unit_own_dirty_rhs	l2trans produced no L1; see the log
graph_shape_ns_source_nested_copy	l2trans produced no L1; see the log
graph_shape_ns_source_nested_copy_walk_methods	l2trans produced no L1; see the log
unit_array_write_general_root_real_field	refused, but not with "unsupported index"
unit_s7_nested_shape	l2trans produced no L1; see the log
unit_s7_arg_deep	l2trans produced no L1; see the log
unit_s7_ret_deep	l2trans produced no L1; see the log
unit_s7_ret_field	l2trans produced no L1; see the log
unit_s7_part_root_below_refused	l2trans ACCEPTED a fixture that must be refused
unit_matrix_callable_struct_identity	the generated L1 lacks "@: Lmx l2_rw4 lmx_walk_frame(l2_program_arena, l2_rw_roles, l2_rw3, c.LMX_WALK_OP_OWN, 3U)"
unit_named_actual_whole	l2trans produced no L1; see the log
unit_free_conv	l2trans produced no L1; see the log
unit_walk_free_conv	l2trans produced no L1; see the log
unit_named_until_copy_call	l2trans produced no L1; see the log
unit_named_until_copy_call_walk	l2trans produced no L1; see the log
parser_alloc_port	l2trans produced no L1; see the log
parser_trailer_role	l2trans produced no L1; see the log
```
