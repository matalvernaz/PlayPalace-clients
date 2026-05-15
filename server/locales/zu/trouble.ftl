# Trouble — zu
# AI-translated with limited fluency, native review strongly recommended.
game-name-trouble = Trouble

trouble-rules =
    I-Trouble ngumdlalo wokucijela owomndeni weParcheesi.
    Umdlali ngamunye uqala namatokeni akhe endaweni yeKhaya.
    Ekhonweni lakho, cindezela idayisi futhi uhambise elinye lamatokeni akho.
    Ngokuzenzakalelayo kufanele uphose i-6 ukukhulula itokeni elivela eKhaya liye emzileni.
    Ngokuzenzakalelayo, ukuphosa i-6 kunikeza nethuba elengeziwe.
    Amatokeni anyakaza ngokulandela ihora emzileni ohlanganyelwe aya endaweni yokuphela.
    Ukufika etokeni elimelene nawe lithumela emuva eKhaya lawo, ngaphandle uma indawo ivikelwe.
    Lapho wonke amatokeni akho efinyelela ekupheleni, uyawina.
    Kumodi yethimba, ithimba lakho liyawina lapho bonke abasebenzisi bephothula.
    Izinkinobho ze-1 kuya ku-6 zikhetha itokeni, R iphose.
    Cindezela u-E noma nini ukuze uzwe isimo esiphelele sebhodi.

trouble-action-roll = Cindezela idayisi
trouble-action-move-token = Hambisa itokeni { $token }
trouble-action-check-board = Bheka ibhodi

trouble-token-label-home = Itokeni { $token }: eKhaya
trouble-token-label-track = Itokeni { $token }: indawo { $position } yomzila
trouble-token-label-finish-lane = Itokeni { $token }: umzila wokuphela { $position } kwa-{ $total }
trouble-token-label-finished = Itokeni { $token }: liphothuliwe

trouble-rolled = { $player } uphose i-{ $roll }.
trouble-leave-home = { $player } ukhulula itokeni { $token } emzileni.
trouble-advance-track = { $player } uhambisa itokeni { $token } endaweni { $position }.
trouble-enter-finish-lane = { $player } ufaka itokeni { $token } emzileni wokuphela.
trouble-advance-finish-lane =
    { $player } uhambisa itokeni { $token } endaweni { $position } kwa-{ $total } yomzila wokuphela.
trouble-token-finished = Itokeni { $token } lika-{ $player } lifinyelela ekupheleni.
trouble-bump =
    Itokeni { $token } lika-{ $player } lithumela itokeni { $opp_token } lika-{ $opponent } emuva eKhaya.
trouble-no-legal-move = { $player } akanazo iziphethu ezivumelekile. Ithuba liyadlula.
trouble-extra-turn = { $player } uthola ithuba elengeziwe ngokuphosa i-6.

trouble-winner = { $player } uyawina! Wonke amatokeni asekupheleni.
trouble-team-winner = Ithimba { $team } liyawina! Bonke abasebenzisi baphothula.
trouble-final-standing = { $player }: { $finished } kwa-{ $total } amatokeni aphothuliwe.

trouble-turn-summary =
    Una-{ $own_home } eKhaya, { $own_track } emzileni, { $own_finished } ekupheleni.
    Abamelene: { $opponents }.
trouble-opponent-summary = { $name }: { $home } ikhaya, { $track } umzila, { $finished } ekupheleni

trouble-board-status =
    Amatokeni akho: { $own_tokens }.
    Amatokeni amelene: { $opp_tokens }.

trouble-reason-not-rolled = Cindezela idayisi kuqala.
trouble-reason-already-rolled = Usucindezele. Khetha itokeni ohambisa.
trouble-reason-no-legal-moves = Akukho iziphethu ezivumelekile zalokhu kuphosa.
trouble-reason-token-home-needs-six = Leli tokeni liseKhaya. Udinga i-6 ukulikhulula.
trouble-reason-token-home-needs-any = Leli tokeni liseKhaya. Noma yikuphi okuphosa kukhulula.
trouble-reason-token-home-no-qualifying-roll =
    Leli tokeni liseKhaya futhi ukuphosa kwakho akwanele ukulikhulula.
