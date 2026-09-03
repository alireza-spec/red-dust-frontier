extends Node3D

var player: CharacterBody3D
var horse: Node3D
var hint: Label
var objective: Label
var mats := {}

func _ready() -> void:
 _make_materials()
 _build_world()
 _build_player()
 _build_hud()

func _make_materials() -> void:
 mats.dirt = _mat(Color("#8a4e32"), 0.95)
 mats.sand = _mat(Color("#c88b54"), 1.0)
 mats.rock = _mat(Color("#5b302b"), 0.95)
 mats.wood = _mat(Color("#40261e"), 0.9)
 mats.plank = _mat(Color("#a36a3d"), 0.9)
 mats.gold = _mat(Color("#d9a441"), 0.5, Color("#e6a83e"))
 mats.dark = _mat(Color("#10141e"), 0.75)
 mats.red = _mat(Color("#9e3e31"), 0.9)
 mats.white = _mat(Color("#d8d1bd"), 0.8)

func _mat(color: Color, roughness: float, emission := Color.BLACK) -> StandardMaterial3D:
 var m := StandardMaterial3D.new(); m.albedo_color = color; m.roughness = roughness
 if emission != Color.BLACK: m.emission_enabled = true; m.emission = emission; m.emission_energy_multiplier = 1.5
 return m

func _mesh(parent: Node3D, shape: PrimitiveMesh, material: Material, pos: Vector3, scale := Vector3.ONE) -> MeshInstance3D:
 var n := MeshInstance3D.new(); n.mesh = shape; n.material_override = material; n.position = pos; n.scale = scale; parent.add_child(n); return n

func _box(parent: Node3D, pos: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
 var b := BoxMesh.new(); b.size = size; return _mesh(parent, b, material, pos)

func _cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
 var c := CylinderMesh.new(); c.top_radius = radius; c.bottom_radius = radius * 1.05; c.height = height; c.radial_segments = 12; return _mesh(parent, c, material, pos)

func _build_world() -> void:
 var env := WorldEnvironment.new(); var e := Environment.new(); e.background_mode = Environment.BG_SKY
 var sky := Sky.new(); var sky_mat := ProceduralSkyMaterial.new(); sky_mat.sky_top_color = Color("#1d2848"); sky_mat.sky_horizon_color = Color("#d88355"); sky_mat.ground_bottom_color = Color("#2e2028"); sky_mat.ground_horizon_color = Color("#b96a49"); sky_mat.sun_angle_max = 18.0; sky.sky_material = sky_mat; e.sky = sky
 e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY; e.ambient_light_energy = 0.65; e.tonemap_mode = Environment.TONE_MAPPER_FILMIC; e.fog_enabled = true; e.fog_light_color = Color("#b9785e"); e.fog_density = 0.008; e.fog_sky_affect = 0.55; env.environment = e; add_child(env)
 var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-28, -32, 0); sun.light_color = Color("#ffd0a1"); sun.light_energy = 1.7; sun.shadow_enabled = true; add_child(sun)
 var fill := OmniLight3D.new(); fill.position = Vector3(0, 6, 3); fill.light_color = Color("#e77d4e"); fill.omni_range = 18.0; fill.light_energy = 1.8; add_child(fill)
 _mesh(self, PlaneMesh.new(), mats.sand, Vector3(0, -0.12, 0), Vector3(12, 1, 12))
 # mesas and rocks frame the playable basin
 for data in [[Vector3(-38,3,-28),Vector3(10,6,8)],[Vector3(42,5,-40),Vector3(14,10,10)],[Vector3(-48,4,30),Vector3(13,8,12)],[Vector3(48,2,34),Vector3(9,4,8)]]:
  _mesh(self, CylinderMesh.new(), mats.rock, data[0], data[1])
 _build_town()
 _build_horse(Vector3(9, 0.9, 4))
 _build_marker(Vector3(-14, 0.2, -11))

