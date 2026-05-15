# Liar's Dice — hi
# AI-translated with limited fluency, native review strongly recommended.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = हर खिलाड़ी अपने कप के नीचे गुप्त रूप से पासे फेंकता है। बारी-बारी से पूरी मेज़ के एक चेहरे की कुल संख्या पर बढ़ती बोलियाँ लगाते हैं — या अंतिम बोली पर विश्वास न हो तो "झूठा!" चिल्लाते हैं। गलत होने पर एक पासा खोते हैं। अंतिम बचे पासे वाला जीतता है।

liarsdice-rules =
    Liar's Dice 2 से 6 खिलाड़ियों के लिए धोखे का पासा खेल है।
    हर खिलाड़ी कप में 5 पासों से शुरू करता है। हर दौर की शुरुआत में सभी गुप्त रूप से फेंकते हैं।
    बारी-बारी से सभी पासों पर एक चेहरे की कुल संख्या पर बोली लगाते हैं — जैसे "तीन 4" का मतलब सभी कप खोलने पर कम से कम तीन 4 हैं।
    हर नई बोली पिछली से अधिक होनी चाहिए: वही चेहरा अधिक संख्या के साथ, या अधिक चेहरा बराबर या अधिक संख्या के साथ।
    1 जोकर हैं — वे हर बोली में गिने जाते हैं सिवाय 1 पर बोली के।
    1 पर बोली में बदलने से संख्या आधी हो जाती है (ऊपर पूर्णांकित)। 1 से सामान्य चेहरे पर वापस जाने के लिए पिछली संख्या से दोगुना से अधिक चाहिए।
    बोली के बजाय "झूठा!" चिल्ला कर पिछली बोली को चुनौती दे सकते हैं। सभी कप खोले जाते हैं: यदि बोली सही थी, चुनौती देने वाला एक पासा खोता है; यदि नहीं, तो बोली लगाने वाला एक पासा खोता है।
    Spot On सक्षम होने पर आप "Spot On" चिल्ला सकते हैं, यह दांव लगाते हुए कि बोली बिल्कुल सही है। सही — हर दूसरा खिलाड़ी एक पासा खोता है; गलत — आप दो पासे खोते हैं।
    शून्य पासों पर समाप्त। अंतिम पासे वाला जीतता है।
    मेज़ देखने के लिए S दबाएँ।

ld-set-starting-dice = प्रति खिलाड़ी आरंभिक पासे: { $dice }
ld-desc-starting-dice = हर खिलाड़ी कितने पासों से शुरू करता है। डिफ़ॉल्ट 5। अधिक पासे = लंबे खेल और अधिक धोखे की गुंजाइश।
ld-prompt-starting-dice = आरंभिक पासे दर्ज करें (3 से 8)
ld-option-changed-starting-dice = आरंभिक पासे { $dice } पर सेट किए गए।

ld-toggle-wild-ones = 1 जोकर हैं: { $enabled }
ld-desc-wild-ones = चालू: 1 हर गैर-1 बोली में गिने जाते हैं। 1 पर बोली उस बोली के लिए जोकर निष्क्रिय करती है। बंद — खेल बिना जोकर शुद्ध प्रायिकता बन जाता है।
ld-option-changed-wild-ones = जोकर 1 { $enabled }.

ld-toggle-spot-on = Spot On कॉल सक्षम: { $enabled }
ld-desc-spot-on = चालू: "झूठा" के अलावा आप "Spot On" चिल्ला सकते हैं, यह दांव लगाते हुए कि बोली बिल्कुल सही है। सही — अन्य लोग एक-एक पासा खोते हैं। गलत — आप दो खोते हैं। उच्च जोखिम, उच्च इनाम।
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = दौर { $round } शुरू होता है। मेज़ पर कुल पासे: { $total }। सभी फेंकते हैं।
ld-your-roll = इस दौर में आपके पासे: { $dice }।
ld-your-counts = आपकी गिनती: { $counts }।
ld-turn-start = { $player } की बारी। { $bid_state }
ld-no-bid-yet = अभी कोई बोली नहीं — दौर खोलें।
ld-current-bid = वर्तमान बोली: { $quantity } { $face }।

