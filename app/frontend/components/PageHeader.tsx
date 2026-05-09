import * as React from "react"

type PageHeaderProps = {
  title: React.ReactNode
  description?: React.ReactNode
  actions?: React.ReactNode
  tabs?: React.ReactNode
}

export function PageHeader({ title, description, actions, tabs }: PageHeaderProps) {
  return (
    <div>
      <div className="flex flex-col gap-4 border-b border-hairline pb-6 sm:flex-row sm:items-start sm:justify-between">
        <div>
          <h1>{title}</h1>
          {description && <p className="mt-1">{description}</p>}
        </div>
        {actions && <div className="flex items-center gap-2">{actions}</div>}
      </div>
      {tabs}
    </div>
  )
}
