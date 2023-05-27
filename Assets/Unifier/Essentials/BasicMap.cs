using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Tilemaps;

public class BasicMap : MonoBehaviour
{

    public static BasicMap Instance;

    public Tilemap[] Layers;

    public GameObject TilemapPrefab;

    private void deleteLayers() {
        int count = transform.childCount;
        for (int i = 0; i < count; i++) {
            DestroyImmediate(transform.GetChild(0).gameObject);
        }
    }

    public void MakeTilemaps(int width, int height, int layers) {
        deleteLayers();
        Layers = new Tilemap[layers];
        for (int z = 0; z < layers; z++) {
            Layers[z] = Instantiate(TilemapPrefab, transform).GetComponent<Tilemap>();
            Layers[z].transform.position = new Vector3(0f,0f,layers-z);
        }
    }

    private void OnValidate() {
        Instance = this;
    }

    private void OnDestroy() {
        Instance = null;
    }

}
