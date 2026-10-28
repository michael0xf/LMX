$ErrorActionPreference='Stop'
if([IO.Path]::GetFullPath((Get-Location).Path) -ne [IO.Path]::GetFullPath('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src')){throw 'Unexpected CWD'}
$taskPins=@'
[
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/l1trans.exe","sha256":"3C8976D7001871A919103A9A89E9AAE27A99018FC657F3F582485911F6F20BA5"},
{"path":"C:/Git/usr/bin/timeout.exe","sha256":"4B83B85F7B2AFC718334F6669FACED88B47A11C492E4325A97FB519BEAB401E4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/frontend-source.lm1","sha256":"CBF343676F3E45B7D30015946039A1472E9CB65D6BC154EC8255934C4C295B53"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l1src/libc_abi.lm1","sha256":"83263D08F53033E5C19F72CD23BA14FF801F30EDB850D01823882E005B17540A"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l1src/own.h.lm1","sha256":"732EDEE02E6959735147D27032C56AFD733E441B11212F07A15F72CFF4A584BD"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l1src/p0.h.lm1","sha256":"39CE0459B712A3034388FB8924C4F9104EE5A36EBFEDD2E3CE111C46EC22F2A7"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l1src/p0_own_state.lm1","sha256":"93B7C7A193BDD4C880426F06B5B7409DB52D2363F1EE53E0209F70C6C348D9ED"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l1src/parser.lm1","sha256":"79B6D57948E2CF2956B8CD44391F6753239009F3603B796E95170E2ADA739A32"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_application.h.lm1","sha256":"2CB336C74624D96EF7A0387406F66FDCAED462F604296332A60052820C10B0F9"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_consumer_uses.h.lm1","sha256":"7DF10E50386D9F9984C9D091E806FA2C26506E7C7E22FA911915477BEB34BB4A"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_consumer_uses.lm1","sha256":"2FBF0EAEA60FD06CF636E0ABA2675C7F97C8CDF15CF74EC66D0274B47E9A86D0"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_consumer_uses_abi.h.lm1","sha256":"F341D312D7A94D7EB52528EFA9142E26BC50B99190C312F05800530E7713656A"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_copy_uses.h.lm1","sha256":"D003483E10E62769AFE3877F8C00CFD785CA126CBF1B023735C010DCAF8D81FB"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_copy_uses.lm1","sha256":"98EDA4C50E4B8A12CA45DC58CCF9E437113206AA433958738CDE21D4B2FDCCDC"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_alloc.h.lm1","sha256":"16D51747BB568E136A2CD8B1A69B9152399FCBE176A7621BC12C423EB50AABD2"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_alloc.lm1","sha256":"1916AFB1B8480538D9CB1D40BA0B4C41845214297515FB773DE87A427A7C703E"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_context.h.lm1","sha256":"F66863F93BEEFAB54FBF350B827A03D39A28DC8DF3140DCDEB2DFD9C46F8F0FC"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_context.lm1","sha256":"7ED98C91E404BB53145FC3C12E59A19D84F7C16037B9A14231426DBBF617B941"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_coords.h.lm1","sha256":"E6585660AA179D43E5DD01E57A4918A2B55811CE265EC26B4056B51E01A09BC4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_coords.lm1","sha256":"5E8A9095A119A8A2807EBFD4063F6C83DC0ED434D531213DE4FE78E34736D370"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_core.h.lm1","sha256":"DA71B0941FCBA80B8017F94FA5BDBBCC332DAC7D6D4C68480827A36FAE7AFE3F"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_core.lm1","sha256":"D914DB32336BA2C07FD2E67CB8FCA892A1EFC44BA33A0E6524D250E7BE5A3383"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_emit.h.lm1","sha256":"E9B98CE34B53B950B5E6490AF0FF84A1C250C87CA44822B71C9D68340B2CBE70"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_emit.lm1","sha256":"675E84DCF9F62B5690DBF8D09427D25BE5C9E7E339147048E7D4E4AECBC839BD"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_helpers.h.lm1","sha256":"3F072BAF3F74C78C9EA1E9695DE87B022B7653D0750AFBE6DA3551AF0C9787CE"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_helpers.lm1","sha256":"DCCF83392559D2ADC0EB296FDE1B068960A14709463B2BF9B0F425427A377B8C"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_intern.h.lm1","sha256":"111518F89964710F06CE86144D89343AF74D2DC8EDDDF73BCC5A25EED8652651"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_intern.lm1","sha256":"3C394F701E8D0252700E77BD77572AD27C02393B89739C5F4A90C90C7C7D0918"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_lower.h.lm1","sha256":"2A952F2652C44D969641ED4B3F403264CCC5CB15E0D23C0F27DEF04D1AB863A2"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_lower.lm1","sha256":"730E0572CD68520297C538A21CF885B8143204ACB00E83BDA262FACE3019E8A9"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_resolve.h.lm1","sha256":"4EABD272EA804E8EAA97A60C6D9B8CE72C0A711B3736FAF140514F9AE214C07F"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_resolve.lm1","sha256":"5AA2B6CD23D6DFF4A88BE2D2ACA71D3AB3BE0BC3B24DDD40F36BB7488B661C88"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_state.lm1","sha256":"BE6FA6AC7B18717079C7A37C1420B8E6563299577903FE09AE1831D93CE71A8B"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_types.h.lm1","sha256":"0468457F8562FE539FE9BFD1C272C8ED7C987E72C4F7006DE7A76B4E0A17BFAD"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_types.lm1","sha256":"B5EB2FE1D088BB4E1B8B846ADA1E5D20DE4BD4998208F75EF89717457EF753C4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_useplan.h.lm1","sha256":"9F562C58B5C1F67CE16DA2CDDA8B63D1C8DE0D025AFBB8CAA5D5E38F4A2625CF"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_useplan.lm1","sha256":"E0F9BF10E71C31C304E02AE272F17968673B72D664C31B9E699B0E8684EA2D8B"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_values.h.lm1","sha256":"8D44D2BA659C113155FF08E577E56EDE09D6E919BC8B96D8FCA777FF039111C4"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_values.lm1","sha256":"CCCF77238A57210D3CC6D8A266E73046F0EA850796D646A22EA025C4DA017055"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_views.h.lm1","sha256":"D063392B26884D87EAFEB2684A3C364ADBD9B71C25E4241D3F1D4E6B19DAC44E"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_frontend_views.lm1","sha256":"905AF4055DBBC187A65348C973FCA2D8504E098ADBE33F8D5F15271DC520DC92"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_immut_query.h.lm1","sha256":"753CEB8E58C1E859CA9B3E2EFD15165889B4E7E321642775A154DBAA77771DCB"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_machine_types.h.lm1","sha256":"BD6E6D601DCC9F2CD5029B0AF4D27D752429BFDF4A05186C70738C714C692960"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_machine_types.lm1","sha256":"186D484B86595CE5B8656024DDDA7A37C93057402FE7F23C4542DCEB57650932"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_machine_types_abi.h.lm1","sha256":"E2415F54BCB5C5CD2FC23B49D05F18E9075EF9F50DB7A16DEF12278DB88AF321"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_receiving_source.h.lm1","sha256":"4653867ACB38ACE402C449EE27F71E6E887EC0A9579C898D986901AE20A3E7F0"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_receiving_source.lm1","sha256":"FDF19629B1A5E0D5CE4EC0A8CA01C95DF022915094FC0F7E3FD931A4B54696F9"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/l2_receiving_source_abi.h.lm1","sha256":"47E90F76AA0FC5383458F751B9ADDE26482217A7A06F2F551392D893000535AA"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/p0_own.h.lm1","sha256":"3D6D72F1A4F89AED3C1B46BAF08DC1E12A5A11B17696783D88BAEF58532D5078"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/p0_own.lm1","sha256":"D01A4B2480BF179158C7EBADAFCE54C73563ADE2481F984BD5CE71052205EAC5"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/p0_parser.h.lm1","sha256":"3026A919DD26440A1B581D3B656A8F937342D950F7470C1F5ED63FBE4D5502FC"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/p0_parser.lm1","sha256":"411E5B3B1912E3272D9E9ED2D3691F451429D3BCEE340CA3EB9B4DDEB12FE562"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/p0_scan.h.lm1","sha256":"B54BC16CBA6A69672291B6CE57EC7B02766659DFFDB34C1B28FD5BA119274C7A"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/p0_scan.lm1","sha256":"65023C1A6E608947D356A02EA56ACEC7297B59ED12013CF0A7362CAC6A39C943"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/p0_text.h.lm1","sha256":"0A612C2C8C603012E978662989002908F7301E53AE07B4A6483AEEFB56D51A11"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/p0_text.lm1","sha256":"DCACBFDE7FD46887FA8CD92D3262E7B745BD7364229246704E82CA06CFDABD69"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/parser_alloc_port_l2.h.lm1","sha256":"E67CEA1DEA68EBB2023CF4F5132DF21A44D287EF09625D90A46A55F1B2829056"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/parser_scan_port_l2.h.lm1","sha256":"5D189F67A519A39443920110DCC0D2FA8071F342F90F7716CB75832887D62C53"},
{"path":"C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/src/l2src/parser_text_port_l2.h.lm1","sha256":"F29EA2357B05E1AF1BDC96B54E1258382D19BA50E0BB34C89E44434F0B0477E2"}
]
'@|ConvertFrom-Json
if(@($taskPins).Count -ne 59){throw ('Pin count '+@($taskPins).Count+' is not 59: the emitter body/header pins are missing')}
foreach($taskG in $taskPins){if((Get-FileHash -LiteralPath $taskG.path).Hash -ne $taskG.sha256){throw ('Changed root L1 input: '+$taskG.path)}}
if(@(Get-CimInstance Win32_Process|Where-Object{$_.Name -match '^(gcc|cc1|collect2|ld|as|l1trans|l2trans)\.exe$'}).Count -ne 0){throw 'Compiler pipeline running'}
$taskFree=(Get-CimInstance Win32_OperatingSystem).FreeVirtualMemory
if($taskFree -lt 838861){throw 'Insufficient VM'}
foreach($taskF in @('C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/frontend.c','C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/L1.log')){if(Test-Path -LiteralPath $taskF){throw ('Output exists: '+$taskF)}}
'StartUTC '+[DateTime]::UtcNow.ToString('o')
'PreVMKiB '+$taskFree
$taskWatch=[Diagnostics.Stopwatch]::StartNew()
& 'C:/Git/usr/bin/timeout.exe' '1800' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/l1trans.exe' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/frontend-source.lm1' 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/frontend.c' *> 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/L1.log'
$taskExit=$LASTEXITCODE
$taskWatch.Stop()
'EndUTC '+[DateTime]::UtcNow.ToString('o')
'ElapsedSeconds '+$taskWatch.Elapsed.TotalSeconds
'Exit '+$taskExit
if($taskExit -ne 0){Get-Content -LiteralPath 'C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/warm-frontend41/L1.log' -Tail 24}
exit $taskExit