trouble-reason-token-finished = Leli tokeni selingaphothuliwe.
trouble-reason-overshoot-wastes = Leli tokeni alinakuhamba { $roll } izindawo ngaphandle kokweqa ukuphela.
trouble-reason-blocked = Lokhu kunyakaza kuvinjelwe.

trouble-option-track-size = Ubukhulu bomzila: { $track_size } izindawo
trouble-option-select-track-size = Khetha inombolo yezindawo zomzila.
trouble-option-changed-track-size = Umzila usethelwe ku-{ $track_size } izindawo.
trouble-option-desc-track-size = Inombolo yezindawo emzileni ohlanganyelwe.

trouble-option-tokens-per-player = Amatokeni ngomdlali: { $tokens }
trouble-option-enter-tokens-per-player = Faka amatokeni ngomdlali (2-6):
trouble-option-changed-tokens-per-player = Amatokeni ngomdlali asethelwe ku-{ $tokens }.
trouble-option-desc-tokens-per-player = Mangaki amatokeni umdlali ngamunye awahambisa ekupheleni.

trouble-option-extra-turn-on-six = Ithuba elengeziwe ku-6: { $enabled }
trouble-option-changed-extra-turn-on-six = Ithuba elengeziwe ku-6 { $enabled ->
    [on] livulwe.
    [off] livaliwe.
   *[other] libuyekeziwe.
}
trouble-option-desc-extra-turn-on-six =
    Kuvuliwe: i-6 inikeza ithuba elengeziwe (umthetho ovamile we-Hasbro).

trouble-option-six-to-leave-home = Idinga i-6 ukuthi uphume eKhaya: { $enabled }
trouble-option-changed-six-to-leave-home = Isithupha ukuphuma eKhaya { $enabled ->
    [on] kuvuliwe.
    [off] kuvaliwe.
   *[other] kubuyekeziwe.
}
trouble-option-desc-six-to-leave-home =
    Kuvuliwe: umdlali kufanele aphose i-6 ukukhulula itokeni eKhaya. Kuvaliwe: noma yikuphi okuphosa kuyakhulula.

trouble-option-safe-spaces = Izindawo eziphephile: { $mode }
trouble-option-select-safe-spaces = Khetha imodi yezindawo eziphephile.
trouble-option-changed-safe-spaces = Izindawo eziphephile zisethelwe ku-{ $mode }.
trouble-option-desc-safe-spaces = Nquma noma amatokeni angavikelwa ekungquzukweni.

trouble-safe-mode-none = Lutho
trouble-safe-mode-home-stretch = Umzila wokuphela kuphela
trouble-safe-mode-every-seventh = Njalo 7. indawo

trouble-option-finish-behavior = Ukuphela: { $mode }
trouble-option-select-finish-behavior = Khetha ukuziphatha kokuphela.
trouble-option-changed-finish-behavior = Ukuziphatha kokuphela kusethelwe ku-{ $mode }.
trouble-option-desc-finish-behavior = Indlela yokuphatha ukuphosa okwedlula ukuphela.

trouble-finish-mode-exact = Kudingeka ukuphosa okuqondile
trouble-finish-mode-bounce = Ukweqa kuyabuyela
trouble-finish-mode-allow = Ukweqa kuvunyelwe

trouble-option-bot-difficulty = Ubunzima bebhothi: { $level }
trouble-option-select-bot-difficulty = Khetha ubunzima bebhothi.
trouble-option-changed-bot-difficulty = Ubunzima bebhothi busethelwe ku-{ $level }.
trouble-option-desc-bot-difficulty = Amandla amabhothi akhile ngaphakathi.

trouble-bot-difficulty-naive = Okulula
trouble-bot-difficulty-greedy = Okukhanukayo

trouble-option-preset = Isethulo: { $preset }
trouble-option-select-preset = Khetha okuhlukile. Umsingathi angalungisa kamuva imithetho engodwa.
trouble-option-changed-preset = Isethulo sisetshenzisiwe: { $preset }.
trouble-option-desc-preset = Amaqembu okukhetha asongelwe ngaphambili okwehluka okuvamile.

trouble-preset-classic = Okuvamile kwe-Hasbro
trouble-preset-fast = Okusheshayo
trouble-preset-brutal = Okuhlukumezayo
trouble-preset-custom = Okwezifiso
