using JetBrains.Annotations;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

[System.Serializable]
public class EssentialsTable {// ISerializationCallbackReceiver {

    public int SizeX;
    public int SizeY;
    public int SizeZ;

    int[][] values;
    [SerializeField] public string[] s_values;

    public EssentialsTable(int z, int y, int x) {
        SizeX = x; SizeY = y; SizeZ = z;
        values = new int[SizeY*SizeZ][];
        for (int i = 0; i < SizeY*SizeZ; i++) {
            values[i] = new int[z];
        }
    }

    public int Get(int z, int y, int x) {
        return values[z*y+y][x];
    }

    public void OnBeforeSerialize() {
        Debug.Log("Beginning serialize");
        s_values = new string[SizeY * SizeZ];
        for (int i = 0; i < SizeY * SizeZ; i++) {
            s_values[i] = string.Join(" ", Array.ConvertAll(values[i], n => n.ToString()));
        }
    }

    // Assumes SizeX, SizeY and SizeZ already describe the dimensions of s_values. These values should not be changed in the inspector.
    public void OnAfterDeserialize() {
        Debug.Log("Beginning deserialize");
        values = new int[SizeY * SizeZ][];
        for (int i = 0; i < SizeY * SizeZ; i++) {
            values[i] = Array.ConvertAll(s_values[i].Split(" "), int.Parse);
        }

    }

}