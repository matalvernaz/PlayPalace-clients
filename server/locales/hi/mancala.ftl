# Mancala game messages — hi
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = मंकाला

# Actions
mancala-pit-label = गड्ढा { $pit }: { $stones } पत्थर

# Game events
mancala-sow = { $player } गड्ढे { $pit } से { $stones } पत्थर बोता है
mancala-capture = { $player } ने { $captured } पत्थर पकड़े!
mancala-extra-turn = आखिरी पत्थर भंडार में! { $player } को एक और बारी मिलती है।
mancala-winner = { $player } { $score } पत्थरों से जीता!
mancala-draw = बराबरी! दोनों खिलाड़ियों के पास { $score } पत्थर हैं।

# Board status
mancala-board-status =
    आपके गड्ढे: { $own_pits }। आपका भंडार: { $own_store }। प्रतिद्वंद्वी के गड्ढे: { $opp_pits }। प्रतिद्वंद्वी का भंडार: { $opp_store }।

# Options
mancala-set-stones = प्रति गड्ढा पत्थर: { $stones }
mancala-desc-stones = शुरुआत में हर गड्ढे में पत्थरों की संख्या
mancala-enter-stones = प्रति गड्ढा शुरुआती पत्थरों की संख्या दर्ज करें:
mancala-option-changed-stones = शुरुआती पत्थर { $stones } में बदले गए

# Disabled reasons
mancala-pit-empty = वह गड्ढा खाली है।

# Rules
mancala-rules =
    मंकाला दो खिलाड़ियों का गड्ढे और पत्थर का खेल है।
    हर खिलाड़ी के पास 6 गड्ढे और एक भंडार होता है।
    अपनी बारी में, बोने के लिए अपना एक गड्ढा चुनें।
    पत्थर बोर्ड के चारों ओर हर गड्ढे में एक-एक करके रखे जाते हैं, आपके भंडार सहित लेकिन प्रतिद्वंद्वी के भंडार को छोड़कर।
    अगर आपका आखिरी पत्थर आपके भंडार में गिरता है, तो आपको एक और बारी मिलती है।
    अगर आपका आखिरी पत्थर आपकी तरफ के खाली गड्ढे में गिरता है, तो आप वह पत्थर और सामने के गड्ढे के सभी पत्थर पकड़ लेते हैं।
    खेल तब समाप्त होता है जब एक तरफ पूरी तरह खाली हो जाती है।
    सबसे ज्यादा पत्थरों वाला खिलाड़ी जीतता है।
    गड्ढा चुनने के लिए 1 से 6 कुंजियों का उपयोग करें। बोर्ड जांचने के लिए E दबाएं।

# End screen
mancala-final-score = { $player }: { $score } पत्थर
