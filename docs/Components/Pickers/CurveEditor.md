---
tags:
  - Pickers
  - Components
---

# CurveEditor

CurveEditor edits a `NumberSequence`, the curve used by particles, beams and trails. It is a plot of a smooth curve with keypoints you can drag, tangent handles to shape it, and number fields for the selected keypoint.

## Usage

Call `Components.CurveEditor` with a scope and a table of properties:

```luau
local curve = scope:Value(NumberSequence.new(0, 1))

scope:CurveEditor({
	Value = curve, -- (1)!
	Min = 0,
	Max = 1,
	ShowEnvelope = true,
})
```

1.  A `Value` and the editor follow each other. Assign `curve:get()` to a `ParticleEmitter.Size`, for example. A `NumberSequence` is a list of straight pieces, so the curve is sampled into up to 20 keypoints, spread over the curved segments.

## Editing

- Drag a keypoint to move it. The first keypoint stays at time `0` and the last at time `1`, and a keypoint cannot pass its neighbours.
- Select a keypoint to show its two tangent handles (the diamonds). Drag one to bend the curve. Keypoints you have not shaped get smooth tangents that follow their neighbours and stay flat at peaks.
- Double click the plot to add a keypoint. It starts on the curve and splits it where it is, so the curve does not change.
- Select a keypoint and press the trash button, or focus it and press Delete, to remove it. The first and last keypoints cannot be removed.
- The fields under the plot edit the selected keypoint: `T` is its time, `V` its value and `±` its envelope, when `ShowEnvelope` is on.
- A focused keypoint moves with the arrow keys.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |

## See also

- [GradientPicker](./GradientPicker.md)
- [NumberField](../Forms/NumberField.md)
