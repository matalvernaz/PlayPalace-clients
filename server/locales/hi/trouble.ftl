# Trouble — hi
# AI-translated with limited fluency, native review strongly recommended.
game-name-trouble = Trouble

trouble-rules =
    Trouble पार्चीसी परिवार का दौड़ खेल है।
    हर खिलाड़ी अपने घर में अपनी गोटियों के साथ शुरू करता है।
    अपनी बारी में पासे को पॉप करें और एक गोटी चलाएँ।
    डिफ़ॉल्ट रूप से घर से गोटी ट्रैक पर छोड़ने के लिए 6 चाहिए।
    डिफ़ॉल्ट रूप से 6 अतिरिक्त बारी भी देता है।
    गोटियाँ साझा ट्रैक पर घड़ी की दिशा में अंतिम क्षेत्र की ओर बढ़ती हैं।
    विरोधी की गोटी पर उतरने से वह उसके घर लौट जाती है, जब तक स्थान सुरक्षित न हो।
    जब आपकी सभी गोटियाँ अंतिम पर पहुँचती हैं, आप जीतते हैं।
    टीम मोड में आपकी टीम तब जीतती है जब सभी टीममेट समाप्त कर लें।
    1-6 गोटी चुनते हैं, R रोल करता है।
    किसी भी समय बोर्ड की पूरी स्थिति सुनने के लिए E दबाएँ।

trouble-action-roll = पासा पॉप करें
trouble-action-move-token = गोटी { $token } चलाएँ
trouble-action-check-board = बोर्ड देखें

trouble-token-label-home = गोटी { $token }: घर में
trouble-token-label-track = गोटी { $token }: ट्रैक का { $position }वाँ स्थान
trouble-token-label-finish-lane = गोटी { $token }: अंतिम लेन { $position } में से { $total }
trouble-token-label-finished = गोटी { $token }: समाप्त

trouble-rolled = { $player } ने { $roll } निकाला।
trouble-leave-home = { $player } गोटी { $token } को ट्रैक पर छोड़ते हैं।
trouble-advance-track = { $player } गोटी { $token } को स्थान { $position } पर ले जाते हैं।
trouble-enter-finish-lane = { $player } गोटी { $token } को अंतिम लेन में डालते हैं।
trouble-advance-finish-lane =
    { $player } गोटी { $token } को अंतिम लेन के { $position } / { $total } स्थान पर बढ़ाते हैं।
trouble-token-finished = { $player } की गोटी { $token } अंतिम पर पहुँची।
trouble-bump =
    { $player } की गोटी { $token } { $opponent } की गोटी { $opp_token } को घर भेजती है।
trouble-no-legal-move = { $player } के पास कोई मान्य चाल नहीं। बारी आगे बढ़ती है।
trouble-extra-turn = { $player } 6 के लिए अतिरिक्त बारी पाते हैं।

trouble-winner = { $player } जीतते हैं! सभी गोटियाँ अंतिम पर।
trouble-team-winner = टीम { $team } जीतती है! सभी टीममेट समाप्त।
trouble-final-standing = { $player }: { $total } में से { $finished } गोटियाँ समाप्त।

trouble-turn-summary =
    आपके घर में { $own_home }, ट्रैक पर { $own_track }, अंतिम पर { $own_finished } हैं।
    विरोधी: { $opponents }।
trouble-opponent-summary = { $name }: { $home } घर, { $track } ट्रैक, { $finished } अंतिम

trouble-board-status =
    आपकी गोटियाँ: { $own_tokens }।
    विरोधी गोटियाँ: { $opp_tokens }।

trouble-reason-not-rolled = पहले पासा पॉप करें।
trouble-reason-already-rolled = आपने पहले से पॉप किया है। चलाने के लिए गोटी चुनें।
trouble-reason-no-legal-moves = इस रोल के लिए कोई मान्य चाल नहीं।
trouble-reason-token-home-needs-six = यह गोटी घर में है। छोड़ने के लिए 6 चाहिए।
trouble-reason-token-home-needs-any = यह गोटी घर में है। कोई भी रोल छोड़ देगा।
trouble-reason-token-home-no-qualifying-roll =
    यह गोटी घर में है और आपका रोल छोड़ने के योग्य नहीं।