ld-action-bid = बोली लगाएँ
ld-action-call-liar = झूठा कहें
ld-action-call-spot-on = Spot On कहें
ld-bid-prompt = अपनी बोली चुनें।
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] आप { $quantity } { $face } की बोली लगाते हैं।
    *[player] { $player } { $quantity } { $face } की बोली लगाते हैं।
}

ld-call-liar = { $who ->
    [you] आप { $target } की { $quantity } { $face } बोली पर झूठा कहते हैं।
    *[player] { $player } { $target } की { $quantity } { $face } बोली पर झूठा कहते हैं।
}
ld-call-spot-on = { $who ->
    [you] आप { $target } की { $quantity } { $face } बोली पर Spot On कहते हैं।
    *[player] { $player } { $target } की { $quantity } { $face } बोली पर Spot On कहते हैं।
}
ld-reveal-header = कप ऊपर! मेज़ पर { $face } गिन रहे हैं।
ld-reveal-line = { $player } ने फेंका: { $dice }।
ld-actual-count = { $face } की वास्तविक संख्या (जोकर 1 सहित): { $count }। बोली { $quantity } थी।
ld-actual-count-no-wild = { $face } की वास्तविक संख्या (बिना जोकर): { $count }। बोली { $quantity } थी।

ld-liar-bidder-loses = { $bidder } ने ज़्यादा बोली लगाई — एक पासा खोते हैं।
ld-liar-caller-loses = बोली ईमानदार थी — { $caller } एक पासा खोते हैं।
ld-spot-on-correct = Spot on! { $caller } ने ठीक अनुमान लगाया — अन्य सभी एक पासा खोते हैं।
ld-spot-on-wrong = Spot on नहीं। { $caller } दो पासे खोते हैं।

ld-lost-die = { $who ->
    [you] आप एक पासा खो गए। अब आपके पास { $remaining } { $remaining ->
        [one] पासा
        *[other] पासे
    } हैं।
    *[player] { $player } एक पासा खो गए। अब { $remaining } हैं।
}
ld-lost-dice-multi = { $who ->
    [you] आप { $count } पासे खो गए। अब आपके पास { $remaining } { $remaining ->
        [one] पासा
        *[other] पासे
    } हैं।
    *[player] { $player } { $count } पासे खो गए। अब { $remaining } हैं।
}
ld-eliminated = { $player } पासों से बाहर हो गए और बाहर हो गए! { $remaining } { $remaining ->
    [one] खिलाड़ी
    *[other] खिलाड़ी
} बचे।
ld-winner = { $player } अंतिम पासों के साथ — जीतते हैं!

ld-status-round = दौर { $round }।
ld-status-your-dice = आपके पासे: { $dice }।
ld-status-your-counts = आपकी गिनती: { $counts }।
ld-status-no-dice = आपके पास पासे नहीं — आप बाहर हैं।
ld-status-current-bid = वर्तमान बोली: { $quantity } { $face }।
ld-status-no-bid = इस दौर में कोई बोली नहीं।
ld-status-table-total = मेज़ पर कुल पासे: { $total }।
ld-status-detailed-header = विस्तृत स्थिति — { $count } खिलाड़ी बचे।
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] पासा
    *[other] पासे
}।
ld-status-detailed-out = { $player }: बाहर।
ld-status-detailed-self-suffix = {" "}(आप)

ld-face-1 = इकाई
ld-face-2 = दो
ld-face-3 = तीन
ld-face-4 = चार
ld-face-5 = पाँच
ld-face-6 = छह

ld-action-not-your-turn = अभी आपकी बारी नहीं है।
ld-action-not-playing = खेल चल नहीं रहा।
ld-action-no-bid-to-call = अभी चुनौती देने के लिए कोई बोली नहीं।
ld-action-eliminated = आप बाहर हो चुके हैं।
