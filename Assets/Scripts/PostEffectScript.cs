using System.Collections;
using UnityEngine;

[ExecuteInEditMode]
public class PostEffectScript : MonoBehaviour 
{
    public Material mat;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // src is the fully rendered scene that you would normally
        // send directly to the monitor. we are intercepting 
        // this so we can do a bit more work, before passing it on

        //Debug.Log("ASDASd");

        Graphics.Blit(src, dest, mat);
    }
}
