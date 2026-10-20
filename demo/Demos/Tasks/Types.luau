--!strict
export type Todo = {
	id: number,
	title: string,
	notes: string,
	done: boolean,
	project: string, -- "" is the inbox
	due: string, -- "YYYY-MM-DD", or "" for no date
	tags: { string },
	order: number?, -- set on the copies that the list shows
}

export type Project = { Id: string, Icon: string }
export type Tag = { Id: string, Label: string }

return {}
