# Treasure Box — Design

A beautiful Minecraft-themed tracker for real, physical boxes. Built as a
companion for a hand-made treasure chest with an NFC tag on the lid - tap the
box and its inventory opens - and extensible to any container: storage bins,
toolboxes, moving boxes. Every box is reachable three ways: an NFC tag, a
printed QR code, or a simple typed code. The app is the answer to "what is in
this box" and "which box has my X" - wrapped in a warm, immersive Minecraft
room.

## 1. Product

- **The tap moment**: tap a phone on the chest's tag. The app opens on the
  room, the camera settles on the chest, the lid swings open, and the
  inventory chunk-loads in. That moment must feel like Minecraft, not like a
  database app.
- **The tracker**: the same app tracks any number of physical boxes. Each box
  in the app mirrors a real container. Items carry an optional `spot` ("side
  pocket", "bottom layer") so the answer to "where is it" is precise. Global
  find-my-stuff searches every box at once.
- **Identity rails** - ONE human code (`BOX-N`) per box, carried by every
  rail. Each rail wraps the code in its own envelope so the app knows HOW a
  box was opened:
  1. **NFC tag** (the hero path on mobile): the tag stores two NDEF records -
     a `treasurebox://box/BOX-N` URI (Android auto-opens the app) and a JSON
     text record `{"v":1,"code":"BOX-N","name":...,"src":"nfc"}` (NTAG216 has
     888 bytes - room to spare). Payload presence = NFC rail.
  2. **QR code** (printable, universal): the printed QR encodes
     `TB:BOX-N:QR`. Scanning opens `/box/TB:BOX-N:QR`; the app strips the
     envelope and knows the rail was QR.
  3. **Box code** (no hardware at all): `BOX-N`, the bare slot number, or the
     box name typed into "Code" on home. No envelope = ID rail.
- **Rails are auto-learned, not declared**: badges beside the box name (home
  chip + inventory header) show only the rails actually used - ID always,
  QR after a scan opened the box, NFC once a tag is linked or tapped.
- **Slot reuse**: `BOX-N` codes are assigned as the lowest free slot, so
  deleting all boxes and creating new ones reuses BOX-1 first - printed QR
  labels and written NFC tags stay valid across box turnover.
- **Offline-first**: everything lives in a local SQLite database. No account,
  no network. NFC/QR/code are conveniences, never requirements.

## 2. Confirmed decisions

- **State**: Riverpod. **Persistence**: Drift (SQLite) behind an abstract
  `InventoryRepository`; UI never touches generated Drift types.
- **Multi-box** is core, not an extension: box schema carries `qrToken`
  (stable identity), `nfcTagId`, `skinKey` (cosmetic), room position, sort.
- **Item images**: curated Minecraft pixel icon per item + optional real photo.
- **NFC**: real and optional (`nfc_manager` on mobile, stub elsewhere). The
  stub never auto-fires - a simulated tap is always an explicit user action.
- **Capacity** counts item stacks/slots (rows), not summed quantity.
- **Chest opening is calm and in-place**: the world never warps. Lid swings
  open on the chest itself + a subtle camera push-in (max 1.06x), short dwell,
  then the block-wipe ("chunk load") transition into the inventory.
- Game/mini-game ideas (archaeology dig, trophy shelf) are parked: the product
  is the tracker. Any future game must never touch the real inventory. The
  one playful element that stays is the home-wall ore easter egg, governed by
  the shared `OreKind` rulebook (`core/game/mine_block.dart`): hardness (taps
  to break) and points per ore, session-scoped tally, cosmetic only.

## 3. Architecture

Layered, feature-first. Unchanged since v1 and load-bearing - do not break:

```text
UI (features/*)  ->  Riverpod providers  ->  InventoryRepository (interface)
                                                     |
                                          DriftInventoryRepository
                                                     |
                                            AppDatabase (Drift)  ->  SQLite
```

- **Repository boundary**: features import only domain models (`Item`, `Box`,
  `ItemDraft`, `FoundItem`), never Drift-generated types.
- **Platform abstraction**: `NfcService` and the DB connection are chosen by
  conditional import; mobile-only packages never break desktop/web builds.

```text
lib/
  core/
    theme/       MinecraftColors (+voidDark/obsidianDeep), text styles, theme
    widgets/     pixel primitives, MinecraftChest (+ChestSkin), world scene,
                 particles + performance throttle, block-wipe transition
    data/        tables, daos, connection (native/web), models, repositories
    providers/   database, repository, boxes, inventory query
    router/      GoRouter config (incl. /box/:code deep link)
    platform/    NfcService interface + mobile impl + stub + factory
  features/
    home/        room viewport, camera controller, chest layer, open sequence
    inventory/   list, search/filter, header, hotbar
    item_detail/ add_item/  create_box/  find/  box_link/
    settings/    the Info tab: stats, NFC, name/capacity, label kit, recent
```

Plus `core/game/mine_block.dart` (the `OreKind` rulebook) and
`core/data/models/box_code.dart` (rail envelope parse - the only place the
`TB:...:QR` format is known).

## 4. Data model (schemaVersion = 1)

**Box**: `id`, `name`, `capacity` (default 27), `nfcTagId?`, `qrToken?`
(the human code `BOX-<slot>`), `slot` (lowest-free identity number),
`skinKey` (default `oak`), `roomX`/`roomY` (0..1), `sortOrder`,
`qrUsedAt?`/`nfcUsedAt?` (auto-learned rail usage stamps), timestamps.

**Item**: `id`, `boxId` (FK cascade), `name`, `category`, `iconKey`,
`photoPath?`, `qty`, `rarity`, `notes?`, `spot?` (where inside the box),
timestamps.

- Enums stored as `.name` strings (readable rows, reorder-safe).
- `PRAGMA foreign_keys = ON` in `beforeOpen` so box deletion cascades.
- Demo seed (2 boxes + items) only with `--dart-define=DEMO=true`.

### Identity resolution

`parseBoxCode(raw)` (`models/box_code.dart`) - strips the deep-link path and
the `TB:...:QR` envelope, canonicalizes `BOX-N`, and reports the rail
(`BoxCodeSource.qr/nfc/id`). Pure function, unit-tested.
`boxByToken(token)` - exact token match (NFC/QR path).
`boxByAnyCode(code)` - tolerant resolution for anything a label can carry:
parses via `parseBoxCode`, then tries code -> slot number -> case-insensitive
exact name. Used by the "Code" entry and the `/box/:code` route.
`markOpenedVia(boxId, source)` - stamps `qrUsedAt`/`nfcUsedAt` when a rail
actually opens a box (ID rail stamps nothing); drives the earned badges.

## 5. Look and feel

- **One dark base**: `voidDark` (#0B0A10) under everything; surface gradients
  run obsidian -> `obsidianDeep`. No patchwork of grays; `headerBar` is a dark
  obsidian tone, not a light slab.
- **The room**: panoramic painted scene (stone-brick wall, ore flecks, grass
  floor, torches), camera pans with drag and snaps to the nearest chest.
  Ambient particles (dust, torch sparks, embers, XP orbs, bat shadows) with a
  frame-time throttle.
- **Focal chest**: the centered chest is the hero - larger (~1.08x) with a
  gentle idle bob; neighbors recede and dim. No glow behind the chest (a
  radial gradient reads as a square against the wall). In-world name chips
  (name + earned rail badges) instead of floating cards.
- **Wall ores**: mineable easter-egg blocks in the wall follow the `OreKind`
  rulebook - iron/redstone/coal 2 taps, gold/diamond 3; cracks densify one
  tap before breaking; breaking awards points to a session toast.
- **Ghost chest**: adding a box = a desaturated translucent chest with a faint
  "+" sitting in the room; tapping it opens the 2-step creation wizard.
- **Typography**: Press Start 2P only >=12px for display/labels; VT323 >=16px
  for sentences. Both bundled as assets (offline, deterministic tests).
- **Transitions**: block-wipe ("chunk loading") between screens.

## 6. Interaction model (home)

Tap and pan coexist on ONE `GestureDetector` (the tap-vs-pan fix): the
viewport resolves chest hits in screen space on `onTapUp`, drags pan the
camera. Nested per-chest detectors under a pan detector lose the gesture
arena and swallow taps on web/desktop - never reintroduce that.

Open sequence (`OpenSequenceController`): `lid` (550ms, easeOutCubic) ->
`dwell` (500ms) -> navigate. Derived values: `lidOpenValue` (0..1),
`pushScale` (1.0 -> 1.06). Cancel reverses in place.

## 7. Screens

- **Home / room**: panoramic room, centered chest hero, quiet bottom entries
  ("My stuff", "Scan", "About"). Title text embedded in the scene. Empty
  state = ghost chest centered, "Place your first chest". The camera resumes
  ON the last-opened box (no snap animation).
- **Box link** (`/box/:code`): deep-link resolver; known code -> the ROOM
  with the cinematic open (pendingOpenProvider); unknown -> themed error.
- **Inventory**: header (mini chest, name, LINKED, capacity bar), search +
  filter/sort sheet, item tiles, hotbar nav. Title tap returns to the room.
- **Item detail / Add-Edit**: pixel icon or photo hero, rarity, qty stepper,
  notes, spot; capacity enforced on add; TNT delete confirm.
- **Create box**: 2-step wizard (name -> skin: oak/spruce/birch/ender).
- **My stuff** (`/find`): the cross-box hub - MY CHESTS list (open/delete
  per chest), recent additions across boxes, and search; results show
  `box - spot` and tap through to the item.
- **Info tab** (`/info` - the ONLY second tab; `/settings` redirects here):
  chest stats (fill, stack/item counts, category bars), NFC status +
  simulate-a-tap, chest name + capacity, box code & QR label kit,
  write-tag, recently-added items across boxes, danger zone. One place for
  everything about the chest; hotbar is just Chest / Info / +.
- **Home extras**: persistent mining points chip top-right (pickaxe + total,
  shared_preferences), hidden until the first ore breaks. The app runs
  fullscreen immersive (system bars hidden; edge-swipe peeks them).

## 8. NFC / identity flows

- **Tap a written tag** -> the NDEF payload carries the box code, so ANY
  phone resolves it without prior linking -> camera pans to its chest ->
  open sequence -> inventory. Stamps `nfcUsedAt`.
- **Tap an unknown tag** -> link it to the default box, then open.
  Re-linking to another box is Info -> Write tag.
- **Write tag** (Settings / Info label kit): writes both NDEF records (URI +
  JSON metadata with code and box name).
- **Scan the printed QR** -> OS opens `/box/TB:BOX-N:QR` -> envelope stripped
  -> inventory. Stamps `qrUsedAt`.
- **Type a code** -> home "Code" entry -> `boxByAnyCode` -> pan + open. No
  stamp - the ID rail is always available.
- **No hardware** -> tap the chest itself, or Settings -> Simulate a tap.
- The stub `NfcService.waitForTag()` resolves ONLY on `simulateTap()` (an
  explicit action, bufferable from Settings before home mounts). The app
  never opens a chest by itself.

## 9. Testing and verification

- **Unit** (in-memory Drift): CRUD, slot/capacity semantics, cascade delete,
  `boxByToken`, `boxByAnyCode` (token / id / name / deep link / envelope /
  junk), `parseBoxCode` rails, `markOpenedVia` stamps, recent-items ordering,
  find-my-stuff.
- **Widget**: inventory, add/edit, room viewport tap-vs-pan (tap opens, drag
  pans, tap-after-drag, ghost chest, empty room), open-sequence phases.
  Ambient tickers never settle - use fixed-duration pumps, not
  `pumpAndSettle`.
- **End-to-end** from the repo root: `flutter pub get` -> `dart run build_runner
  build --delete-conflicting-outputs` -> `flutter analyze` (0 issues) ->
  `flutter test` -> `flutter build web --dart-define=DEMO=true` -> serve and
  drive with Playwright (tap-to-open, pan, code entry, QR render, deep link,
  CRUD, search, settings) with screenshots.

## 10. Dependencies

| Package | Why | Notes |
| --- | --- | --- |
| `flutter_riverpod` | state | |
| `drift` (+`drift_dev`, `build_runner`) | SQLite + codegen | web: `sqlite3.wasm` + worker in `web/` |
| `sqlite3_flutter_libs`, `path_provider`, `path` | native DB | no-op on web |
| `go_router` | routing, ShellRoute, `/box/:code` deep link | |
| `image_picker` | optional real photo | desktop = file dialog |
| `nfc_manager` | real NFC | Android/iOS only, behind `NfcService` |
| `qr_flutter` | per-box QR render | pure Dart, all platforms |
| bundled fonts | Press Start 2P + VT323 | assets, no google_fonts |

## 11. Extension points (designed-for, not built)

- **Camera QR scanning in-app** (mobile_scanner) so the app can scan labels
  itself instead of relying on the OS camera.
- **Custom URL scheme / app links** (`treasurebox://box/<token>`) so printed
  QRs open the installed app directly on mobile.
- **Box archive/labels page**: print sheet with several QR labels at once.
- **The parked game**: if ever built, rewards live in a separate collection
  and currency - never in the real inventory.
