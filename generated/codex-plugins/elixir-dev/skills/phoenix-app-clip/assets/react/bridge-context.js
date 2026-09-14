// OPTIONAL React context so deeply-nested components can read the host bridge
// (token / pushEvent / navigate) without prop-drilling. The hook provides the
// value; components read it via useBridge(). Zero dependencies beyond React.
//
// If your component is shallow, skip this and just pass `bridge` as a prop.
import * as React from 'react';

const BridgeContext = React.createContext({
  token: null,
  pushEvent: () => {}, // (event, payload, onReply) => to LiveView handle_event/3
  navigate: () => {}, // (path) => LiveView navigation
});

export const BridgeProvider = BridgeContext.Provider;
export const useBridge = () => React.useContext(BridgeContext);
