using Assets.Unifier.Game;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.UI;

[RequireComponent(typeof(SpriteRenderer))]
public abstract class SpriteAnimator : MonoBehaviour
{

    public string SpritesheetName; // e.g. "Assets/Insurgence/Graphics/Characters/64px/trchar001"

    private int activeSprites;
    private Sprite[] sprites;
    private SpriteRenderer spriteRenderer;
    public bool Playing = true;
    //private bool playingOnce = false;

    public float Speed = 20f;

    private int[] animationData;
    private int animationFrame = 0;
    private int animationLength;
    private float frameTime = 0f;

    private void Start() {
        spriteRenderer = GetComponent<SpriteRenderer>();
        LoadSprites();
    }

    private void Update() {
        if (Playing) {
            frameTime += Time.deltaTime;
            if (frameTime >= Speed) {
                frameTime = 0f;
                nextFrame();
            }
        }
    }

    private void OnValidate() {
        spriteRenderer = GetComponent<SpriteRenderer>();
    }

    public void SwitchSpritesheet(Sprite[] newSprites) {
        sprites = newSprites;
        UpdateSprite();
    }

    protected void setSpritesheetWithoutUpdating(Sprite[] newSprites) {
        sprites = newSprites;
    }

    public abstract void LoadSprites();
    
    public void LoadAnimation(int[] anim) {
        animationData = anim;
        animationLength = animationData.Length;
    }

    public void UpdateSprite() {
        setFrame(animationFrame);
    }

    protected void nextFrame() {
        animationFrame++;
        if (animationFrame == animationLength) {
/*            if (playingOnce) {
                Stop();
            }*/
            animationFrame = 0;
        }
        UpdateSprite();
    }

    public void setFrame(int index) {
        //Debug.Log(transform.parent.name+":\nsprites.length: "+sprites.Length+"\nanimationData.Length: "+animationData.Length+"\nindex: "+index+"\nspriteRenderer: "+spriteRenderer+"\nsprites[animationData[index]]: "+sprites[animationData[index]]);
        spriteRenderer.sprite = sprites[animationData[index]];
    }

    public void FreezeFrame(int index) {
        setFrame(index);
        Stop();
    }

    public void Play() {
        Playing = true;// playingOnce = false;
    }

    /*public void PlayOnce() {
        if (!Playing) {
            animationFrame = 0;
            Playing = true; playingOnce = true;
        }
    }*/

    public void Stop() {
        Playing = false;// playingOnce = false;
    }

}
