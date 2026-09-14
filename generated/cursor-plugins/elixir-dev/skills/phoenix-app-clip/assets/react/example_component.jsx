// EXAMPLE ONLY — replace with your own component. The skill does not dictate what
// the React element is or which libraries it uses. This stub exists only to show
// the two things a mounted component interacts with:
//   1. props  — data Phoenix sent (initial data-* and live push_event updates)
//   2. bridge — functions to talk back to Phoenix (pushEvent, navigate) + token
//
// Here the bridge arrives as a prop. If you prefer context, wrap the tree in
// <BridgeProvider value={bridge}> in the hook and read it with useBridge().
import * as React from 'react';

export const ExampleComponent = ({ title, count, bridge }) => {
  return (
    <div>
      <h2>{title}</h2>
      {/* `count` re-renders when the server pushes "clip:update" (see the hook) */}
      <p>Count from server: {count}</p>

      {/* React -> Phoenix: lands in handle_event("increment", ...) */}
      <button onClick={() => bridge.pushEvent('increment', { by: 1 })}>+1</button>

      {/* React -> Phoenix: with a reply callback */}
      <button
        onClick={() =>
          bridge.pushEvent('save', { title }, (reply) => {
            if (reply?.ok) console.log('saved');
          })
        }
      >
        Save
      </button>

      {/* React -> Phoenix: navigate the host */}
      <button onClick={() => bridge.navigate('/somewhere')}>Go</button>
    </div>
  );
};