func _build_town() -> void:
 var town := Node3D.new(); town.name = "DusthavenSettlement"; add_child(town)
 for x in [-16.0, -7.0, 2.0]:
  _box(town, Vector3(x,2.0,-13), Vector3(6,4,5), mats.plank)
  _box(town, Vector3(x,4.5,-13), Vector3(6.6,0.35,5.6), mats.rock)
  _box(town, Vector3(x,2.0,-10.35), Vector3(1.2,2.2,0.12), mats.dark)
  _box(town, Vector3(x-1.8,2.0,-10.35), Vector3(0.7,1.4,0.12), mats.gold)
 _box(town, Vector3(-7,1.0,-6), Vector3(1.0,2.0,1.0), mats.wood)
 _box(town, Vector3(-7,2.25,-6), Vector3(1.6,0.25,1.6), mats.red)
 for x in range(-22, 11, 4): _box(town, Vector3(x,0.55,-8.0), Vector3(0.16,1.1,0.16), mats.wood)

func _build_horse(pos: Vector3) -> void:
 horse = Node3D.new(); horse.name = "FrontierHorse"; horse.position = pos; add_child(horse)
 _mesh(horse, CapsuleMesh.new(), mats.rock, Vector3(0,1.25,0), Vector3(0.65,1.35,1.25))
 _mesh(horse, CapsuleMesh.new(), mats.rock, Vector3(0,2.5,-0.55), Vector3(0.4,0.75,0.55))
 for x in [-0.38,0.38]: for z in [-0.38,0.38]: _mesh(horse, CylinderMesh.new(), mats.rock, Vector3(x,0.45,z), Vector3(0.18,1.2,0.18))
 var sign := Label3D.new(); sign.text = "FRONTIER HORSE"; sign.modulate = Color("#ffd39a"); sign.outline_size = 8; sign.position = Vector3(0,3.5,0); horse.add_child(sign)

func _build_marker(pos: Vector3) -> void:
 var marker := OmniLight3D.new(); marker.position = pos + Vector3(0,3,0); marker.light_color = Color("#efbd4d"); marker.light_energy = 3.0; marker.omni_range = 8.0; add_child(marker)
 _mesh(self, CylinderMesh.new(), mats.gold, pos, Vector3(1.3,0.08,1.3))
 var label := Label3D.new(); label.text = "THE LOST LETTER"; label.modulate = Color("#ffe5a8"); label.outline_size = 10; label.position = pos + Vector3(0,2.3,0); add_child(label)

func _build_player() -> void:
 player = CharacterBody3D.new(); player.name = "Ranger"; player.position = Vector3(8,1.2,12); add_child(player)
 var shape := CollisionShape3D.new(); var capsule := CapsuleShape3D.new(); capsule.radius = 0.45; capsule.height = 1.8; shape.shape = capsule; shape.position.y = 0.9; player.add_child(shape)
 _mesh(player, CapsuleMesh.new(), mats.dark, Vector3(0,1.0,0), Vector3(0.48,0.9,0.48))
 var cam_pivot := Node3D.new(); cam_pivot.position = Vector3(0,2.0,0); player.add_child(cam_pivot)
 var cam := Camera3D.new(); cam.position = Vector3(0,3.0,8.0); cam.rotation_degrees.x = -12; cam.current = true; cam_pivot.add_child(cam)
 var script := load("res://scripts/player.gd"); player.set_script(script); player.setup(cam, cam_pivot, horse); player.interaction_changed.connect(_on_hint)

func _build_hud() -> void:
 var layer := CanvasLayer.new(); add_child(layer)
 var title := Label.new(); title.text = "RED DUST  /  FRONTIER"; title.position = Vector2(34,28); title.add_theme_font_size_override("font_size",22); title.add_theme_color_override("font_color",Color("#f4d3a0")); layer.add_child(title)
 objective = Label.new(); objective.text = "◆  THE LOST LETTER\n     Find the marker outside Dusthaven"; objective.position = Vector2(34,68); objective.add_theme_font_size_override("font_size",16); objective.add_theme_color_override("font_color",Color("#ffe2ae")); layer.add_child(objective)
 hint = Label.new(); hint.text = "WASD  Move     Shift/Space  Sprint"; hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); hint.position = Vector2(-220,-58); hint.size = Vector2(440,40); hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; hint.add_theme_font_size_override("font_size",17); hint.add_theme_color_override("font_color",Color("#fff0d5")); layer.add_child(hint)
 var vignette := ColorRect.new(); vignette.color = Color(0.02,0.015,0.02,0.14); vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE; vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); layer.add_child(vignette); layer.move_child(vignette,0)

func _on_hint(message: String) -> void:
 if hint: hint.text = message
