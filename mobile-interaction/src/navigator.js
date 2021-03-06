/******************************************************************************
 *
 * Настройки навигации приложения
 *
 *   ARRRRRRRRRRRRRRRRRRRRRR!
 *
 *
 *              |    |    |
 *             )_)  )_)  )_)
 *            )___))___))___)
 *           )____)____)_____)\
 *         _____|____|____|____\\\__
 *---------\                   /---------
 *  ^^^^^ ^^^^^^^^^^^^^^^^^^^^^
 *    ^^^^      ^^^^     ^^^    ^^
 *         ^^^^      ^^^
 *****************************************************************************/

import React from "react";
import { StackNavigator } from "react-navigation";
import ScanerPage from "./ScanerPage";
import SettingsPage from "./SettingsPage";
import ShipmentPage from "./ShipmentPage";

const FlowNivigator = StackNavigator(
    {
        First: { screen: ScanerPage },
        Second: { screen: ShipmentPage }
    },
    {
        headerMode: "none",
        initialRouteName: "First"
        //mode: "modal"
    }
);
const AppNavigator = StackNavigator(
    {
        Flow: { screen: FlowNivigator },
        Settings: { screen: SettingsPage }
    },
    {
        initialRouteName: "Flow",
        headerMode: "float"
    }
);

export default AppNavigator;
