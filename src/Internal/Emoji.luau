--!strict

--[[
	Emoji.luau
]]

export type Group = { Name: string, Icon: string, Emojis: { string } }

local function list(text: string): { string }
	return string.split(text, " ")
end

local Emoji: { Group } = {
	{
		Name = "Faces",
		Icon = "smile",
		Emojis = list(
			"😀 😃 😄 😁 😆 😅 🤣 😂 🙂 🙃 😉 😊 😇 🥰 😍 🤩 😘 😗 😚 😙 🥲 😋 😛 😜 🤪 😝 🤑 🤗 🤭 🤫 🤔 🤐 🤨 😐 😑 😶 😏 😒 🙄 😬 🤥 😌 😔 😪 🤤 😴 😷 🤒 🤕 🤢 🤮 🤧 🥵 🥶 🥴 😵 🤯 🤠 🥳 🥸 😎 🤓 🧐 😕 😟 🙁 😮 😯 😲 😳 🥺 😦 😧 😨 😰 😥 😢 😭 😱 😖 😣 😞 😓 😩 😫 🥱 😤 😡 😠 🤬 😈 👿 💀 💩 🤡 👹 👺 👻 👽 👾 🤖"
		),
	},
	{
		Name = "Gestures",
		Icon = "hand",
		Emojis = list(
			"👋 🤚 🖐 ✋ 🖖 👌 🤌 🤏 ✌ 🤞 🤟 🤘 🤙 👈 👉 👆 🖕 👇 👍 👎 ✊ 👊 🤛 🤜 👏 🙌 👐 🤲 🤝 🙏 ✍ 💅 🤳 💪 🦾 👂 👃 🧠 👀 👁 👅 👄 👶 🧒 👦 👧 🧑 👨 👩 🧓 👴 👵 🙍 🙎 🙅 🙆 💁 🙋 🙇 🤦 🤷 💃 🕺"
		),
	},
	{
		Name = "Hearts",
		Icon = "heart",
		Emojis = list(
			"❤ 🧡 💛 💚 💙 💜 🖤 🤍 🤎 💔 ❣ 💕 💞 💓 💗 💖 💘 💝 💟 💋 💯 💢 💥 💫 💦 💨 💬 💭 💤"
		),
	},
	{
		Name = "Animals",
		Icon = "paw-print",
		Emojis = list(
			"🐶 🐱 🐭 🐹 🐰 🦊 🐻 🐼 🐨 🐯 🦁 🐮 🐷 🐸 🐵 🙈 🙉 🙊 🐔 🐧 🐦 🐤 🦆 🦅 🦉 🦇 🐺 🐗 🐴 🦄 🐝 🐛 🦋 🐌 🐞 🐜 🕷 🦂 🐢 🐍 🦎 🐙 🦑 🦐 🦀 🐡 🐠 🐟 🐬 🐳 🐋 🦈 🐊 🐅 🐆 🦓 🦍 🐘 🦛 🐪 🐫 🦒 🦘 🐃 🐂 🐄 🐎 🐖 🐏 🐑 🐐 🦌 🐕 🐩 🐈 🐓 🦃 🕊 🐇 🐁 🐀 🐿 🦔 🐉 🐲 🌵 🎄 🌲 🌳 🌴 🌱 🌿 ☘ 🍀 🍁 🍂 🍃 🍄 🌷 🌹 🌺 🌸 🌼 🌻 🌞 🌝 🌛 🌙 ⭐ 🌟 ✨ ⚡ 🔥 🌈 ☀ ⛅ ☁ 🌧 ⛈ ❄ ☃ 💧 🌊"
		),
	},
	{
		Name = "Food",
		Icon = "utensils",
		Emojis = list(
			"🍏 🍎 🍐 🍊 🍋 🍌 🍉 🍇 🍓 🫐 🍈 🍒 🍑 🥭 🍍 🥥 🥝 🍅 🍆 🥑 🥦 🥬 🥒 🌶 🌽 🥕 🧄 🧅 🥔 🍠 🥐 🥯 🍞 🥖 🧀 🥚 🍳 🥞 🥓 🥩 🍗 🍖 🌭 🍔 🍟 🍕 🥪 🌮 🌯 🥗 🍝 🍜 🍲 🍛 🍣 🍱 🥟 🍤 🍙 🍚 🍘 🍥 🥠 🍢 🍡 🍧 🍨 🍦 🥧 🧁 🍰 🎂 🍮 🍭 🍬 🍫 🍿 🍩 🍪 🌰 🥜 🍯 🥛 🍼 ☕ 🍵 🧃 🥤 🍶 🍺 🍻 🥂 🍷 🥃 🍸 🍹 🍾"
		),
	},
	{
		Name = "Activities",
		Icon = "gamepad-2",
		Emojis = list(
			"⚽ 🏀 🏈 ⚾ 🥎 🎾 🏐 🏉 🎱 🏓 🏸 🏒 🥍 🏏 🥅 ⛳ 🏹 🎣 🥊 🥋 ⛸ 🎿 🛷 🏆 🥇 🥈 🥉 🏅 🎖 🎗 🎫 🎟 🎪 🎭 🎨 🎬 🎤 🎧 🎼 🎹 🥁 🎷 🎺 🎸 🎻 🎲 ♟ 🎯 🎳 🎮 🎰 🧩"
		),
	},
	{
		Name = "Travel",
		Icon = "car",
		Emojis = list(
			"🚗 🚕 🚙 🚌 🚎 🏎 🚓 🚑 🚒 🚐 🚚 🚛 🚜 🛵 🏍 🚲 🛴 🚨 🚔 🚍 🚘 🚖 🚡 🚠 🚟 🚃 🚋 🚞 🚝 🚄 🚅 🚈 🚂 🚆 🚇 🚊 🚉 ✈ 🛫 🛬 🛩 💺 🛰 🚀 🛸 🚁 🛶 ⛵ 🚤 🛥 🛳 ⛴ 🚢 ⚓ 🚧 ⛽ 🚏 🗺 🗿 🗽 🗼 🏰 🏯 🏟 🎡 🎢 🎠 ⛲ 🏖 🏝 🏜 🌋 ⛰ 🏔 🗻 🏕 🏠 🏡 🏢 🏬 🏭 🏥 🏦 🏨 🏪 🏫 ⛪ 🕌 🕍 ⛩"
		),
	},
	{
		Name = "Objects",
		Icon = "lightbulb",
		Emojis = list(
			"⌚ 📱 💻 ⌨ 🖥 🖨 🖱 💽 💾 💿 📀 📷 📸 📹 🎥 📞 ☎ 📺 📻 🎙 ⏰ ⏳ ⌛ 📡 🔋 🔌 💡 🔦 🕯 🧯 💸 💵 💴 💶 💷 💰 💳 💎 ⚖ 🧰 🔧 🔨 ⚒ 🛠 ⛏ 🔩 ⚙ 🧱 ⛓ 🧲 🔫 💣 🧨 🔪 🗡 ⚔ 🛡 🚬 ⚰ 🔮 📿 🧿 💈 🔭 🔬 🩹 💊 💉 🧬 🦠 🧪 🌡 🧹 🧺 🧻 🚽 🚿 🛁 🧼 🧽 🔑 🗝 🚪 🛋 🛏 🧸 🖼 🛍 🎁 🎈 🎏 🎀 🎊 🎉 🎎 ✉ 📩 📦 📜 📃 📄 📊 📈 📉 📋 📌 📎 ✂ 🗃 🗄 🗑 🔒 🔓"
		),
	},
	{
		Name = "Symbols",
		Icon = "shapes",
		Emojis = list(
			"✅ ❌ ❎ ➕ ➖ ➗ ✖ ♾ ❓ ❔ ❕ ❗ ‼ ⁉ ⚠ 🚫 ⛔ 📵 🔞 ☢ ☣ ⬆ ↗ ➡ ↘ ⬇ ↙ ⬅ ↖ ↕ ↔ ↩ ↪ ⤴ ⤵ 🔃 🔄 🔙 🔚 🔛 🔜 🔝 ⚛ ☮ ☯ ✡ ☪ ♈ ♉ ♊ ♋ ♌ ♍ ♎ ♏ ♐ ♑ ♒ ♓ ⛎ 🔀 🔁 🔂 ▶ ⏩ ⏭ ◀ ⏪ ⏮ 🔼 ⏫ 🔽 ⏬ ⏸ ⏹ ⏺ ⏏ 🎦 🔅 🔆 📶 📳 📴 ♻ ⚜ 🔱 📛 🔰 ⭕ ☑ ✔ ➰ ➿ ⭐ 🌟 🔴 🟠 🟡 🟢 🔵 🟣 ⚫ ⚪ 🟤 🔺 🔻 🔸 🔹 🔶 🔷 🔳 🔲 ▪ ▫ ⬛ ⬜ 🏁 🚩 🎌 🏴 🏳"
		),
	},
}

return Emoji
