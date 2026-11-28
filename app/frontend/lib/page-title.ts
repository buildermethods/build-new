// Every page title ends with the brand: "Quest Board · Nest Quest". Titles that
// already carry the name (the landing page) are left alone.
export function pageTitle(title: string): string {
  if (!title) return "Nest Quest"
  return title.includes("Nest Quest") ? title : `${title} · Nest Quest`
}
