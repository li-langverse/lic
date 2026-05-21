/** Virtual project files for wireframe code editor (maps to future workspace FS). */
(function (global) {
  const FILES = {
    "world.li": {
      path: "world.li",
      language: "python",
      dirty: false,
      sample: `# world.li — root scene (git-diffable)
import world
import physics.custom

def main() -> unit:
    var body = world.spawn("RocketBody", at=(0.0, 12.0, 0.0))
    body.attach("Nozzle", mesh="nozzle.gltf")
    body.set_law(physics.custom.inverse_gravity, gamma=1.02)
    world.run(profile=sim_profile_scientific)
`,
    },
    "physics/custom_gravity.li": {
      path: "physics/custom_gravity.li",
      language: "python",
      dirty: false,
      sample: `# User custom physics — composable gate required
import physics.custom

def inverse_gravity(state: SimState) -> Vec3:
    requires state.mass > 0.0
    ensures result.norm() > 0.0
    return Vec3(0.0, 9.81 * state.mass_inv, 0.0)
`,
    },
    "studio.toml": {
      path: "studio.toml",
      language: "toml",
      dirty: false,
      sample: `[project]
name = "rocket-demo"
profile = "game"

[theme]
preset = "aurora"

[bench]
tier2 = "world_engine"
`,
    },
    "packages/game/rocket_logic.li": {
      path: "packages/game/rocket_logic.li",
      language: "python",
      dirty: true,
      sample: `# Custom gameplay / creation logic (user code)
def on_tick(tick: int, nozzle: Entity) -> unit:
    if tick % 60 == 0:
        nozzle.set_thrust(1.0e6)
    ensures lic_gate_passed()
`,
    },
    "gui/hud.li": {
      path: "gui/hud.li",
      language: "python",
      dirty: false,
      sample: `import gui

def hud_main() -> unit:
    gui.label("γ", bind="physics.gamma")
    gui.button("Play", cmd=ui_cmd_play())
`,
    },
  };

  const PATCH_DIFF = {
    "world.li": {
      title: "patch_id=2 · spawn Z +12m",
      hunks: [
        { type: "ctx", text: "@@ spawn RocketBody @@" },
        { type: "del", text: '-    var body = world.spawn("RocketBody", at=(0.0, 0.0, 0.0))' },
        { type: "add", text: '+    var body = world.spawn("RocketBody", at=(0.0, 12.0, 0.0))' },
        { type: "ctx", text: "     body.attach(\"Nozzle\", mesh=\"nozzle.gltf\")" },
      ],
    },
  };

  const PROBLEMS = [
    { severity: "error", code: "E0303", file: "packages/game/rocket_logic.li", line: 5, message: "ensures must not be bare true on value return" },
    { severity: "warn", code: "W1201", file: "world.li", line: 6, message: "spawn height may intersect ground mesh" },
    { severity: "info", code: "I0001", file: "studio.toml", line: 8, message: "bench tier2 row world_engine not run this session" },
  ];

  const ASSETS = [
    { name: "nozzle.gltf", type: "mesh", size: "2.1 MB" },
    { name: "rocket_body.gltf", type: "mesh", size: "4.8 MB" },
    { name: "exhaust.fx", type: "vfx", size: "12 KB" },
    { name: "field_heat_001.bin", type: "sim", size: "840 KB" },
  ];

  const INSPECTOR_SCHEMA = {
    RocketBody: [
      { key: "transform.position", label: "Position", type: "vec3", value: "0, 12, 0", unit: "m" },
      { key: "transform.rotation", label: "Rotation", type: "vec3", value: "0, 0, -3°", unit: "deg" },
      { key: "physics.mass", label: "Mass", type: "float", value: "4200", unit: "kg" },
      { key: "physics.custom_law", label: "Custom law", type: "enum", value: "inverse_gravity" },
    ],
    Nozzle: [
      { key: "thrust", label: "Thrust", type: "float", value: "1.0e6", unit: "N" },
      { key: "gimbal", label: "Gimbal", type: "bool", value: "true" },
    ],
    default: [
      { key: "entity.id", label: "Entity id", type: "string", value: "—" },
      { key: "sim.profile", label: "Profile", type: "string", value: "sim_profile_scientific" },
    ],
  };

  global.StudioFiles = { FILES, PATCH_DIFF, PROBLEMS, ASSETS, INSPECTOR_SCHEMA };
})(window);
