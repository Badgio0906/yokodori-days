"""One-time scaffolder. Edit the resulting TSCNs in Godot afterward."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
def write(name, data):
    path = root / name; path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(data, encoding='utf-8')

poses = ['working','phone','talk','caught','steal','happy','sad']
for name, who, script in [('Sawano','sawano','sawano'),('TargetCoworker','target','target_coworker'),('Coworker','coworker','character_visual')]:
    s = '[gd_scene load_steps=10 format=3]\n\n'
    s += f'[ext_resource type="Script" path="res://scripts/{script}.gd" id="1"]\n'
    for i,p in enumerate(poses,2): s += f'[ext_resource type="Texture2D" path="res://assets/characters/{who}_{p}.png" id="{i}"]\n'
    s += '\n[sub_resource type="SpriteFrames" id="Frames"]\nanimations = [\n'
    s += ',\n'.join('{"frames": [{"duration": 1.0, "texture": ExtResource("%s")}], "loop": true, "name": &"%s", "speed": 5.0}'%(i,p) for i,p in enumerate(poses,2))
    s += f'\n]\n\n[node name="{name}" type="Node2D"]\nscript = ExtResource("1")\n'
    s += '\n[node name="Sprite" type="AnimatedSprite2D" parent="."]\ntexture_filter = 1\nscale = Vector2(2, 2)\nsprite_frames = SubResource("Frames")\nanimation = &"working"\n'
    write(f'scenes/characters/{name}.tscn',s)

for name,script,folder in [('TitleScreen','title_screen',''),('GameOver','game_over',''),('HUD','hud','ui/'),('ChanceBubble','chance_bubble','ui/'),('ScorePopup','score_popup','ui/')]:
    write(f'scenes/{folder}{name}.tscn',f'''[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/{script}.gd" id="1"]

[node name="{name}" type="Control"]
layout_mode = 0
offset_right = 960.0
offset_bottom = 540.0
mouse_filter = 2
script = ExtResource("1")
''')

resources = [('Script','scripts/game_manager.gd','script'),('Texture2D','assets/office/background.png','bg'),('Texture2D','assets/office/desks.png','desks'),('Texture2D','assets/items/phone.png','phone')]
for name, folder in [('Sawano','characters'),('TargetCoworker','characters'),('Coworker','characters'),('HUD','ui'),('ChanceBubble','ui'),('ScorePopup','ui')]:
    resources.append(('PackedScene',f'scenes/{folder}/{name}.tscn',name))
for name in ['phone_ring','steal_success','banana_get','caught','game_over']:
    resources.append(('AudioStream',f'assets/audio/{name}.wav',name))
s=f'[gd_scene load_steps={len(resources)+1} format=3]\n\n'
for typ,path,uid in resources: s+=f'[ext_resource type="{typ}" path="res://{path}" id="{uid}"]\n'
s+='\n[node name="Game" type="Node2D"]\nscript = ExtResource("script")\nprocess_priority = 10\n'
s+='\n[node name="Background" type="Sprite2D" parent="."]\ntexture = ExtResource("bg")\ncentered = false\nscale = Vector2(2, 2)\n'
for name,x in [('Sawano',244),('TargetCoworker',476),('Coworker',708)]:
    s+=f'\n[node name="{name}" parent="." instance=ExtResource("{name}")]\nposition = Vector2({x}, 288)\n'
s+='\n[node name="Desks" type="Sprite2D" parent="."]\ntexture = ExtResource("desks")\ncentered = false\nscale = Vector2(2, 2)\n'
s+='\n[node name="Phone" type="Sprite2D" parent="."]\ntexture = ExtResource("phone")\nposition = Vector2(569, 327)\nscale = Vector2(2, 2)\n'
# Keep the world behind the manager's item/particle draw calls.
for node, z in [('Background',-10),('Sawano',-8),('TargetCoworker',-8),('Coworker',-8),('Desks',-6),('Phone',-5)]:
    lines = s.splitlines()
    index = next(i for i,line in enumerate(lines) if line.startswith(f'[node name="{node}" '))
    lines.insert(index+1, f'z_index = {z}')
    s = '\n'.join(lines) + '\n'
for name in ['HUD','ChanceBubble','ScorePopup']: s+=f'\n[node name="{name}" parent="." instance=ExtResource("{name}")]\n'
s+='\n[node name="Audio" type="Node" parent="."]\n'
for name in ['phone_ring','steal_success','banana_get','caught','game_over']:
    s+=f'\n[node name="{name}" type="AudioStreamPlayer" parent="Audio"]\nstream = ExtResource("{name}")\nvolume_db = -8.0\n'
write('scenes/Game.tscn',s)
write('scenes/Main.tscn','''[gd_scene load_steps=5 format=3]

[ext_resource type="Script" path="res://scripts/main.gd" id="1"]
[ext_resource type="PackedScene" path="res://scenes/Game.tscn" id="2"]
[ext_resource type="PackedScene" path="res://scenes/TitleScreen.tscn" id="3"]
[ext_resource type="PackedScene" path="res://scenes/GameOver.tscn" id="4"]

[node name="Main" type="Node"]
script = ExtResource("1")

[node name="Game" parent="." instance=ExtResource("2")]

[node name="TitleScreen" parent="." instance=ExtResource("3")]

[node name="GameOver" parent="." instance=ExtResource("4")]
''')
print('Scene resources generated.')
