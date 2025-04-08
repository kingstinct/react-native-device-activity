import React from "react";
import { PaperProvider, BottomNavigation } from "react-native-paper";

import { AllTheThings } from "./screens/AllTheThings";
import { EventsTab } from "./screens/Events";
import { SetOpsTab } from "./screens/SetOps";
import { Settings } from "./screens/Settings";
import { SimpleTab } from "./screens/SimpleTab";
import { WhiteListTab } from "./screens/WhiteList";

export default function App() {
  const [index, setIndex] = React.useState(0);
  const [routes] = React.useState([
    {
      key: "activities",
      title: "Activities",
      focusedIcon: "heart",
      unfocusedIcon: "heart-outline",
    },
    { key: "events", title: "Events", focusedIcon: "album" },
    { key: "all", title: "All", focusedIcon: "album" },
    { key: "shield", title: "Set ops", focusedIcon: "history" },
    { key: "whitelist", title: "Whitelist", focusedIcon: "history" },
    {
      key: "settings",
      title: "Settings",
      focusedIcon: "bell",
      unfocusedIcon: "bell-outline",
    },
  ]);

  const renderScene = BottomNavigation.SceneMap({
    activities: SimpleTab,
    events: EventsTab,
    all: AllTheThings,
    shield: SetOpsTab,
    whitelist: WhiteListTab,
    settings: Settings,
  });

  return (
    <PaperProvider>
      <BottomNavigation
        navigationState={{ index, routes }}
        onIndexChange={setIndex}
        renderScene={renderScene}
      />
    </PaperProvider>
  );
}
