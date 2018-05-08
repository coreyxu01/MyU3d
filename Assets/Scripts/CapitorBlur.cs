using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class CapitorBlur : PostEffectBase
{

    public Camera camera;
    public RawImage image;

	// Use this for initialization
	void Start () {
        StartCoroutine(CaptureCamera());
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    private IEnumerator CaptureCamera()
    {
        Rect rect = new Rect(0, 0, 1280, 720);
        // 创建一个RenderTexture对象
        RenderTexture rt = new RenderTexture(1280, 720, 24);

        // 临时设置相关相机的targetTexture为rt, 并手动渲染相关相机
        camera.targetTexture = rt;
        camera.Render();
        yield return null;

        // 激活这个rt, 并从中中读取像素。
        RenderTexture.active = rt;
        OnRenderImage1(rt);

        Texture2D screenShot = new Texture2D((int)rect.width, (int)rect.height, TextureFormat.RGB24, false);
        screenShot.ReadPixels(rect, 0, 0);// 注：这个时候，它是从RenderTexture.active中读取像素
        screenShot.Apply();

        // 重置相关参数，以使用camera继续在屏幕上显示
        camera.targetTexture = null;
        RenderTexture.active = null; // JC: added to avoid errors
        GameObject.Destroy(rt);

        image.texture = screenShot;
    }

    //模糊半径  
    public float BlurRadius = 1.0f;
    //降分辨率  
    public int downSample = 2;
    //迭代次数  
    public int iteration = 1;
    void OnRenderImage1(RenderTexture source)
    {
        if (_Material)
        {
            //申请RenderTexture，RT的分辨率按照downSample降低  
            RenderTexture rt1 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);
            RenderTexture rt2 = RenderTexture.GetTemporary(source.width >> downSample, source.height >> downSample, 0, source.format);

            //直接将原图拷贝到降分辨率的RT上  
            Graphics.Blit(source, rt1);

            //进行迭代高斯模糊  
            for (int i = 0; i < iteration; i++)
            {
                //第一次高斯模糊，设置offsets，竖向模糊  
                _Material.SetVector("_offsets", new Vector4(0, BlurRadius, 0, 0));
                Graphics.Blit(rt1, rt2, _Material);
                //第二次高斯模糊，设置offsets，横向模糊  
                _Material.SetVector("_offsets", new Vector4(BlurRadius, 0, 0, 0));
                Graphics.Blit(rt2, rt1, _Material);
            }

            //将结果输出  
            Graphics.Blit(rt1, source);

            //释放申请的两块RenderBuffer内容  
            RenderTexture.ReleaseTemporary(rt1);
            RenderTexture.ReleaseTemporary(rt2);
        }
    }
}
