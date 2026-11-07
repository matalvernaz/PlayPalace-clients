# ninetynine.ftl for locale hi. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game names
game-name-ninetynine = नाइंटी नाइन
# Round
ninetynine-round = राउंड { $round }।
# Playing cards
ninetynine-you-play = आप { $card } खेलते हैं। गिनती अब { $count } है।
ninetynine-player-plays = { $player } { $card } खेलते हैं। गिनती अब { $count } है।
# Direction reverse
ninetynine-direction-reverses = खेल की दिशा उलट जाती है!
# Skip
ninetynine-player-skipped = { $player } को छोड़ा गया।
# Token loss
ninetynine-you-lose-tokens =
    आप { $amount } { $amount ->
        [one] टोकन
       *[other] टोकन
    } खोते हैं।
ninetynine-player-loses-tokens =
    { $player } { $amount } { $amount ->
        [one] टोकन
       *[other] टोकन
    } खोते हैं।
# Elimination
ninetynine-player-eliminated = { $player } बाहर हो गए हैं!
# Game end
ninetynine-player-wins = { $player } खेल जीतते हैं!
# Drawing cards
ninetynine-you-draw = आप { $card } ड्रॉ करते हैं।
ninetynine-player-draws = { $player } एक पत्ता ड्रॉ करते हैं।
# No valid cards
ninetynine-no-valid-cards = { $player } के पास कोई ऐसे पत्ते नहीं हैं जो 99 से अधिक नहीं जाएंगे!
# Status - for C key
ninetynine-current-count = गिनती { $count } है।
# Ace choice
ninetynine-ace-choice = इक्का को +1 या +11 के रूप में खेलें?
ninetynine-ace-add-eleven = 11 जोड़ें
ninetynine-ace-add-one = 1 जोड़ें
# Ten choice
ninetynine-ten-choice = 10 को +10 या -10 के रूप में खेलें?
ninetynine-ten-add = 10 जोड़ें
ninetynine-ten-subtract = 10 घटाएं
# Manual draw
ninetynine-draw-card = पत्ता ड्रॉ करें
ninetynine-draw-prompt = पत्ता ड्रॉ करने के लिए स्पेस या D दबाएं।
# Options
ninetynine-set-tokens = शुरुआती टोकन: { $tokens }
ninetynine-enter-tokens = शुरुआती टोकन की संख्या दर्ज करें:
ninetynine-option-changed-tokens = शुरुआती टोकन { $tokens } पर सेट किए गए।
ninetynine-set-rules = नियम प्रकार: { $rules }
ninetynine-select-rules = नियम प्रकार चुनें
ninetynine-option-changed-rules = नियम प्रकार { $rules } पर सेट किया गया।
ninetynine-set-hand-size = हाथ का आकार: { $size }
ninetynine-enter-hand-size = हाथ का आकार दर्ज करें:
ninetynine-option-changed-hand-size = हाथ का आकार { $size } पर सेट किया गया।
ninetynine-set-autodraw = स्वचालित ड्रॉइंग: { $enabled }
ninetynine-option-changed-autodraw = स्वचालित ड्रॉइंग { $enabled } पर सेट की गई।
# Disabled action reasons
ninetynine-choose-first = आपको पहले एक विकल्प चुनने की आवश्यकता है।
