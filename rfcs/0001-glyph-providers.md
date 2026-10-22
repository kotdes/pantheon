# RFC 0001: glyph providers

- **Status:** draft
- **Author:** 7kayoh
- **Date:** 21 October 2026
- **Pull request:** N/A

## Summary

This RFC proposes a new way to manage icons in Pantheon. Pantheon stops depending on one icon family. The `Icon` component asks a registered glyph provider for an icon. A provider returns an image or a set of `Path2D` objects.

Pantheon still ships with Lucide (`luci`) as the default provider, so current code keeps working. Other families, such as Phosphor (`phor`), are separate packages. A provider can also draw icons at run time with `EditableImage` or `Path2D`.

## Problem

`Icon` calls Lucide directly. That causes 4 problems:

- You cannot use another icon family, such as Phosphor or your own set, without forking Pantheon and editing it. A fork stops receiving updates and can require effort to merge new releases.
- The author of the Lucide package for Roblox does not plan to update it again. New icons from the official Lucide set are not available in Pantheon. The Pantheon team does not have the resources to maintain a large icon set.
- Sprite atlases use more memory and storage with each icon you add. Pantheon aims to be light and fast.
- Lucide is a static set. You cannot use animated or dynamic icons.

## Proposal

### Providers

A provider is a table:

```luau
type GlyphProvider = {
	Id: string,
	Aliases: { string }?,
	Resolve: (name: string, size: number) -> Glyph?,
	Roles: { [string]: string }?,
}
```

`Resolve` returns one of 2 kinds of glyph, or `nil` if the provider does not have the icon:

```luau
type Glyph = {
	Kind: "Image",
	Image: Content,
	Offset: Vector2,
	Size: Vector2,
	Tint: boolean,
} | {
	Kind: "Path2D",
	ViewBox: Vector2,
	Build: (parent: GuiObject, colour: Color3, size: number) -> (),
}
```

- Use `Content` for an image, so a sprite atlas, an asset and an `EditableImage` all work.
- Set `Tint` to `false` for an image that already has its colours and must not be recoloured.
- `Build` creates the `Path2D` objects under `parent`.

`Icon` builds an `ImageLabel` or a frame with `Path2D` objects, depending on the kind. It does not cache. Each provider caches its own results.

If `Resolve` returns `nil`, `Icon` warns once and shows an empty box.

### Registering and choosing

```luau
Pantheon.Icons.register("phor", provider)
Pantheon.Icons.setDefault("phor")
```

`register` rejects an id or alias that another provider already uses.

### Names and prefixes

- A bare name such as `home` goes to the default provider.
- A prefix with a colon picks a provider: `luci:home`, `phor:house`. This is the form the documentation uses.
- Hyphen prefixes do not work, because icon names contain hyphens. A provider with the id `arrow` would break `arrow-up`.

### Roles

Pantheon's own icons (close, chevron, check) use roles, not family names. A provider maps a role to one of its own names in `Roles`. If the default provider has no mapping for a role, Pantheon uses the Lucide name. A partial provider does not break components.

### Packaging

- The Lucide provider ships with Pantheon and is the default.
- Later, the Lucide provider can move to `Path2D`, which is smaller and faster.
- Other providers are addons that call `Icons.register`. Examples are Phosphor, a `Path2D` version of Lucide, and an `EditableImage` renderer.
- `Path2D` is in beta, so it is not the default.

## Alternatives

- **Build several families into Pantheon.** This makes the package larger, and every new family needs a release.
- **One addon package for each family, with no shared interface.** Each package would patch `Icon`. They would conflict.
- **A registry that belongs to the theme.** See the open questions.

## Compatibility

Bare names still fall back to Lucide, so current code keeps working without changes. All icons already go through `Icon.luau`. Other files mention Lucide only in comments. That code moves to the Lucide provider. The `Name` property of `Icon` keeps its type.

## Open questions

- Should the registry be global, or travel with the theme through `Theme.Provide`? A theme-scoped registry lets one window use a different family. A global one is simpler. The lookup stays behind one function so it can change later.
- Should weight be part of the name (`phor:house-bold`), or a separate `IconWeight` property?
- Is `Path2D` stable enough to be the default, for a framework that shows many icons?

## Rollout

- Version 0.2: the provider interface, the registry, and roles for internal icons.
- Later: Phosphor and the other addons, as separate packages, and a `Path2D` version of Lucide. This depends on what the community needs and on whether `Path2D` is stable enough to be the default.