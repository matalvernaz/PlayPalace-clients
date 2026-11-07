"""The format marker stored with every saved game, so old saves are never half-loaded.

Live tables and user-saved tables keep their game state as JSON. When the game
engine changes shape, an old blob can still deserialize: missing fields get
defaults and unknown ones are dropped, and the game comes back silently
corrupted. Every save therefore records which engine format wrote it, and a
restore accepts only the current one.

Bump GAME_ENGINE_FORMAT only when saved games stop being compatible.
"""

# The PlayAural game engine, first imported from PlayAural afde669.
GAME_ENGINE_FORMAT = "playaural-1"
