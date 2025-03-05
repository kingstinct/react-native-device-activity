import React from "react";
import { PaperProvider, BottomNavigation } from "react-native-paper";

import { AllTheThings } from "./screens/AllTheThings";
import { EventsTab } from "./screens/Events";
import { Settings } from "./screens/Settings";
import { ShieldTab } from "./screens/ShieldTab";
import { SimpleTab } from "./screens/SimpleTab";

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
    { key: "shield", title: "Shield", focusedIcon: "history" },
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
    shield: ShieldTab,
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
