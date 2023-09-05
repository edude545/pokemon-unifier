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

    private int activeSprites;
    private Sprite[] sprites;
    private SpriteRenderer spriteRenderer;
    public bool Playing = true;
    //private bool playingOnce = false;

    public float Speed = 20f;

    public int[] FrameSequence;
    private int frameIndex = 0;
    private int animationLength;
    private float timeOnCurrentFrame = 0f;
    private int frameToEndOn = -1;

    protected virtual void Start() {
        spriteRenderer = GetComponent<SpriteRenderer>();
        LoadSprites();
    }

    private void Update() {
        if (Playing) {
            timeOnCurrentFrame += Time.deltaTime;
            if (timeOnCurrentFrame >= Speed) {
                timeOnCurrentFrame = 0f;
                nextFrame();
            }
        }
    }

    public void UpdateSprite() {
        spriteRenderer.sprite = sprites[FrameSequence[frameIndex]];
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

    public void LoadAnimation(int[] seq) {
        FrameSequence = seq;
        animationLength = FrameSequence.Length;
    }

    protected void nextFrame() {
        if (frameToEndOn >= 0) {
            frameIndex = 0;
            frameToEndOn = -1;
            Stop();
        } else {
            frameIndex++;
            if (frameIndex == animationLength) {
                frameIndex = 0;
            }
        }
        UpdateSprite();
    }

    public void Play() {
        Playing = true;
    }

    public void Stop() {
        Playing = false;
        timeOnCurrentFrame = 0f;
    }

    public void DelayedStop(int frame) {
        frameToEndOn = frame;
    }

}