trouble-reason-token-finished = यह गोटी पहले ही समाप्त हो चुकी।
trouble-reason-overshoot-wastes = यह गोटी अंतिम को पार किए बिना { $roll } स्थान नहीं चल सकती।
trouble-reason-blocked = यह चाल अवरुद्ध है।

trouble-option-track-size = ट्रैक का आकार: { $track_size } स्थान
trouble-option-select-track-size = ट्रैक के स्थानों की संख्या चुनें।
trouble-option-changed-track-size = ट्रैक { $track_size } स्थानों पर सेट।
trouble-option-desc-track-size = साझा ट्रैक पर स्थानों की संख्या।

trouble-option-tokens-per-player = प्रति खिलाड़ी गोटियाँ: { $tokens }
trouble-option-enter-tokens-per-player = प्रति खिलाड़ी गोटियाँ दर्ज करें (2-6):
trouble-option-changed-tokens-per-player = प्रति खिलाड़ी गोटियाँ: { $tokens }।
trouble-option-desc-tokens-per-player = हर खिलाड़ी कितनी गोटियाँ अंतिम पर ले जाता है।

trouble-option-extra-turn-on-six = 6 पर अतिरिक्त बारी: { $enabled }
trouble-option-changed-extra-turn-on-six = 6 पर अतिरिक्त बारी { $enabled ->
    [on] सक्षम।
    [off] अक्षम।
   *[other] अपडेट।
}
trouble-option-desc-extra-turn-on-six =
    चालू: 6 अतिरिक्त बारी देता है (क्लासिक Hasbro नियम)।

trouble-option-six-to-leave-home = घर छोड़ने के लिए 6 चाहिए: { $enabled }
trouble-option-changed-six-to-leave-home = घर छोड़ने के लिए छह { $enabled ->
    [on] सक्षम।
    [off] अक्षम।
   *[other] अपडेट।
}
trouble-option-desc-six-to-leave-home =
    चालू: गोटी छोड़ने के लिए 6 चाहिए। बंद: कोई भी रोल छोड़ देगा।

trouble-option-safe-spaces = सुरक्षित स्थान: { $mode }
trouble-option-select-safe-spaces = सुरक्षित स्थान मोड चुनें।
trouble-option-changed-safe-spaces = सुरक्षित स्थान { $mode } पर सेट।
trouble-option-desc-safe-spaces = तय करें कि गोटियाँ टकराव से सुरक्षित हो सकती हैं या नहीं।

trouble-safe-mode-none = कोई नहीं
trouble-safe-mode-home-stretch = केवल अंतिम स्ट्रेच
trouble-safe-mode-every-seventh = हर 7 वाँ स्थान

trouble-option-finish-behavior = अंतिम: { $mode }
trouble-option-select-finish-behavior = अंतिम व्यवहार चुनें।
trouble-option-changed-finish-behavior = अंतिम व्यवहार { $mode } पर सेट।
trouble-option-desc-finish-behavior = अंतिम पार करने वाले रोल को कैसे संभाला जाए।

trouble-finish-mode-exact = सटीक रोल चाहिए
trouble-finish-mode-bounce = ज़्यादा होने पर वापस उछलता
trouble-finish-mode-allow = अधिकता अनुमत

trouble-option-bot-difficulty = बॉट कठिनाई: { $level }
trouble-option-select-bot-difficulty = बॉट कठिनाई चुनें।
trouble-option-changed-bot-difficulty = बॉट कठिनाई { $level } पर सेट।
trouble-option-desc-bot-difficulty = अंतर्निहित बॉट की ताकत।

trouble-bot-difficulty-naive = सरल
trouble-bot-difficulty-greedy = लालची

trouble-option-preset = प्रीसेट: { $preset }
trouble-option-select-preset = वेरिएंट चुनें। होस्ट बाद में अलग-अलग नियम बदल सकता है।
trouble-option-changed-preset = प्रीसेट लागू: { $preset }।
trouble-option-desc-preset = सामान्य वेरिएंट के लिए पूर्व-पैक किए विकल्प।

trouble-preset-classic = क्लासिक Hasbro
trouble-preset-fast = तेज़
trouble-preset-brutal = क्रूर
trouble-preset-custom = कस्टम
