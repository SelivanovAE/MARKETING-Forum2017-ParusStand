/******************************************************************************
 *
 * Результат отгрузки
 *
 *****************************************************************************/

import React from "react";
import { TouchableOpacity, Text, View, StyleSheet } from "react-native";
const styles = StyleSheet.create({
    resultContainer: {
        marginHorizontal: 50,
        alignItems: "center",
        backgroundColor: "transparent"
    },
    resultText: {
        lineHeight: 38,
        fontSize: 34,
        marginVertical: 10,
        color: "white",
        backgroundColor: "transparent"
    },
    button: {
        width: 400,
        height: 70,
        borderWidth: 0.5,
        borderColor: "#FFF",
        marginTop: 50,
        justifyContent: "center"
    },
    buttonText: {
        fontSize: 22,
        alignSelf: "center",
        backgroundColor: "transparent",
        color: "#FFF"
    }
});

export const ShipmentResult = props => (
    <View style={styles.resultContainer}>
        <Text style={styles.resultText}>{props.resultText}</Text>
        <TouchableOpacity onPress={props.onPress} style={styles.button}>
            <Text style={styles.buttonText}>ОК</Text>
        </TouchableOpacity>
    </View>
);
