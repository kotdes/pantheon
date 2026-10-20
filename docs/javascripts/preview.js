/* Live component previews drawn as SVG.
   <div class="es-preview" data-component="Button"></div>
   Each renderer returns SVG markup and the Luau that makes the same component. The SVG is a
   drawing of the component, not the component itself, so keep it in step with the Luau by hand. */
(function () {
	const FONT = 'font-family="Figtree, sans-serif" font-size="14" font-weight="600"';

	const renderers = {
		Button: {
			controls: [
				{ key: "Text", type: "text", value: "Run" },
				{ key: "Variant", type: "select", value: "Filled", options: ["Filled", "Tonal", "Outlined", "Text"] },
				{ key: "Disabled", type: "check", value: false },
				{ key: "Color", type: "color", value: "" },
			],
			svg(p) {
				const w = Math.max(72, p.Text.length * 9 + 40);
				const accent = p.Color || "var(--es-primary)";
				const cx = w / 2;
				const d = p.Disabled;
				const fill = {
					Filled: accent,
					Tonal: p.Color ? `color-mix(in srgb, ${p.Color} 25%, var(--es-surface))` : "var(--es-primary-container)",
					Outlined: "none",
					Text: "none",
				}[p.Variant];
				const ink = {
					Filled: p.Color ? onColor(p.Color) : "var(--es-on-primary)",
					Tonal: p.Color ? "var(--es-on-surface)" : "var(--es-on-primary-container)",
					Outlined: accent,
					Text: accent,
				}[p.Variant];
				const stroke = p.Variant === "Outlined" ? `stroke="${accent}" stroke-width="1.5"` : "";
				const body = d
					? `<rect width="${w}" height="40" rx="20" fill="var(--es-on-surface)" opacity=".12"/>
					   <text x="${cx}" y="25" text-anchor="middle" ${FONT} fill="var(--es-on-surface)" opacity=".38">${esc(p.Text)}</text>`
					: `<rect width="${w}" height="40" rx="20" fill="${fill}" ${stroke}/>
					   <text x="${cx}" y="25" text-anchor="middle" ${FONT} fill="${ink}">${esc(p.Text)}</text>`;
				return `<svg width="${w}" height="40" viewBox="0 0 ${w} 40">${body}</svg>`;
			},
			luau(p) {
				const lines = [`Text = "${p.Text}",`, `Variant = "${p.Variant}",`];
				if (p.Color) lines.push(`Color = "${p.Color}",`);
				if (p.Disabled) lines.push("Disabled = true,");
				return `scope:Button({\n\t${lines.join("\n\t")}\n})`;
			},
		},
		TextField: {
			controls: [
				{ key: "Label", type: "text", value: "Name" },
				{ key: "Placeholder", type: "text", value: "Type here" },
				{ key: "Text", type: "text", value: "" },
				{ key: "Error", type: "text", value: "" },
				{ key: "Disabled", type: "check", value: false },
			],
			svg(p) {
				const edge = p.Error ? "var(--es-error)" : "var(--es-outline)";
				const shown = p.Text || p.Placeholder;
				const ink = p.Text ? "var(--es-on-surface)" : "var(--es-on-variant)";
				const note = p.Error ? `<text x="2" y="76" font-size="12" fill="var(--es-error)" font-family="Figtree, sans-serif">${esc(p.Error)}</text>` : "";
				return `<svg width="260" height="84" viewBox="0 0 260 84" opacity="${p.Disabled ? 0.45 : 1}">
					<text x="2" y="12" font-size="12" fill="var(--es-on-variant)" font-family="Figtree, sans-serif">${esc(p.Label)}</text>
					<rect x="1" y="20" width="258" height="40" rx="10" fill="var(--es-surface)" stroke="${edge}" stroke-width="1.5"/>
					<text x="14" y="45" font-size="14" fill="${ink}" font-family="Figtree, sans-serif">${esc(shown)}</text>
					${note}
				</svg>`;
			},
			luau(p) {
				const lines = [];
				if (p.Label) lines.push(`Label = "${p.Label}",`);
				if (p.Placeholder) lines.push(`Placeholder = "${p.Placeholder}",`);
				if (p.Text) lines.push(`Text = "${p.Text}",`);
				if (p.Error) lines.push(`Error = "${p.Error}",`);
				if (p.Disabled) lines.push("Disabled = true,");
				return `scope:TextField({\n\t${lines.join("\n\t")}\n})`;
			},
		},
		Slider: {
			controls: [
				{ key: "Label", type: "text", value: "Volume" },
				{ key: "Value", type: "range", value: 0.6 },
				{ key: "Disabled", type: "check", value: false },
			],
			svg(p) {
				const x = 8 + p.Value * 244;
				const on = p.Disabled ? "var(--es-outline)" : "var(--es-primary)";
				return `<svg width="260" height="50" viewBox="0 0 260 50" opacity="${p.Disabled ? 0.45 : 1}">
					<text x="2" y="12" font-size="12" fill="var(--es-on-variant)" font-family="Figtree, sans-serif">${esc(p.Label)} (${(+p.Value).toFixed(2)})</text>
					<rect x="8" y="32" width="244" height="4" rx="2" fill="var(--es-outline)"/>
					<rect x="8" y="32" width="${x - 8}" height="4" rx="2" fill="${on}"/>
					<circle cx="${x}" cy="34" r="9" fill="${on}"/>
				</svg>`;
			},
			luau(p) {
				return `scope:Slider({\n\tLabel = "${p.Label}",\n\tValue = scope:Value(${(+p.Value).toFixed(2)}),${p.Disabled ? "\n\tDisabled = true," : ""}\n})`;
			},
		},
		Checkbox: {
			controls: [
				{ key: "Label", type: "text", value: "Remember me" },
				{ key: "Checked", type: "check", value: true },
				{ key: "Disabled", type: "check", value: false },
			],
			svg(p) {
				const box = p.Checked
					? `<rect x="1" y="1" width="20" height="20" rx="5" fill="var(--es-primary)"/>
					   <path d="M6 11.5l3.5 3.5L16 8" fill="none" stroke="var(--es-on-primary)" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>`
					: `<rect x="1.5" y="1.5" width="19" height="19" rx="5" fill="none" stroke="var(--es-on-variant)" stroke-width="2"/>`;
				const w = 40 + p.Label.length * 8;
				return `<svg width="${w}" height="22" viewBox="0 0 ${w} 22" opacity="${p.Disabled ? 0.45 : 1}">${box}
					<text x="32" y="16" font-size="14" fill="var(--es-on-surface)" font-family="Figtree, sans-serif">${esc(p.Label)}</text></svg>`;
			},
			luau(p) {
				return `scope:Checkbox({\n\tLabel = "${p.Label}",\n\tChecked = scope:Value(${p.Checked}),${p.Disabled ? "\n\tDisabled = true," : ""}\n})`;
			},
		},
		Tabs: {
			controls: [
				{ key: "Selected", type: "select", value: "Overview", options: ["Overview", "Usage", "Props"] },
			],
			svg(p) {
				const items = ["Overview", "Usage", "Props"];
				const w = 96;
				const tabs = items
					.map((name, i) => {
						const on = name === p.Selected;
						return `<text x="${i * w + w / 2}" y="26" text-anchor="middle" font-size="14" font-weight="${on ? 700 : 500}" fill="${on ? "var(--es-primary)" : "var(--es-on-variant)"}" font-family="Figtree, sans-serif">${name}</text>
						${on ? `<rect x="${i * w + 14}" y="38" width="${w - 28}" height="3" rx="1.5" fill="var(--es-primary)"/>` : ""}`;
					})
					.join("");
				return `<svg width="${w * 3}" height="44" viewBox="0 0 ${w * 3} 44"><rect y="42" width="${w * 3}" height="1" fill="var(--es-outline)"/>${tabs}</svg>`;
			},
			luau(p) {
				return `scope:Tabs({\n\tItems = {\n\t\t{ Id = "Overview", Label = "Overview" },\n\t\t{ Id = "Usage", Label = "Usage" },\n\t\t{ Id = "Props", Label = "Props" },\n\t},\n\tSelected = scope:Value("${p.Selected}"),\n})`;
			},
		},
		Switch: {
			controls: [{ key: "Value", type: "check", value: true }],
			svg(p) {
				return `<svg width="52" height="30" viewBox="0 0 52 30">
					<rect width="52" height="30" rx="15" fill="${p.Value ? "var(--es-primary)" : "var(--es-outline)"}"/>
					<circle cx="${p.Value ? 37 : 15}" cy="15" r="${p.Value ? 11 : 9}" fill="${p.Value ? "var(--es-on-primary)" : "var(--es-surface)"}"/>
				</svg>`;
			},
			luau(p) {
				return `scope:Switch({\n\tValue = scope:Value(${p.Value}),\n})`;
			},
		},
	};

	function onColor(hex) {
		const n = parseInt(hex.slice(1), 16);
		const lum = (0.2126 * (n >> 16) + 0.7152 * ((n >> 8) & 255) + 0.0722 * (n & 255)) / 255;
		return lum > 0.5 ? "#000000" : "#ffffff";
	}

	function esc(text) {
		return String(text).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
	}

	function mount(root) {
		const spec = renderers[root.dataset.component];
		if (!spec || root.dataset.ready) return;
		root.dataset.ready = "1";
		const state = {};
		spec.controls.forEach((c) => (state[c.key] = c.value));
		root.innerHTML =
			'<div class="es-preview__stage"></div><div class="es-preview__controls"></div><pre><code></code></pre>';
		const stage = root.querySelector(".es-preview__stage");
		const controls = root.querySelector(".es-preview__controls");
		const code = root.querySelector("code");

		function draw() {
			stage.innerHTML = spec.svg(state);
			code.textContent = spec.luau(state);
		}

		spec.controls.forEach((c) => {
			const label = document.createElement("label");
			label.append(c.key + " ");
			let input;
			if (c.type === "select") {
				input = document.createElement("select");
				c.options.forEach((o) => input.add(new Option(o)));
				input.value = c.value;
				input.onchange = () => ((state[c.key] = input.value), draw());
			} else if (c.type === "color") {
				input = document.createElement("input");
				input.type = "color";
				input.value = "#00695c";
				input.onchange = () => ((state[c.key] = input.value), draw());
				const reset = document.createElement("button");
				reset.type = "button";
				reset.textContent = "Reset";
				reset.onclick = () => ((state[c.key] = ""), draw());
				label.append(input, reset);
				controls.append(label);
				return;
			} else if (c.type === "range") {
				input = document.createElement("input");
				input.type = "range";
				input.min = 0;
				input.max = 1;
				input.step = 0.01;
				input.value = c.value;
				input.oninput = () => ((state[c.key] = +input.value), draw());
			} else if (c.type === "check") {
				input = document.createElement("input");
				input.type = "checkbox";
				input.checked = c.value;
				input.onchange = () => ((state[c.key] = input.checked), draw());
			} else {
				input = document.createElement("input");
				input.type = "text";
				input.value = c.value;
				input.oninput = () => ((state[c.key] = input.value), draw());
			}
			label.append(input);
			controls.append(label);
		});
		draw();
	}

	function run() {
		document.querySelectorAll(".es-preview[data-component]").forEach(mount);
	}
	if (window.document$) window.document$.subscribe(run);
	else document.addEventListener("DOMContentLoaded", run);
})();
