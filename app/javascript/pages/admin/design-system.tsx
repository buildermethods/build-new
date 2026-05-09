import { Head } from "@inertiajs/react";
import { DesignSystem } from "@/components/design-system/DesignSystem";

export default function AdminDesignSystem() {
  return (
    <>
      <Head title="Design system">
        <meta
          name="description"
          content="Internal reference for every visual primitive in this app — colors, typography, structure, base styles, and elements."
        />
        <meta property="og:title" content="Design system" />
        <meta
          property="og:description"
          content="Internal reference for every visual primitive in this app — colors, typography, structure, base styles, and elements."
        />
      </Head>
      <DesignSystem />
    </>
  );
}
