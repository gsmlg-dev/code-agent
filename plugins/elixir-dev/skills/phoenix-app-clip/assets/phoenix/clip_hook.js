// The mount + data-bridge hook — the core of this skill.
// Place at assets/js/clips/__name__.js, then register Mount__Name__ in
// assets/js/hooks.js. Replace:
//   @your-scope / your-package   where your React component lives
//   __name__  slug   __Name__  PascalCase
//
// Uses only the standard LiveView hook API: this.el, this.root (ours),
// this.pushEvent, this.handleEvent. No extra packages.
import * as React from 'react';
import { createRoot } from 'react-dom/client';
import { YourComponent } from '@your-scope/your-package';

export const Mount__Name__ = {
  Mount__Name__: {
    mounted() {
      this.root = createRoot(this.el); // set before any await so destroyed() can unmount

      // Phoenix -> React (initial): read data-* attributes set on the node.
      // `data-props` holds JSON; `data-token` a plain string.
      this.props = JSON.parse(this.el.dataset.props || '{}');
      this.token = this.el.dataset.token;

      // Phoenix -> React (live updates): server push_event re-renders with new props.
      this.handleEvent('clip:update', (payload) => {
        this.props = { ...this.props, ...payload };
        this.render();
      });

      this.render();
    },

    destroyed() {
      this.root?.unmount(); // mandatory — LiveView navigations call destroyed()
    },

    // React -> Phoenix: the functions React calls to talk back to the server.
    bridge() {
      return {
        token: this.token,
        pushEvent: (event, payload, onReply) => this.pushEvent(event, payload, onReply),
        // Navigation goes through the server (public API): the LiveView replies
        // with push_navigate/push_patch. Avoids reaching into LiveView internals.
        navigate: (path) => this.pushEvent('navigate', { to: path }),
      };
    },

    render() {
      this.root.render(<YourComponent {...this.props} bridge={this.bridge()} />);
    },
  },
};
