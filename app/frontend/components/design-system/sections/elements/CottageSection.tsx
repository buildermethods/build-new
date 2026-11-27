import { SectionShell } from "@/components/design-system/SectionShell"
import { Cottage } from "@/components/sanctuary/Cottage"

const code = `<Cottage
  placements={{ rug: "woven_rug", plant: "fern_pot", lamp: "table_lamp", wall: "meadow_frame" }}
  names={{ woven_rug: "Woven Rug" }}
/>`

export function CottageSection() {
  return (
    <SectionShell
      id="cottage"
      title="Cottage"
      description={
        <>
          The sanctuary illustration: one room with four fixed slots (rug, plant, lamp, wall). It is an inline SVG
          coloured with design tokens, and exposes a text description of what is equipped to screen readers.
        </>
      }
      whenToUse={
        <ul>
          <li>The sanctuary page and the dashboard cottage preview.</li>
        </ul>
      }
      whenNotToUse={
        <ul>
          <li>Free-form decorating; the room only supports fixed slots.</li>
        </ul>
      }
      preview={
        <div className="max-w-md">
          <Cottage
            placements={{ rug: "woven_rug", plant: "fern_pot", lamp: "table_lamp", wall: "meadow_frame" }}
            names={{ woven_rug: "Woven Rug", fern_pot: "Fern in a Pot", table_lamp: "Cosy Table Lamp", meadow_frame: "Framed Meadow" }}
          />
        </div>
      }
      code={code}
    />
  )
}
