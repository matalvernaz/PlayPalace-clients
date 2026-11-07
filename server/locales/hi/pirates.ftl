# pirates.ftl for locale hi. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-pirates = खोए हुए समुद्रों के समुद्री डाकू
# Game start and setup
pirates-welcome = खोए हुए समुद्रों के समुद्री डाकू में आपका स्वागत है! समुद्रों में नौकायन करें, रत्न इकट्ठा करें, और अन्य समुद्री डाकुओं से लड़ें!
pirates-oceans = आपकी यात्रा आपको इनके माध्यम से ले जाएगी: { $oceans }
pirates-gems-placed = { $total } रत्न समुद्रों में बिखरे हुए हैं। उन सभी को खोजें!
pirates-golden-moon = स्वर्णिम चंद्रमा उगता है! इस राउंड में सभी XP लाभ तीन गुना हैं!
# Turn announcements
pirates-turn = { $player } की बारी। स्थिति { $position }
# Movement actions
pirates-move-left = बाईं ओर नौकायन करें
pirates-move-right = दाईं ओर नौकायन करें
pirates-move-2-left = 2 टाइल बाईं ओर नौकायन करें
pirates-move-2-right = 2 टाइल दाईं ओर नौकायन करें
pirates-move-3-left = 3 टाइल बाईं ओर नौकायन करें
pirates-move-3-right = 3 टाइल दाईं ओर नौकायन करें
# Movement messages
pirates-move-you = आप { $direction } स्थिति { $position } पर नौकायन करते हैं।
pirates-move = { $player } { $direction } स्थिति { $position } पर नौकायन करता है।
pirates-map-edge = आप आगे नौकायन नहीं कर सकते। आप स्थिति { $position } पर हैं।
pirates-your-position = आपकी स्थिति: { $ocean } में { $position }
pirates-check-position = स्थिति जांचें
pirates-check-moon = चंद्रमा की चमक जांचें
# Position and status
pirates-check-status = स्थिति जांचें
pirates-all-gems-collected = सभी रत्न एकत्र कर लिए गए हैं!
# Winner
pirates-winner = { $player } { $score } अंकों के साथ जीतता है!
# Gem collection
pirates-gem-found-you = आपको एक { $gem } मिला! { $value } अंक के लायक।
pirates-gem-found = { $player } को एक { $gem } मिला! { $value } अंक के लायक।
pirates-level-up-you = आप स्तर { $level } पर पहुंच गए!
pirates-level-up = { $player } स्तर { $level } पर पहुंच गया!
pirates-level-up-multiple-you = आपने { $levels } स्तर प्राप्त किए! अब स्तर { $level }!
pirates-level-up-multiple = { $player } ने { $levels } स्तर प्राप्त किए! अब स्तर { $level }!
pirates-skills-unlocked-you = आपने नए कौशल अनलॉक किए: { $skills }।
pirates-skills-unlocked = { $player } ने नए कौशल अनलॉक किए: { $skills }।
# Combat - Attack initiation
pirates-cannonball = तोप का गोला दागें
pirates-no-targets = { $range } टाइल के भीतर कोई लक्ष्य नहीं।
pirates-attack-you-fire = आप { $target } पर तोप का गोला दागते हैं!
pirates-attack-incoming = { $attacker } आप पर तोप का गोला दागता है!
pirates-attack-fired = { $attacker } { $defender } पर तोप का गोला दागता है!
# Combat - Hit results
pirates-attack-hit-you = सीधा प्रहार! आपने { $target } को मारा!
pirates-attack-hit-them = आप { $attacker } द्वारा मारे गए हैं!
pirates-attack-hit = { $attacker } { $defender } को मारता है!
# Combat - Miss results
pirates-attack-miss-you = आपका तोप का गोला { $target } से चूक गया।
pirates-attack-miss-them = तोप का गोला आपसे चूक गया!
pirates-attack-miss = { $attacker } का तोप का गोला { $defender } से चूक जाता है।
pirates-push = { $attacker } { $defender } को { $old_pos } से { $new_pos } तक { $direction } धकेलता है।
pirates-steal-success-you = आपने { $target } से एक { $gem } चुरा लिया!
pirates-steal-success-them = { $attacker } ने आपका { $gem } चुरा लिया!
pirates-steal-success = { $attacker } { $defender } से एक { $gem } चुराता है!
pirates-steal-failed = चोरी का प्रयास विफल रहा!
# Skills menu
pirates-use-skill = कौशल का उपयोग करें
pirates-select-skill = उपयोग करने के लिए एक कौशल चुनें
# Skill activation
pirates-skill-activated = { $player } { $skill } को सक्रिय करता है!
pirates-buff-expired = { $player } का { $skill } बफ समाप्त हो गया है।
# Portal skill
pirates-portal-no-ships = पोर्टल करने के लिए दृष्टि में कोई अन्य जहाज नहीं।
pirates-portal-fizzle = { $player } का पोर्टल बिना किसी गंतव्य के फीका पड़ जाता है।
pirates-portal-success = { $player } स्थिति { $position } पर { $ocean } में पोर्टल करता है!
# Gem Seeker skill
pirates-gem-seeker-reveal = समुद्र स्थिति { $position } पर एक { $gem } की फुसफुसाहट करते हैं। ({ $uses } उपयोग शेष)
# Sword Fighter skill
pirates-sword-fighter-activated = तलवारबाज सक्रिय! { $turns } टर्न के लिए +4 हमला बोनस।
# Push skill (defense buff)
pirates-push-activated = पुश सक्रिय! { $turns } टर्न के लिए +3 रक्षा बोनस।
# Skilled Captain skill
pirates-skilled-captain-activated = कुशल कप्तान सक्रिय! { $turns } टर्न के लिए +2 हमला और +2 रक्षा।
# Battleship skill
pirates-battleship-activated = युद्धपोत सक्रिय! आप इस टर्न में दो शॉट दाग सकते हैं!
pirates-battleship-shot = शॉट { $shot } दागते हुए...
pirates-battleship-no-targets = शॉट { $shot } के लिए कोई लक्ष्य नहीं।
# Double Devastation skill
pirates-double-devastation-activated = डबल विनाश सक्रिय! { $turns } टर्न के लिए हमला सीमा 10 टाइल तक बढ़ गई।
# XP Multiplier options
pirates-set-combat-xp-multiplier = युद्ध xp गुणक: { $combat_multiplier }
pirates-enter-combat-xp-multiplier = युद्ध के लिए अनुभव
pirates-set-find-gem-xp-multiplier = रत्न खोजने xp गुणक: { $find_gem_multiplier }
pirates-enter-find-gem-xp-multiplier = रत्न खोजने के लिए अनुभव
# Gem stealing options
pirates-set-gem-stealing = रत्न चोरी: { $mode }
pirates-select-gem-stealing = रत्न चोरी मोड चुनें
pirates-option-changed-stealing = रत्न चोरी { $mode } पर सेट किया गया।
# Gem stealing mode choices
pirates-stealing-with-bonus = रोल बोनस के साथ
pirates-stealing-no-bonus = कोई रोल बोनस नहीं
pirates-stealing-disabled = अक्षम
