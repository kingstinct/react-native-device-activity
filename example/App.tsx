import React from "react";
import { PaperProvider, BottomNavigation } from "react-native-paper";

import { AllTheThings } from "./screens/AllTheThings";
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
    { key: "shield", title: "Shield", focusedIcon: "history" },
    {
      key: "notifications",
      title: "Notifications",
      focusedIcon: "bell",
      unfocusedIcon: "bell-outline",
    },
  ]);

  const renderScene = BottomNavigation.SceneMap({
    activities: SimpleTab,
    events: AllTheThings,
    shield: ShieldTab,
    notifications: AllTheThings,
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
