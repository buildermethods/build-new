import { SectionShell } from "@/components/design-system/SectionShell"
import { Logo, LogoMark, TAGLINE } from "@/components/Logo"

const code = `<Logo size="md" />                    // sidebar and headers
<Logo size="xl" />                    // landing hero
<Logo size="lg" stacked tagline />    // sign in and welcome screens
<Logo size="md" iconOnly />           // collapsed sidebar`

export function LogoSection() {
  return (
    <SectionShell
      id="logo"
      title="Logo"
      description={
        <>
          The Nest Quest mascot (a cheeky chick in an explorer cap, peeking out of a nest) with a chunky, rounded
          two-tone wordmark in the brand font. The tagline is always <strong>{TAGLINE}</strong>. The mark uses fixed
          brand colours so it looks the same in every theme.
        </>
      }
      whenToUse={
        <ul>
          <li>Large on the landing page and sign-in screens, medium in the sidebar, small on setup and footers.</li>
          <li>Mark only where space is tight (a collapsed sidebar, the app icon); the name stays available to screen readers.</li>
        </ul>
      }
      whenNotToUse={
        <ul>
          <li>Recolouring or stretching the mark, or retyping the wordmark in another font.</li>
        </ul>
      }
      preview={
        <div className="flex flex-wrap items-center gap-10">
          <Logo size="xl" />
          <Logo size="lg" stacked tagline />
          <Logo size="md" />
          <Logo size="sm" />
          <LogoMark className="h-10 w-10" />
        </div>
      }
      code={code}
    />
  )
}
