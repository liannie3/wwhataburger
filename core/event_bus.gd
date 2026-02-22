extends Node

# UI Signals
signal show_prompt(player_id: int, text: String)
signal hide_prompt(player_id: int)
signal show_dialogue(player_id: int, npc_name: String, text: String)
signal hide_dialogue(player_id: int)
