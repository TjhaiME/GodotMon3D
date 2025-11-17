Absolutely — here’s a clean **summary document** you can drop into your repo as `docs/control_system_summary.md` (or keep locally) to quickly refresh your memory later.

---

# 🎮 Control System Architecture Summary

**Godot 4.5 – Modular Pokémon-like Battle System**

---

## 🧩 Core Concept

We’re building a **data-driven, modular control system** for an action-based “monster battle” game — where:

* You can **control trainers, monsters, or attacks** directly.
* Every controllable object handles its own movement and logic.
* Input handling is **device-agnostic** (keyboard, controller, VR).
* The master controller simply **delegates control** — not logic.

---

## 🧱 Overview of Components

### 🧠 `Controllable.gd`

**Base class** for anything that can be controlled (trainer, monster, attack).

* Extends `CharacterBody3D`
* Has a simple flag:

  ```gdscript
  var is_controlled: bool = false
  ```
* Keeps running physics & logic even when not player-controlled.
* Only responds to input when `is_controlled == true`.

#### Key Functions

```gdscript
func handle_input(delta: float, input_data: Dictionary) -> void:
	pass  # called only if controlled

func _physics_process(delta):
	if is_controlled:
		_handle_controlled_physics(delta)
	else:
		_handle_autonomous_physics(delta)
```

Use `handle_input()` to process movement, aiming, or attacks.

---

### 🐾 `Monster.gd`

Subclass of `Controllable`.

Implements:

* Basic WASD or stick movement
* Rotation towards movement direction
* Attack trigger printout (for now)

Used to test the input pipeline.

---

### 🔮 `Attack.gd`

Also inherits from `Controllable`.

Implements:

* Own movement logic (e.g., steerable projectile)
* Duration timer (`duration` + `life`)
* Frees itself when finished

Attacks are *self-contained entities* with independent control and physics.

---

### 🧰 `ControllerManager.gd`

**Master control node** that manages which entity is currently controlled.

Responsibilities:

* Owns one `InputProvider` (keyboard, controller, VR).
* Sends input each frame to the active `Controllable`.
* Toggles `is_controlled` flags when swapping focus.

```gdscript
func set_control(new_controller: Controllable):
	if current_controller:
		current_controller.is_controlled = false
	current_controller = new_controller
	current_controller.is_controlled = true
```

---

### ⌨️ `InputProvider.gd`

Abstract base class that defines a common input structure.

Always returns a **Dictionary** of normalized input data:

```gdscript
{
	"move": Vector2,
	"look": Vector2,
	"attack_pressed": bool,
	"attack_held": bool,
	"attack_released": bool,
	"dodge_pressed": bool,
	"jump_pressed": bool
}
```

All input devices must implement this interface.

---

### 🎹 `KeyboardInputProvider.gd`

Concrete implementation of `InputProvider`.

Maps keyboard/mouse input to the standardized dictionary.

#### Example:

```gdscript
input_data["move"] = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
input_data["attack_pressed"] = Input.is_action_just_pressed("attack_primary")
```

**Input Map bindings to define:**

```
move_forward  = W / ↑
move_back     = S / ↓
move_left     = A / ←
move_right    = D / →
attack_primary = Left Mouse / Ctrl
dodge          = Shift / Space
jump           = Space / A button
```

---

## 🧩 Data Flow Summary

```
Keyboard / Controller / VR
		  ↓
	 InputProvider
		  ↓
   ControllerManager
		  ↓
  Active Controllable (Monster, Attack, etc.)
		  ↓
   handle_input(delta, input_data)
		  ↓
  Entity-specific movement & logic
```

---

## 🔁 Control Swapping

1. Start controlling the **trainer** or **monster**.
2. When an attack is used:

   * `ControllerManager.set_control(attack_instance)`
   * Monster’s `is_controlled` = false
   * Attack’s `is_controlled` = true
3. When attack ends:

   * `ControllerManager.set_control(monster)` (or previous stack entry)
4. Each object keeps simulating in the background.

---

## 🧠 Design Philosophy

| Goal                         | Achieved By                                 |
| ---------------------------- | ------------------------------------------- |
| Unified control logic        | `Controllable` base class                   |
| Modular, reusable entities   | Per-entity subclasses (Monster, Attack)     |
| Simple control switching     | Single `is_controlled` flag                 |
| Device-independent input     | InputProvider system                        |
| Minimal code, data-heavy     | Use exported variables/resources for tuning |
| Future-ready (controller/VR) | Swap in new `InputProvider` subclasses      |

---

## 🔧 Next Steps / Expansion Ideas

* **Add Trainer → Monster switching**

  * Throw Pokéball → spawn monster → transfer control.
* **Cooldown / fatigue system**

  * Each attack tracks its own cooldown timers.
* **Element & stat data**

  * Use `.tres` or JSON files to define attack stats.
* **Controller & VR support**

  * Implement `ControllerInputProvider` and `VRInputProvider`.
* **Camera system**

  * Camera follows `current_controller` dynamically.

---

### 🗃️ Quick File Index

| File                                   | Purpose                                      |
| -------------------------------------- | -------------------------------------------- |
| `entities/Controllable.gd`             | Base controllable interface                  |
| `entities/Monster.gd`                  | Example controllable monster                 |
| `entities/Attack.gd`                   | Example steerable attack                     |
| `controllers/InputProvider.gd`         | Abstract input interface                     |
| `controllers/KeyboardInputProvider.gd` | Keyboard/mouse input provider                |
| `controllers/ControllerManager.gd`     | Manages which entity is currently controlled |

---

### 🧩 Mental Model Recap

> “Every entity runs all the time — only the one marked `is_controlled = true` listens to input.”

---

Would you like me to include a small **ASCII diagram of the control flow** (like a flowchart from input → controller → entity → world) in this document too? It’s great for quick onboarding or explaining to collaborators.
