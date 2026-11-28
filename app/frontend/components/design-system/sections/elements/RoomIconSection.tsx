import { SectionShell } from "@/components/design-system/SectionShell"
import { RoomIcon } from "@/components/ui/room-icon"

const rooms = ["kitchen", "living_room", "dining_room", "bedroom", "bathroom", "hallway", "kids_room", "utility", "office", "garden", "home"]

const code = `<RoomIcon room="kitchen" />
<RoomIcon room="bedroom" className="h-16 w-16" />
// Decorative by default; pass label="Kitchen" if it stands alone.`

export function RoomIconSection() {
  return (
    <SectionShell
      id="room-icon"
      title="Room icon"
      description={<>A small illustrated glyph per room, drawn with design tokens so it follows light and dark mode. Always shown beside the room name, so it is hidden from screen readers unless a label is given.</>}
      whenToUse={
        <ul>
          <li>Setup steps, chore lists and anywhere a room is the heading.</li>
        </ul>
      }
      whenNotToUse={
        <ul>
          <li>As the only way to tell rooms apart; always include the name.</li>
        </ul>
      }
      preview={
        <ul className="grid list-none grid-cols-5 gap-4 p-0">
          {rooms.map((room) => (
            <li key={room} className="flex flex-col items-center gap-1">
              <RoomIcon room={room} className="h-14 w-14" />
              <span className="text-xs text-ink-muted">{room.replace("_", " ")}</span>
            </li>
          ))}
        </ul>
      }
      code={code}
    />
  )
}
