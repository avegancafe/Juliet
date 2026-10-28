import type { Register } from 'claude-code'

import { keepFresh, translateNative } from './native'
import { renderPane } from './render'
import { PANE, hydrate } from './state'
import { registerTools, serveTools } from './tools'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await hydrate($)
    await registerTools($)
    // A refused command must not cost the tools and the pane registered beside it.
    await $.command.register({ name: 'task-graph', description: 'Open the shared task graph' }).catch(() => undefined)
    void $.ui.open({ id: PANE, title: 'Tasks' })

    return next(e)
  })

  on('command.run', { command: 'task-graph' }, async $ => {
    const opened = await $.ui.open({ id: PANE, title: 'Tasks', focus: true })

    return { text: opened.isPlaced ? 'Task graph opened.' : `Task graph waiting for room: ${opened.reason}` }
  })

  serveTools(on)
  translateNative(on)
  keepFresh(on)
  renderPane(on)
}
