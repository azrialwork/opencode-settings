import type { Plugin } from "@opencode-ai/plugin"

export default (async () => {
  return {
    "experimental.chat.system.transform": async (_input, output) => {
      const joined = output.system.join("\n\n")

      const segments = joined.split(/(?=Instructions from:)/)

      const cleanSegments = segments
        .slice(1)
        .map((seg) => seg.replace(/^Instructions from: [^\n]*\n/, "").trim())
        .filter(Boolean)

      if (cleanSegments.length === 0) return

      output.system.splice(0, output.system.length, cleanSegments.join("\n\n"))
    },
  }
}) satisfies Plugin