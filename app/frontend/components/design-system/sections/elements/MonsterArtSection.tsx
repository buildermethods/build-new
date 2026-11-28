import { SectionShell } from "@/components/design-system/SectionShell"
import { MonsterArt } from "@/components/ui/monster-art"

const monsters = [
  ["laundry_troll", "Laundry Troll"], ["dust_bunny_horde", "Dust Bunny Horde"], ["counter_goblins", "Counter Goblins"],
  ["bathroom_slime", "Bathroom Slime"], ["doom_pile_dragon", "Doom Pile Dragon"], ["toy_swarm", "Toy Swarm"],
  ["backpack_bandits", "Backpack Bandits"], ["wardrobe_wraith", "Wardrobe Wraith"],
]

const code = `<MonsterArt monster="counter_goblins" className="h-20 w-20" />
<MonsterArt monster="counter_goblins" mood="sleepy" />  // after a defeat
// Decorative by default; pass label="Counter Goblins" if it stands alone.`

export function MonsterArtSection() {
  return (
    <SectionShell
      id="monster-art"
      title="Monster art"
      description={<>A charming, never-scary illustration for each chore monster, coloured with design tokens. Each has a happy pose and a sleepy one for after a defeat. The keys match the monster catalogue.</>}
      whenToUse={
        <ul>
          <li>Quest cards, the one-thing card, focus mode and victory.</li>
        </ul>
      }
      whenNotToUse={
        <ul>
          <li>As the only indication of a task; the plain-language chore is always shown too.</li>
        </ul>
      }
      preview={
        <div className="space-y-6">
          <ul className="grid list-none grid-cols-2 gap-4 p-0 sm:grid-cols-4">
            {monsters.map(([key, name]) => (
              <li key={key} className="flex flex-col items-center gap-1">
                <MonsterArt monster={key} className="h-24 w-24" />
                <span className="text-xs text-ink-muted">{name}</span>
              </li>
            ))}
          </ul>
          <p className="caption">Sleepy mood (shown after a monster is defeated):</p>
          <ul className="grid list-none grid-cols-2 gap-4 p-0 sm:grid-cols-4">
            {monsters.map(([key, name]) => (
              <li key={key} className="flex flex-col items-center gap-1">
                <MonsterArt monster={key} mood="sleepy" className="h-24 w-24" />
                <span className="text-xs text-ink-muted">{name}</span>
              </li>
            ))}
          </ul>
        </div>
      }
      code={code}
    />
  )
}
