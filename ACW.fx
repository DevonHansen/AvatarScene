//**************************************************************//
//  Effect File exported by RenderMonkey 1.6
//
//  - Although many improvements were made to RenderMonkey FX  
//    file export, there are still situations that may cause   
//    compilation problems once the file is exported, such as  
//    occasional naming conflicts for methods, since FX format 
//    does not support any notions of name spaces. You need to 
//    try to create workspaces in such a way as to minimize    
//    potential naming conflicts on export.                    
//    
//  - Note that to minimize resulting name collisions in the FX 
//    file, RenderMonkey will mangle names for passes, shaders  
//    and function names as necessary to reduce name conflicts. 
//**************************************************************//

//--------------------------------------------------------------//
// ACW
//--------------------------------------------------------------//
//--------------------------------------------------------------//
// ACW
//--------------------------------------------------------------//
//--------------------------------------------------------------//
// Environment
//--------------------------------------------------------------//
string ACW_ACW_Environment_Sphere : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\Sphere.3ds";

float4x4 matViewProjection : ViewProjection;
float4 vViewPosition : ViewPosition;

struct VS_INPUT 
{
   float4 Position : POSITION0;
   
};

struct VS_OUTPUT 
{
   float4 Position : POSITION0;
   float3 ViewDir : TEXCOORD0;
};

VS_OUTPUT ACW_ACW_Environment_Vertex_Shader_vs_main( VS_INPUT Input )
{
   VS_OUTPUT Output;

   float4 inPos = Input.Position;
   inPos.xyz += vViewPosition.xyz;
   
   Output.Position = mul(inPos,matViewProjection);
   Output.ViewDir = Input.Position.xyz;
   
   return( Output );
   
}




texture skyBox_Tex
<
   string ResourceName = "F:\\RenderMonkey ACW\\Textures\\CubeMap.dds";
>;
samplerCUBE skyBox = sampler_state
{
   Texture = (skyBox_Tex);
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
};

float4 ACW_ACW_Environment_Pixel_Shader_ps_main(float3 ViewDir : TEXCOORD0) : COLOR0
{   
   return(texCUBE(skyBox, ViewDir));
}




//--------------------------------------------------------------//
// Terrain
//--------------------------------------------------------------//
string ACW_ACW_Terrain_Plane : ModelData = "F:\\RenderMonkey ACW\\Models_v_2\\Plane.3ds";

float4x4 ACW_ACW_Terrain_Vertex_Shader_matViewProjection : ViewProjection;
float4x4 matWorld : World;

float4 ACW_ACW_Terrain_Vertex_Shader_vViewPosition : ViewPosition;
float3 lightDirection
<
   string UIName = "lightDirection";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 1.00, 1.00, 0.00 );

texture HeightMap_Tex
<
   string ResourceName = "F:\\RenderMonkey ACW\\Textures_v_2\\heightmap.dds";
>;
sampler MountainsDM = sampler_state
{
   Texture = (HeightMap_Tex);
   MAGFILTER = LINEAR;
   ADDRESSV = BORDER;
   ADDRESSU = BORDER;
   MINFILTER = LINEAR;
   ADDRESSW = BORDER;
   BORDERCOLOR = 0x0;
   MIPFILTER = LINEAR;
};
float MountainScale
<
   string UIName = "MountainScale";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 205.69 );

struct ACW_ACW_Terrain_Vertex_Shader_VS_INPUT 
{
   float4 Position : POSITION0;
   float3 Normal : NORMAL;
   float2 TexCoord : TEXCOORD0;
   float3 Tangent : TANGENT;
};

struct ACW_ACW_Terrain_Vertex_Shader_VS_OUTPUT 
{
   float4 Position : POSITION0;
   float2 TexCoord : TEXCOORD0;
   float2 TextureWeights : TEXCOORD1;
   float3 Light : TEXCOORD2;
   float3 View : TEXCOORD3;
   float3 TanLight : TEXCOORD4;
   float3 TanView : TEXCOORD5;
};

float texSize = 256.0f;
float texelSize = 1.0f/256.0f;

float4 tex2Dlod_bilinear(sampler tex, float4 uv)
{
   float4 height00 = tex2Dlod(tex, uv);
   float4 height10 = tex2Dlod(tex, uv +float4(texelSize,0,0,0));
   float4 height01 = tex2Dlod(tex, uv + float4(0,texelSize,0,0));
   float4 height11 = tex2Dlod(tex, uv + float4(texelSize, texelSize,0,0));
   
   float2 f = frac(uv.xy * texSize);
   
   float4 tA = lerp(height00, height10, f.x);
   float4 tB = lerp(height01, height11, f.x);
   
   return lerp(tA, tB, f.y);
}

ACW_ACW_Terrain_Vertex_Shader_VS_OUTPUT ACW_ACW_Terrain_Vertex_Shader_vs_main( ACW_ACW_Terrain_Vertex_Shader_VS_INPUT Input )
{
   ACW_ACW_Terrain_Vertex_Shader_VS_OUTPUT Output;

   // Work out world-to-tangent space
   float3x3 worldToTangent;
   worldToTangent[0] = mul(Input.Tangent, matWorld);
   worldToTangent[1] = mul(cross(Input.Tangent, Input.Normal), matWorld);
   worldToTangent[2] = mul(Input.Normal, matWorld);

   float4 Position = Input.Position;
   
   float Height = tex2Dlod_bilinear(MountainsDM, float4(Input.TexCoord.xy, 0,0)).x;

   Position.y = Height * MountainScale;

   float2 TexWeights;
   TexWeights.x = saturate(1.0f - abs(Height - 0) / 0.5f);
   TexWeights.y = saturate(1.0f - abs(Height - 0.4f) / 0.75f);
   
   float totalWeight = TexWeights.x + TexWeights.y;
   
   TexWeights /= totalWeight;
   
   Output.TextureWeights = TexWeights;

   Output.Position = mul( Position, ACW_ACW_Terrain_Vertex_Shader_matViewProjection );
   Output.TexCoord = Input.TexCoord;
   
   Output.View = ACW_ACW_Terrain_Vertex_Shader_vViewPosition - (mul(Input.Position, matWorld));
   Output.Light = lightDirection;
   Output.Light.x = -Output.Light.x;
   
   
   Output.TanView = mul(worldToTangent,ACW_ACW_Terrain_Vertex_Shader_vViewPosition - (mul(Input.Position, matWorld)));
   Output.TanLight = mul(worldToTangent, lightDirection);
   
   return( Output );
   
}




texture Rock_Tex
<
   string ResourceName = "F:\\RenderMonkey ACW\\Textures_v_2\\rock.jpg";
>;
sampler2D Rock = sampler_state
{
   Texture = (Rock_Tex);
   ADDRESSU = WRAP;
   ADDRESSV = WRAP;
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};
texture Grass_Tex
<
   string ResourceName = "F:\\RenderMonkey ACW\\Textures_v_2\\grass.jpg";
>;
sampler2D Grass = sampler_state
{
   Texture = (Grass_Tex);
   ADDRESSU = WRAP;
   ADDRESSV = WRAP;
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};
texture RockBM_Tex
<
   string ResourceName = "F:\\RenderMonkey ACW\\Textures_v_2\\rockBM.jpg";
>;
sampler2D RockBM = sampler_state
{
   Texture = (RockBM_Tex);
};
sampler2D MountainsHM = sampler_state
{
   Texture = (HeightMap_Tex);
};

float ambIntensity
<
   string UIName = "ambIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = 0.00;
   float UIMax = 1.00;
> = float( 0.73 );
float difIntensity
<
   string UIName = "difIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 1.21 );
float specIntensity
<
   string UIName = "specIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.24 );

float normalStrength
<
   string UIName = "normalStrength";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 5.00 );

struct PS_INPUT
{
   float2 TexCoord : TEXCOORD0;
   float2 TextureWeights : TEXCOORD1;
   float3 Light : TEXCOORD2;
   float3 View : TEXCOORD3;
   float3 TanLight : TEXCOORD4;
   float3 TanView : TEXCOORD5;
};

float ACW_ACW_Terrain_Pixel_Shader_texSize = 256.0f;
float ACW_ACW_Terrain_Pixel_Shader_texelSize = 1.0f/256.0f;

float3 GenerateNormals(float2 uv)
{
   // Calculate normals using Sobel Filter
   float tl = abs(tex2D (MountainsHM, uv + ACW_ACW_Terrain_Pixel_Shader_texelSize * float2(-1, -1)).x);   // top left
   float  l = abs(tex2D (MountainsHM, uv + ACW_ACW_Terrain_Pixel_Shader_texelSize * float2(-1,  0)).x);   // left
   float bl = abs(tex2D (MountainsHM, uv + ACW_ACW_Terrain_Pixel_Shader_texelSize * float2(-1,  1)).x);   // bottom left
   float  t = abs(tex2D (MountainsHM, uv + ACW_ACW_Terrain_Pixel_Shader_texelSize * float2( 0, -1)).x);   // top
   float  b = abs(tex2D (MountainsHM, uv + ACW_ACW_Terrain_Pixel_Shader_texelSize * float2( 0,  1)).x);   // bottom
   float tr = abs(tex2D (MountainsHM, uv + ACW_ACW_Terrain_Pixel_Shader_texelSize * float2( 1, -1)).x);   // top right
   float  r = abs(tex2D (MountainsHM, uv + ACW_ACW_Terrain_Pixel_Shader_texelSize * float2( 1,  0)).x);   // right
   float br = abs(tex2D (MountainsHM, uv + ACW_ACW_Terrain_Pixel_Shader_texelSize * float2( 1,  1)).x);   // bottom right

   float dX = tr + 2*r + br -tl - 2*l - bl;
   float dY = bl + 2*b + br -tl - 2*t - tr;
   
   return normalize(float3(dX, 1.0f / normalStrength, dY));
}

float4 GrassColour(PS_INPUT Input, sampler2D texSampler)
{
   // ambient is the base texture multiplied by the intensity
   float4 col = tex2D(texSampler,Input.TexCoord*30);
   float4 amb = ambIntensity * col;
   
   float3 Normal = GenerateNormals(Input.TexCoord.xy);
   float3 lightDir = normalize(Input.Light);
   float3 view = Input.View;
   
   float dif = saturate(dot(normalize(Normal),normalize(lightDir)));
   float3 reflection = normalize(2*normalize(Normal) - normalize(lightDir));   
   float4 specular = float4(1,1,1,1) * specIntensity * pow(saturate(dot(reflection, normalize(view))), 8);
 
  
   return (amb + (dif*col*difIntensity) + (specular*dif));
}

float4 RockColour(PS_INPUT Input, sampler2D base, sampler2D bump)
{
   float4 col = tex2D(base, Input.TexCoord*10);
   float4 amb = ambIntensity * col;
   
   float3 Normal = normalize(GenerateNormals(Input.TexCoord.xy) +((2*(tex2D(bump, Input.TexCoord*10))) - 1.0));
   float3 lightDir = Input.TanLight;
   float3 view = Input.TanView;
   
   float dif = saturate(dot(normalize(Normal), normalize(lightDir)));
   float3 reflection = normalize(2*normalize(Normal)-normalize(lightDir));
   float4 specular = float4(1,1,1,1) * specIntensity * pow(saturate(dot(reflection, normalize(view))), 8);
   
   return (amb + (dif*col*difIntensity) + (specular*dif));
}

float4 ACW_ACW_Terrain_Pixel_Shader_ps_main(PS_INPUT Input) : COLOR0
{   
   // Calculating grass colour   
   float4 grass = GrassColour(Input, Grass);
   float4 rock = RockColour(Input, Rock, RockBM);

   return((grass * Input.TextureWeights.x) + (rock * Input.TextureWeights.y));
}




//--------------------------------------------------------------//
// ShinyJet
//--------------------------------------------------------------//
string ACW_ACW_ShinyJet_Teapot : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\Teapot.3ds";

float4x4 ACW_ACW_ShinyJet_Vertex_Shader_matViewProjection : ViewProjection;
float4x4 ACW_ACW_ShinyJet_Vertex_Shader_matWorld : World;
float4 ACW_ACW_ShinyJet_Vertex_Shader_vViewPosition : ViewPosition;
float3 ACW_ACW_ShinyJet_Vertex_Shader_lightDirection
<
   string UIName = "ACW_ACW_ShinyJet_Vertex_Shader_lightDirection";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 1.00, 1.00, 0.00 );
float3 Scale
<
   string UIName = "Scale";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 0.40, 0.20, 0.40 );
float minY
<
   string UIName = "minY";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( -2.97 );
float maxY
<
   string UIName = "maxY";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 12.19 );
float WingScale
<
   string UIName = "WingScale";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 1.49 );
float3 InitialPos
<
   string UIName = "InitialPos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 0.00, 95.35, 0.00 );
float JetFlyRadius
<
   string UIName = "JetFlyRadius";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( -137.80 );
float JetFlyAngle;
float time : Time0_X;

struct ACW_ACW_ShinyJet_Vertex_Shader_VS_INPUT 
{
   float4 Position : POSITION0;
   float3 Normal : NORMAL;
};

struct ACW_ACW_ShinyJet_Vertex_Shader_VS_OUTPUT 
{
   float4 Position : POSITION0;
   float3 Reflect : TEXCOORD1;
   float3 Normal : NORMAL;
   float3 Light : TEXCOORD2;
   float3 View : TEXCOORD3;
};

ACW_ACW_ShinyJet_Vertex_Shader_VS_OUTPUT ACW_ACW_ShinyJet_Vertex_Shader_vs_main( ACW_ACW_ShinyJet_Vertex_Shader_VS_INPUT Input )
{
   ACW_ACW_ShinyJet_Vertex_Shader_VS_OUTPUT Output;

   float4 inPos = Input.Position;
   float3 normal = Input.Normal;
   
   if((inPos.y > minY) && (inPos.y < maxY) && (inPos.x < 49) && (inPos.x > -48))
   {
      inPos.xz *= WingScale;

      if(inPos.x < 0)
      {
         inPos.x *= WingScale;
      }
      else
      {
         inPos.z *= WingScale;
      }
   }
      
   float4x4 YRot = float4x4(cos(-time), 0, sin(-time), 0,
                            0,1,0,0,
                            -sin(-time),0,cos(-time),0,
                            0,0,0,1);
      
   
      
   inPos.xyz *= Scale;
   inPos.xyz += InitialPos;
   inPos.z += JetFlyRadius;
   inPos = mul(inPos, YRot);
   
   Output.Position = mul( inPos, ACW_ACW_ShinyJet_Vertex_Shader_matViewProjection );
   
   float3 Normal = mul(normalize((mul(normal, YRot))), ACW_ACW_ShinyJet_Vertex_Shader_matWorld);
   float3 PosWorldr = mul(inPos, ACW_ACW_ShinyJet_Vertex_Shader_matWorld);
   float3 ViewDir = normalize(PosWorldr - ACW_ACW_ShinyJet_Vertex_Shader_vViewPosition);
   
   Output.Reflect = reflect(ViewDir, Normal);
   
   Output.Normal = mul(Normal, ACW_ACW_ShinyJet_Vertex_Shader_matWorld);
   Output.Light = ACW_ACW_ShinyJet_Vertex_Shader_lightDirection;
   Output.View = ACW_ACW_ShinyJet_Vertex_Shader_vViewPosition - PosWorldr;
   
   return( Output );
   
}




samplerCUBE ACW_ACW_ShinyJet_Pixel_Shader_skyBox = sampler_state
{
   Texture = (skyBox_Tex);
};
float4 specColour
<
   string UIName = "specColour";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4( 1.00, 1.00, 1.00, 1.00 );
float ACW_ACW_ShinyJet_Pixel_Shader_specIntensity
<
   string UIName = "ACW_ACW_ShinyJet_Pixel_Shader_specIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 2.47 );

struct ACW_ACW_ShinyJet_Pixel_Shader_PS_INPUT
{
   float3 Reflect : TEXCOORD1;
   float3 Normal : NORMAL;
   float3 Light : TEXCOORD2;
   float3 View : TEXCOORD3;
};

float4 ACW_ACW_ShinyJet_Pixel_Shader_ps_main(ACW_ACW_ShinyJet_Pixel_Shader_PS_INPUT Input) : COLOR0
{   
   float4 colour = texCUBE(ACW_ACW_ShinyJet_Pixel_Shader_skyBox, Input.Reflect);

   float3 Normal = normalize(Input.Normal);
   float3 LightDir = normalize(Input.Light);
   float3 ViewDir = normalize(Input.View);
   
   float4 Dif = saturate(dot(Normal,LightDir));
   float3 Refl = normalize(2 * Normal - LightDir);
   
   float specular = specColour * ACW_ACW_ShinyJet_Pixel_Shader_specIntensity * pow(saturate(dot(Refl, ViewDir)), 8);

   return( colour +(specular*Dif) );
}




//--------------------------------------------------------------//
// MetalVehicle
//--------------------------------------------------------------//
string ACW_ACW_MetalVehicle_Teapot : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\Teapot.3ds";

float4x4 ACW_ACW_MetalVehicle_Vertex_Shader_matViewProjection : ViewProjection;
float4x4 ACW_ACW_MetalVehicle_Vertex_Shader_matWorld : World;
float4 ACW_ACW_MetalVehicle_Vertex_Shader_vViewPosition : ViewPosition;
float3 ACW_ACW_MetalVehicle_Vertex_Shader_lightDirection
<
   string UIName = "ACW_ACW_MetalVehicle_Vertex_Shader_lightDirection";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 1.00, 1.00, 0.00 );
float NewZ
<
   string UIName = "NewZ";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 61.99 );
float minX
<
   string UIName = "minX";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 44.54 );
float maxX
<
   string UIName = "maxX";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( -49.29 );
float YOffset
<
   string UIName = "YOffset";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.00 );
float3 ACW_ACW_MetalVehicle_Vertex_Shader_Scale
<
   string UIName = "ACW_ACW_MetalVehicle_Vertex_Shader_Scale";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 0.30, 0.30, 0.30 );
float3 TankPos
<
   string UIName = "TankPos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 107.41, 10.84, 0.00 );

struct ACW_ACW_MetalVehicle_Vertex_Shader_VS_INPUT 
{
   float4 Position : POSITION0;
   float3 Normal : NORMAL;
   float2 TexCoord : TEXCOORD0;
};

struct ACW_ACW_MetalVehicle_Vertex_Shader_VS_OUTPUT 
{
   float4 Position : POSITION0;
   float2 TexCoord : TEXCOORD0;
   float3 Reflect : TEXCOORD1;
   float3 Normal : NORMAL;
   float3 Light : TEXCOORD2;
   float3 View : TEXCOORD3;
};

ACW_ACW_MetalVehicle_Vertex_Shader_VS_OUTPUT ACW_ACW_MetalVehicle_Vertex_Shader_vs_main( ACW_ACW_MetalVehicle_Vertex_Shader_VS_INPUT Input )
{
   ACW_ACW_MetalVehicle_Vertex_Shader_VS_OUTPUT Output;

   float4 inPos = Input.Position;

   if((inPos.x > maxX) && (inPos.x < minX) && (inPos.y < YOffset))
   {
      if(inPos.z > 0)
      {
         inPos.z = NewZ;
      }else{
         inPos.z = -NewZ;
      }
   }

   inPos.xyz *= ACW_ACW_MetalVehicle_Vertex_Shader_Scale;
   inPos.xyz += TankPos;

   Output.Position = mul( inPos, ACW_ACW_MetalVehicle_Vertex_Shader_matViewProjection );
   
   float3 Normal = mul(normalize(Input.Normal), ACW_ACW_MetalVehicle_Vertex_Shader_matWorld);
   float3 PosWorldr = mul(Input.Position, ACW_ACW_MetalVehicle_Vertex_Shader_matWorld);
   float3 ViewDir = normalize(inPos - ACW_ACW_MetalVehicle_Vertex_Shader_vViewPosition);
   
   Output.Reflect = reflect(ViewDir, Normal);
   
   Output.Normal = mul(Normal, ACW_ACW_MetalVehicle_Vertex_Shader_matWorld);
   Output.Light = ACW_ACW_MetalVehicle_Vertex_Shader_lightDirection;
   Output.View = ACW_ACW_MetalVehicle_Vertex_Shader_vViewPosition - PosWorldr;
   Output.TexCoord = Input.TexCoord;
   
   return( Output );
   
}


samplerCUBE ACW_ACW_MetalVehicle_Pixel_Shader_skyBox = sampler_state
{
   Texture = (skyBox_Tex);
};
texture MetalDirt_Tex
<
   string ResourceName = "F:\\RenderMonkey ACW\\Textures\\MetalDirt.jpg";
>;
sampler2D MetalDirt = sampler_state
{
   Texture = (MetalDirt_Tex);
};
float4 ACW_ACW_MetalVehicle_Pixel_Shader_specColour
<
   string UIName = "ACW_ACW_MetalVehicle_Pixel_Shader_specColour";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4( 1.00, 1.00, 1.00, 1.00 );
float ACW_ACW_MetalVehicle_Pixel_Shader_specIntensity
<
   string UIName = "ACW_ACW_MetalVehicle_Pixel_Shader_specIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.72 );
float4 MetalColour
<
   string UIName = "MetalColour";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4( 0.26, 0.63, 0.25, 1.00 );
float4 diffuse
<
   string UIName = "diffuse";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4( 0.00, 0.73, 0.01, 1.00 );
float diffuseIntensity
<
   string UIName = "diffuseIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 0.36 );

struct ACW_ACW_MetalVehicle_Pixel_Shader_PS_INPUT
{
   float3 Reflect : TEXCOORD1;
   float3 Normal : NORMAL;
   float3 Light : TEXCOORD2;
   float3 View : TEXCOORD3;
   float2 TexCoord : TEXCOORD0;
};

float4 ACW_ACW_MetalVehicle_Pixel_Shader_ps_main(ACW_ACW_MetalVehicle_Pixel_Shader_PS_INPUT Input) : COLOR0
{   
   float4 colour = MetalColour * ((texCUBE(ACW_ACW_MetalVehicle_Pixel_Shader_skyBox, Input.Reflect)/2) - (tex2D(MetalDirt, Input.TexCoord)/2));
   
   float3 Normal = normalize(Input.Normal);
   float3 LightDir = normalize(Input.Light);
   float3 ViewDir = normalize(Input.View);
   
   float4 Dif = saturate(dot(Normal,LightDir));
   float3 Refl = normalize(2 * Normal - LightDir);
   
   float specular = ACW_ACW_MetalVehicle_Pixel_Shader_specColour * ACW_ACW_MetalVehicle_Pixel_Shader_specIntensity * pow(saturate(dot(Refl, ViewDir)), 8);

   return( colour + (Dif*diffuse*diffuseIntensity) + (specular*Dif) );
}

//--------------------------------------------------------------//
// BumpyCreature
//--------------------------------------------------------------//
string ACW_ACW_BumpyCreature_Teapot : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\Teapot.3ds";

float4x4 ACW_ACW_BumpyCreature_Vertex_Shader_matViewProjection : ViewProjection;
float4x4 ACW_ACW_BumpyCreature_Vertex_Shader_matWorld : World;
float4 ACW_ACW_BumpyCreature_Vertex_Shader_vViewPosition : ViewPosition;
float3 ACW_ACW_BumpyCreature_Vertex_Shader_lightDirection
<
   string UIName = "ACW_ACW_BumpyCreature_Vertex_Shader_lightDirection";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 1.00, 1.00, 0.00 );

float YStart
<
   string UIName = "YStart";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( -21.74 );
float LegScale
<
   string UIName = "LegScale";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( -60.16 );
float LegRadius
<
   string UIName = "LegRadius";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 10.51 );
float4 XPos
<
   string UIName = "XPos";
   string UIWidget = "Direction";
   bool UIVisible =  false;
   float4 UIMin = float4( -10.00, -10.00, -10.00, -10.00 );
   float4 UIMax = float4( 10.00, 10.00, 10.00, 10.00 );
   bool Normalize =  false;
> = float4( 29.60, 29.00, -29.00, -29.00 );
float4 ZPos
<
   string UIName = "ZPos";
   string UIWidget = "Direction";
   bool UIVisible =  false;
   float4 UIMin = float4( -10.00, -10.00, -10.00, -10.00 );
   float4 UIMax = float4( 10.00, 10.00, 10.00, 10.00 );
   bool Normalize =  false;
> = float4( 32.60, -32.00, 32.00, -32.00 );

float3 ACW_ACW_BumpyCreature_Vertex_Shader_Scale
<
   string UIName = "ACW_ACW_BumpyCreature_Vertex_Shader_Scale";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 0.25, 0.25, 0.25 );
float3 ACW_ACW_BumpyCreature_Vertex_Shader_InitialPos
<
   string UIName = "ACW_ACW_BumpyCreature_Vertex_Shader_InitialPos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( -277.95, 13.49, 0.00 );

float ACW_ACW_BumpyCreature_Vertex_Shader_time : Time0_X;
float Speed
<
   string UIName = "Speed";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 10.18 );
float Angle
<
   string UIName = "Angle";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 0.23 );

float InitAngle;
float3 MoveScale
<
   string UIName = "MoveScale";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 10.30, 0.00, 0.00 );
float MoveSpeed;

struct ACW_ACW_BumpyCreature_Vertex_Shader_VS_INPUT 
{
   float4 Position : POSITION0;  
   float3 Normal : NORMAL;
   float2 TexCoord : TEXCOORD0;
   float3 Tangent : TANGENT;
};

struct ACW_ACW_BumpyCreature_Vertex_Shader_VS_OUTPUT 
{
   float4 Position : POSITION0;
   float2 TexCoord : TEXCOORD0;
   float3 Light : TEXCOORD1;
   float3 View : TEXCOORD2;
};

float4 CreateLegs(float4 inPos, float ctime, bool rotateLegs)
{
      float4x4 Rotation;
      
      // Leg 1
      if(distance(inPos.xz, float2(XPos.x, ZPos.x)) < LegRadius)
      {
         inPos.y = LegScale;
         
         if(rotateLegs)
         {
            Rotation = float4x4(cos(ctime),-sin(ctime), 0, 0,
                             sin(ctime),cos(ctime),0,0,
                             0,0,1,0,
                             0,0,0,1);
                             
            inPos = mul(inPos, Rotation);
         }
      } 
      // Leg 2
      if(distance(inPos.xz, float2(XPos.y, ZPos.y)) < LegRadius)
      {
         inPos.y = LegScale;
         
         if(rotateLegs)
         {
            Rotation = float4x4(cos(-ctime),-sin(-ctime), 0, 0,
                             sin(-ctime),cos(-ctime),0,0,
                             0,0,1,0,
                             0,0,0,1);
                             
            inPos = mul(inPos, Rotation);
         }
      }
      // Leg 3
      if(distance(inPos.xz, float2(XPos.z, ZPos.z)) < LegRadius)
      {
         inPos.y = LegScale;   
         
         if(rotateLegs)
         {
            Rotation = float4x4(cos(-ctime),-sin(-ctime), 0, 0,
                             sin(-ctime),cos(-ctime),0,0,
                             0,0,1,0,
                             0,0,0,1);
                             
            inPos = mul(inPos, Rotation);
         }
      }
      // Leg 4
      if(distance(inPos.xz, float2(XPos.w, ZPos.w)) < LegRadius)
      {
         inPos.y = LegScale;
         if(rotateLegs)
         {
            Rotation = float4x4(cos(ctime),-sin(ctime), 0, 0,
                             sin(ctime),cos(ctime),0,0,
                             0,0,1,0,
                             0,0,0,1);
                             
            inPos = mul(inPos, Rotation);
         }
      }
      
      return inPos;
}

ACW_ACW_BumpyCreature_Vertex_Shader_VS_OUTPUT ACW_ACW_BumpyCreature_Vertex_Shader_vs_main( ACW_ACW_BumpyCreature_Vertex_Shader_VS_INPUT Input )
{
   ACW_ACW_BumpyCreature_Vertex_Shader_VS_OUTPUT Output;

   float4 inPos = Input.Position;                                   
   
   float cosTime = cos(ACW_ACW_BumpyCreature_Vertex_Shader_time*Speed)*Angle;
   
   float movement;
   if(ACW_ACW_BumpyCreature_Vertex_Shader_time%30 < 20)
   {
      movement = ACW_ACW_BumpyCreature_Vertex_Shader_time%30;
      if(inPos.y < YStart)
      {
         inPos = CreateLegs(inPos, cosTime, true);
      }
   }
   else
   {
      movement = 20;
      if(inPos.y < YStart)
      {
         inPos = CreateLegs(inPos, cosTime, false);
      }
   }                
            
   inPos.xyz *= ACW_ACW_BumpyCreature_Vertex_Shader_Scale;

   inPos.xyz += ACW_ACW_BumpyCreature_Vertex_Shader_InitialPos;
   inPos.xyz += MoveScale * movement;
   
   float3x3 worldToTangent;
   worldToTangent[0] = mul(Input.Tangent, ACW_ACW_BumpyCreature_Vertex_Shader_matWorld);
   worldToTangent[1] = mul(cross(Input.Tangent, Input.Normal), ACW_ACW_BumpyCreature_Vertex_Shader_matWorld);
   worldToTangent[2] = mul(Input.Normal, ACW_ACW_BumpyCreature_Vertex_Shader_matWorld);
   
   Output.Position = mul( inPos, ACW_ACW_BumpyCreature_Vertex_Shader_matViewProjection );
   Output.Light = mul(worldToTangent, normalize(ACW_ACW_BumpyCreature_Vertex_Shader_lightDirection));
   Output.View = mul(worldToTangent, ACW_ACW_BumpyCreature_Vertex_Shader_vViewPosition - (mul(inPos, ACW_ACW_BumpyCreature_Vertex_Shader_matWorld)));
   Output.TexCoord = Input.TexCoord;
   
   return( Output );
}


float ACW_ACW_BumpyCreature_Pixel_Shader_ambIntensity
<
   string UIName = "ACW_ACW_BumpyCreature_Pixel_Shader_ambIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.08 );

float ACW_ACW_BumpyCreature_Pixel_Shader_difIntensity
<
   string UIName = "ACW_ACW_BumpyCreature_Pixel_Shader_difIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 1.00 );

float specPow
<
   string UIName = "specPow";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 10.88 );
float ACW_ACW_BumpyCreature_Pixel_Shader_specIntensity
<
   string UIName = "ACW_ACW_BumpyCreature_Pixel_Shader_specIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 1.00 );

texture Base_Tex
<
   string ResourceName = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Textures\\Fieldstone.tga";
>;
sampler2D Base = sampler_state
{
   Texture = (Base_Tex);
};
texture Bump_Tex
<
   string ResourceName = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Textures\\FieldstoneBumpDOT3.tga";
>;
sampler2D Bump = sampler_state
{
   Texture = (Bump_Tex);
};

struct ACW_ACW_BumpyCreature_Pixel_Shader_PS_INPUT
{
   float2 TexCoord : TEXCOORD0;
   float3 Light : TEXCOORD1;
   float3 View : TEXCOORD2;
};

float4 ACW_ACW_BumpyCreature_Pixel_Shader_ps_main(ACW_ACW_BumpyCreature_Pixel_Shader_PS_INPUT Input) : COLOR0
{   
   // Ambient = Ambient Colour * Ambient Intensity
   float4 col = tex2D(Base, Input.TexCoord);
   float4 amb = ACW_ACW_BumpyCreature_Pixel_Shader_ambIntensity * col;
   
   float3 Normal = ((2*(tex2D(Bump, Input.TexCoord))) - 1.0);
   float3 lightDir = (Input.Light);
   float3 view = (Input.View);
   
   // Diffuse = Diffuse Colour * Diffuse Intensity * (dot(normalize(Normal), normalize(LightDir)))
   float dif = saturate(dot(normalize(Normal),normalize(lightDir)));
   
   // Specular = Specular Colour * Specular Intensity * pow(saturate(dot(Reflection, ViewDirection)),n)
   float3 reflection = normalize(2*normalize(Normal)-normalize(lightDir));
   
   float4 specular = float4(1,1,1,1) * ACW_ACW_BumpyCreature_Pixel_Shader_specIntensity * pow(saturate(dot(reflection, normalize(view))),specPow);
   
   return(amb + (dif*col*ACW_ACW_BumpyCreature_Pixel_Shader_difIntensity) + (specular*dif));
}



//--------------------------------------------------------------//
// TextureMapBird
//--------------------------------------------------------------//
string ACW_ACW_TextureMapBird_Teapot : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\Teapot.3ds";

float4x4 ACW_ACW_TextureMapBird_Vertex_Shader_matViewProjection : ViewProjection;
float ScaleFactor
<
   string UIName = "ScaleFactor";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 2.03 );
float TopWingPos
<
   string UIName = "TopWingPos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.76 );
float BottomWingPos
<
   string UIName = "BottomWingPos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( -4.38 );
float ACW_ACW_TextureMapBird_Vertex_Shader_minX
<
   string UIName = "ACW_ACW_TextureMapBird_Vertex_Shader_minX";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( -48.24 );
float ACW_ACW_TextureMapBird_Vertex_Shader_maxX
<
   string UIName = "ACW_ACW_TextureMapBird_Vertex_Shader_maxX";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 49.11 );
float ACW_ACW_TextureMapBird_Vertex_Shader_Speed
<
   string UIName = "ACW_ACW_TextureMapBird_Vertex_Shader_Speed";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 10.18 );
float ACW_ACW_TextureMapBird_Vertex_Shader_Angle
<
   string UIName = "ACW_ACW_TextureMapBird_Vertex_Shader_Angle";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 0.23 );
float ACW_ACW_TextureMapBird_Vertex_Shader_time : Time0_X;
float3 ACW_ACW_TextureMapBird_Vertex_Shader_Scale
<
   string UIName = "ACW_ACW_TextureMapBird_Vertex_Shader_Scale";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 0.15, 0.15, 0.15 );
float3 ACW_ACW_TextureMapBird_Vertex_Shader_InitialPos
<
   string UIName = "ACW_ACW_TextureMapBird_Vertex_Shader_InitialPos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 0.00, 65.28, 22.30 );
float ACW_ACW_TextureMapBird_Vertex_Shader_JetFlyRadius
<
   string UIName = "ACW_ACW_TextureMapBird_Vertex_Shader_JetFlyRadius";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( -137.80 );

struct ACW_ACW_TextureMapBird_Vertex_Shader_VS_INPUT 
{
   float4 Position : POSITION0;
   float3 Normal : NORMAL;
   float2 TexCoord : TEXCOORD0;
};

struct ACW_ACW_TextureMapBird_Vertex_Shader_VS_OUTPUT 
{
   float4 Position : POSITION0;
   float2 TexCoord : TEXCOORD0;
};

ACW_ACW_TextureMapBird_Vertex_Shader_VS_OUTPUT ACW_ACW_TextureMapBird_Vertex_Shader_vs_main( ACW_ACW_TextureMapBird_Vertex_Shader_VS_INPUT Input )
{
   ACW_ACW_TextureMapBird_Vertex_Shader_VS_OUTPUT Output;
   
   float4 inPos = Input.Position;
   
   float cosTime = cos(ACW_ACW_TextureMapBird_Vertex_Shader_time*ACW_ACW_TextureMapBird_Vertex_Shader_Speed)*ACW_ACW_TextureMapBird_Vertex_Shader_Angle;
   
   if((inPos.x > ACW_ACW_TextureMapBird_Vertex_Shader_minX) && (inPos.x < ACW_ACW_TextureMapBird_Vertex_Shader_maxX))
   {
      if((inPos.y < TopWingPos) && (inPos.y > BottomWingPos))
      {
         inPos.z *= ScaleFactor;
         
         // Flap
         if(inPos.z > 0.0)
         {
            float4x4 rotMat = float4x4(1,0,0,0,
                                       0,cos(cosTime), -sin(cosTime),0,
                                       0,sin(cosTime),cos(cosTime),0,
                                       0,0,0,1);
            inPos = mul(inPos,rotMat);
         }else if(inPos.z < 0.0)
         {
            float4x4 rotMat = float4x4(1,0,0,0,
                                       0,cos(-cosTime), -sin(-cosTime),0,
                                       0,sin(-cosTime),cos(-cosTime),0,
                                       0,0,0,1);
            inPos = mul(inPos,rotMat);
         }
      }
   }

   float4x4 YRot = float4x4(cos(-ACW_ACW_TextureMapBird_Vertex_Shader_time), 0, sin(-ACW_ACW_TextureMapBird_Vertex_Shader_time), 0,
                            0,1,0,0,
                            -sin(-ACW_ACW_TextureMapBird_Vertex_Shader_time),0,cos(-ACW_ACW_TextureMapBird_Vertex_Shader_time),0,
                            0,0,0,1);

   inPos.xyz *= ACW_ACW_TextureMapBird_Vertex_Shader_Scale;
   inPos.xyz += ACW_ACW_TextureMapBird_Vertex_Shader_InitialPos;
   inPos.z -= ACW_ACW_TextureMapBird_Vertex_Shader_JetFlyRadius;
   
   inPos = mul(inPos, YRot);

   Output.Position = mul( inPos, ACW_ACW_TextureMapBird_Vertex_Shader_matViewProjection );
   if(Input.Position.z > 0){
      Output.TexCoord = Input.TexCoord/2;
   } else {
      Output.TexCoord = -Input.TexCoord/2;
   }
   
   return( Output );
   
}




texture Feathers_Tex
<
   string ResourceName = "F:\\RenderMonkey ACW\\Textures\\Feathers.jpg";
>;
sampler2D Feathers = sampler_state
{
   Texture = (Feathers_Tex);
};

float4 ACW_ACW_TextureMapBird_Pixel_Shader_ps_main(float2 TexCoord : TEXCOORD0 ) : COLOR0
{   
   return( tex2D(Feathers, TexCoord) ); 
}




//--------------------------------------------------------------//
// Missile1
//--------------------------------------------------------------//
string ACW_ACW_Missile1_Sphere : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\Sphere.3ds";

float4x4 ACW_ACW_Missile1_Vertex_Shader_matViewProjection : ViewProjection;
float4x4 ACW_ACW_Missile1_Vertex_Shader_matWorld : World;
float4 ACW_ACW_Missile1_Vertex_Shader_vViewPosition : ViewPosition;
float3 ACW_ACW_Missile1_Vertex_Shader_lightDirection
<
   string UIName = "ACW_ACW_Missile1_Vertex_Shader_lightDirection";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 1.00, 1.00, 0.00 );
float ACW_ACW_Missile1_Vertex_Shader_time : Time0_X;
float3 ACW_ACW_Missile1_Vertex_Shader_TankPos
<
   string UIName = "ACW_ACW_Missile1_Vertex_Shader_TankPos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 107.41, 10.84, 0.00 );

float3 Missile1Pos
<
   string UIName = "Missile1Pos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( -46.12, 20.00, 0.00 );
float3 ACW_ACW_Missile1_Vertex_Shader_Scale
<
   string UIName = "ACW_ACW_Missile1_Vertex_Shader_Scale";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 0.15, 0.03, 0.03 );

struct ACW_ACW_Missile1_Vertex_Shader_VS_INPUT 
{
   float4 Position : POSITION0;
   float3 Normal : NORMAL;
};

struct ACW_ACW_Missile1_Vertex_Shader_VS_OUTPUT 
{
   float4 Position : POSITION0;
   float3 Normal : NORMAL;
   float3 Light : TEXCOORD1;
   float3 View : TEXCOORD2;
};

ACW_ACW_Missile1_Vertex_Shader_VS_OUTPUT ACW_ACW_Missile1_Vertex_Shader_vs_main( ACW_ACW_Missile1_Vertex_Shader_VS_INPUT Input )
{
   ACW_ACW_Missile1_Vertex_Shader_VS_OUTPUT Output;

   float4 inPos = Input.Position;
   
   if(ACW_ACW_Missile1_Vertex_Shader_time%30 > 20)
   {
      inPos.xyz *= ACW_ACW_Missile1_Vertex_Shader_Scale;
      inPos.xyz += Missile1Pos;
      
      float3 onePercent = (distance(inPos.xyz, ACW_ACW_Missile1_Vertex_Shader_TankPos)/100);
      
      inPos.x -= onePercent.x * ((20-ACW_ACW_Missile1_Vertex_Shader_time%30)*10);
   }else{
      inPos *= 0;
   }

   Output.Light = normalize(ACW_ACW_Missile1_Vertex_Shader_lightDirection);
   
   float3 PosWorldr = mul(inPos, ACW_ACW_Missile1_Vertex_Shader_matWorld);
   Output.View = ACW_ACW_Missile1_Vertex_Shader_vViewPosition - PosWorldr;

   Output.Position = mul( inPos, ACW_ACW_Missile1_Vertex_Shader_matViewProjection );
   Output.Normal = normalize(Input.Normal * ACW_ACW_Missile1_Vertex_Shader_Scale);
   
   return( Output );
   
}




float4 ambCol
<
   string UIName = "ambCol";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4( 1.00, 1.00, 1.00, 1.00 );
float4 difCol
<
   string UIName = "difCol";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4( 1.00, 1.00, 1.00, 1.00 );
float4 specCol
<
   string UIName = "specCol";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4( 1.00, 1.00, 1.00, 1.00 );

float ACW_ACW_Missile1_Pixel_Shader_ambIntensity
<
   string UIName = "ACW_ACW_Missile1_Pixel_Shader_ambIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.30 );
float ACW_ACW_Missile1_Pixel_Shader_difIntensity
<
   string UIName = "ACW_ACW_Missile1_Pixel_Shader_difIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.50 );
float ACW_ACW_Missile1_Pixel_Shader_specIntensity
<
   string UIName = "ACW_ACW_Missile1_Pixel_Shader_specIntensity";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.26 );

struct ACW_ACW_Missile1_Pixel_Shader_PS_INPUT 
{
   float3 Normal : NORMAL;
   float3 Light : TEXCOORD1;
   float3 View : TEXCOORD2;
};

float4 ACW_ACW_Missile1_Pixel_Shader_ps_main(ACW_ACW_Missile1_Pixel_Shader_PS_INPUT Input) : COLOR0
{   
   float4 amb = ACW_ACW_Missile1_Pixel_Shader_ambIntensity * ambCol;
   
   float dif = saturate(dot(normalize(Input.Normal),normalize(Input.Light)));
   float3 refl = normalize(2*normalize(Input.Normal)-normalize(Input.Light));
   
   float4 spec = specCol * ACW_ACW_Missile1_Pixel_Shader_specIntensity * pow(saturate(dot(refl, normalize(Input.View))), 8);
   
   return(amb + (dif*difCol*ACW_ACW_Missile1_Pixel_Shader_difIntensity) + (spec*dif));
}




//--------------------------------------------------------------//
// JetFlamesSmoke
//--------------------------------------------------------------//
string ACW_ACW_JetFlamesSmoke_QuadArray : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\QuadArray.3ds";

float4x4 ACW_ACW_JetFlamesSmoke_Vertex_Shader_matViewProjection : ViewProjection;
float4x4 matViewTranspose : ViewTranspose;
float PSpeed
<
   string UIName = "PSpeed";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.97 );
float PSysShape
<
   string UIName = "PSysShape";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.92 );
float PSpread
<
   string UIName = "PSpread";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 8.95 );
float PSHeight
<
   string UIName = "PSHeight";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 47.17 );
float PSize
<
   string UIName = "PSize";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 3.10 );
float4 PSPos
<
   string UIName = "PSPos";
   string UIWidget = "Direction";
   bool UIVisible =  false;
   float4 UIMin = float4( -10.00, -10.00, -10.00, -10.00 );
   float4 UIMax = float4( 10.00, 10.00, 10.00, 10.00 );
   bool Normalize =  false;
> = float4( 27.08, 97.78, 0.00, 1.00 );
float ACW_ACW_JetFlamesSmoke_Vertex_Shader_time : Time0_X;
float ACW_ACW_JetFlamesSmoke_Vertex_Shader_JetFlyRadius
<
   string UIName = "ACW_ACW_JetFlamesSmoke_Vertex_Shader_JetFlyRadius";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( -137.80 );
float ACW_ACW_JetFlamesSmoke_Vertex_Shader_JetFlyAngle;

struct VS_INPUT{
   float4 Position : POSITION;
   float2 TexCoord : TEXCOORD0;
};

struct ACW_ACW_JetFlamesSmoke_Vertex_Shader_VS_OUTPUT {
   float4 Position : POSITION;  
   float2 TexCoord : TEXCOORD0;
   float Colour : TEXCOORD1; 
};

ACW_ACW_JetFlamesSmoke_Vertex_Shader_VS_OUTPUT ACW_ACW_JetFlamesSmoke_Vertex_Shader_vs_main(ACW_ACW_JetFlamesSmoke_Vertex_Shader_VS_INPUT Input)
{
   ACW_ACW_JetFlamesSmoke_Vertex_Shader_VS_OUTPUT Output;
   
   float t = frac(Input.Position.z  + PSpeed * ACW_ACW_JetFlamesSmoke_Vertex_Shader_time);
   float s = pow(t, PSysShape);
   
   float3 pos;
   pos.x = PSHeight * t;
   pos.z = PSpread * s * cos(62*Input.Position.z);
   pos.y = PSpread * s * sin(163*Input.Position.z);
   
   pos += PSize * (Input.Position.x * matViewTranspose[0] + Input.Position.y * matViewTranspose[1]);
   pos += PSPos;
   pos.z += ACW_ACW_JetFlamesSmoke_Vertex_Shader_JetFlyRadius;
   
   float4x4 YRot = float4x4(cos(-ACW_ACW_JetFlamesSmoke_Vertex_Shader_time), 0, sin(-ACW_ACW_JetFlamesSmoke_Vertex_Shader_time), 0,
                            0,1,0,0,
                            -sin(-ACW_ACW_JetFlamesSmoke_Vertex_Shader_time),0,cos(-ACW_ACW_JetFlamesSmoke_Vertex_Shader_time),0,
                            0,0,0,1);
                            
   float4 inPos = mul(pos, YRot);
   
   Output.Position = mul(float4(inPos.xyz,1.0), ACW_ACW_JetFlamesSmoke_Vertex_Shader_matViewProjection);
   Output.TexCoord = Input.TexCoord;
   Output.Colour = 1 - t;
   
   return Output;
}
texture Flame_Tex
<
   string ResourceName = "F:\\RenderMonkey ACW\\Textures\\smoketex.jpg";
>;
sampler2D Flame = sampler_state
{
   Texture = (Flame_Tex);
};
float ACW_ACW_JetFlamesSmoke_Pixel_Shader_PSysShape;

struct ACW_ACW_JetFlamesSmoke_Pixel_Shader_PS_INPUT
{
   float2 TexCoord : TEXCOORD0;
   float Colour : TEXCOORD1;
};

float4 ACW_ACW_JetFlamesSmoke_Pixel_Shader_ps_main(ACW_ACW_JetFlamesSmoke_Pixel_Shader_PS_INPUT Input) : COLOR
{  
   return tex2D(Flame, Input.TexCoord);
}
//--------------------------------------------------------------//
// JetFlames
//--------------------------------------------------------------//
string ACW_ACW_JetFlames_QuadArray : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\QuadArray.3ds";

float4x4 ACW_ACW_JetFlames_Vertex_Shader_matViewProjection : ViewProjection;
float4x4 ACW_ACW_JetFlames_Vertex_Shader_matViewTranspose : ViewTranspose;
float ACW_ACW_JetFlames_Vertex_Shader_PSpeed
<
   string UIName = "ACW_ACW_JetFlames_Vertex_Shader_PSpeed";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.97 );
float ACW_ACW_JetFlames_Vertex_Shader_PSysShape
<
   string UIName = "ACW_ACW_JetFlames_Vertex_Shader_PSysShape";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.92 );
float ACW_ACW_JetFlames_Vertex_Shader_PSpread
<
   string UIName = "ACW_ACW_JetFlames_Vertex_Shader_PSpread";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 2.28 );
float ACW_ACW_JetFlames_Vertex_Shader_PSHeight
<
   string UIName = "ACW_ACW_JetFlames_Vertex_Shader_PSHeight";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 21.37 );
float ACW_ACW_JetFlames_Vertex_Shader_PSize
<
   string UIName = "ACW_ACW_JetFlames_Vertex_Shader_PSize";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 3.10 );
float4 ACW_ACW_JetFlames_Vertex_Shader_PSPos
<
   string UIName = "ACW_ACW_JetFlames_Vertex_Shader_PSPos";
   string UIWidget = "Direction";
   bool UIVisible =  false;
   float4 UIMin = float4( -10.00, -10.00, -10.00, -10.00 );
   float4 UIMax = float4( 10.00, 10.00, 10.00, 10.00 );
   bool Normalize =  false;
> = float4( 27.08, 97.78, 0.00, 1.00 );
float ACW_ACW_JetFlames_Vertex_Shader_time : Time0_X;
float ACW_ACW_JetFlames_Vertex_Shader_JetFlyRadius
<
   string UIName = "ACW_ACW_JetFlames_Vertex_Shader_JetFlyRadius";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( -137.80 );
float ACW_ACW_JetFlames_Vertex_Shader_JetFlyAngle;
struct VS_INPUT{
   float4 Position : POSITION;
   
};

struct ACW_ACW_JetFlames_Vertex_Shader_VS_OUTPUT {
   float4 Position : POSITION;  
   float2 TexCoord : TEXCOORD0;
   float Colour : TEXCOORD1; 
};

ACW_ACW_JetFlames_Vertex_Shader_VS_OUTPUT ACW_ACW_JetFlames_Vertex_Shader_vs_main(ACW_ACW_JetFlames_Vertex_Shader_VS_INPUT Input)
{
   ACW_ACW_JetFlames_Vertex_Shader_VS_OUTPUT Output;
   
   float t = frac(Input.Position.z  + ACW_ACW_JetFlames_Vertex_Shader_PSpeed * ACW_ACW_JetFlames_Vertex_Shader_time);
   float s = pow(t, ACW_ACW_JetFlames_Vertex_Shader_PSysShape);
   
   float3 pos;
   pos.x = ACW_ACW_JetFlames_Vertex_Shader_PSHeight * t;
   pos.z = ACW_ACW_JetFlames_Vertex_Shader_PSpread * s * cos(62*Input.Position.z);
   pos.y = ACW_ACW_JetFlames_Vertex_Shader_PSpread * s * sin(163*Input.Position.z);   
   
   
   pos += ACW_ACW_JetFlames_Vertex_Shader_PSPos;
   pos.z += ACW_ACW_JetFlames_Vertex_Shader_JetFlyRadius;
   
   float4x4 YRot = float4x4(cos(-ACW_ACW_JetFlames_Vertex_Shader_time), 0, sin(-ACW_ACW_JetFlames_Vertex_Shader_time), 0,
                            0,1,0,0,
                            -sin(-ACW_ACW_JetFlames_Vertex_Shader_time),0,cos(-ACW_ACW_JetFlames_Vertex_Shader_time),0,
                            0,0,0,1);
                            
   float4 inPos = mul(pos, YRot);
   
   inPos += (ACW_ACW_JetFlames_Vertex_Shader_PSize * (Input.Position.x * ACW_ACW_JetFlames_Vertex_Shader_matViewTranspose[0] + Input.Position.y * ACW_ACW_JetFlames_Vertex_Shader_matViewTranspose[1]));
   
   
   Output.Position = mul(float4(inPos.xyz,1.0), ACW_ACW_JetFlames_Vertex_Shader_matViewProjection);
   Output.TexCoord = Input.Position.xy;
   Output.Colour = 1 - t;
   
   return Output;
}
sampler2D ACW_ACW_JetFlames_Pixel_Shader_Flame = sampler_state
{
   Texture = (Flame_Tex);
};
float ACW_ACW_JetFlames_Pixel_Shader_PSysShape
<
   string UIName = "ACW_ACW_JetFlames_Pixel_Shader_PSysShape";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.92 );

struct ACW_ACW_JetFlames_Pixel_Shader_PS_INPUT
{
   float2 TexCoord : TEXCOORD0;
   float Colour : TEXCOORD1;
};

float4 ACW_ACW_JetFlames_Pixel_Shader_ps_main(ACW_ACW_JetFlames_Pixel_Shader_PS_INPUT Input) : COLOR
{  
   float fade = pow(dot(Input.TexCoord, Input.TexCoord), ACW_ACW_JetFlames_Pixel_Shader_PSysShape);
   return (1-fade) * tex2D(ACW_ACW_JetFlames_Pixel_Shader_Flame, (float2(Input.Colour, 0.5)));
}
//--------------------------------------------------------------//
// Missile1Flames
//--------------------------------------------------------------//
string ACW_ACW_Missile1Flames_QuadArray : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\QuadArray.3ds";

float4x4 ACW_ACW_Missile1Flames_Vertex_Shader_matViewProjection : ViewProjection;
float4x4 ACW_ACW_Missile1Flames_Vertex_Shader_matViewTranspose : ViewTranspose;
float ACW_ACW_Missile1Flames_Vertex_Shader_PSpeed
<
   string UIName = "ACW_ACW_Missile1Flames_Vertex_Shader_PSpeed";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.97 );
float ACW_ACW_Missile1Flames_Vertex_Shader_PSysShape
<
   string UIName = "ACW_ACW_Missile1Flames_Vertex_Shader_PSysShape";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.92 );
float ACW_ACW_Missile1Flames_Vertex_Shader_PSpread
<
   string UIName = "ACW_ACW_Missile1Flames_Vertex_Shader_PSpread";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 0.61 );
float ACW_ACW_Missile1Flames_Vertex_Shader_PSHeight
<
   string UIName = "ACW_ACW_Missile1Flames_Vertex_Shader_PSHeight";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 10.63 );
float ACW_ACW_Missile1Flames_Vertex_Shader_PSize
<
   string UIName = "ACW_ACW_Missile1Flames_Vertex_Shader_PSize";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 1.38 );
float4 ACW_ACW_Missile1Flames_Vertex_Shader_PSPos
<
   string UIName = "ACW_ACW_Missile1Flames_Vertex_Shader_PSPos";
   string UIWidget = "Direction";
   bool UIVisible =  false;
   float4 UIMin = float4( -10.00, -10.00, -10.00, -10.00 );
   float4 UIMax = float4( 10.00, 10.00, 10.00, 10.00 );
   bool Normalize =  false;
> = float4( -6.80, 96.70, 0.00, 1.00 );
float ACW_ACW_Missile1Flames_Vertex_Shader_time : Time0_X;
float ACW_ACW_Missile1Flames_Vertex_Shader_JetFlyRadius;
float ACW_ACW_Missile1Flames_Vertex_Shader_JetFlyAngle;
float3 ACW_ACW_Missile1Flames_Vertex_Shader_Missile1Pos
<
   string UIName = "ACW_ACW_Missile1Flames_Vertex_Shader_Missile1Pos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( -46.12, 20.00, 0.00 );
float3 ACW_ACW_Missile1Flames_Vertex_Shader_TankPos
<
   string UIName = "ACW_ACW_Missile1Flames_Vertex_Shader_TankPos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( 107.41, 10.84, 0.00 );
struct VS_INPUT{
   float4 Position : POSITION;
   
};

struct ACW_ACW_Missile1Flames_Vertex_Shader_VS_OUTPUT {
   float4 Position : POSITION;  
   float2 TexCoord : TEXCOORD0;
   float Colour : TEXCOORD1; 
};

ACW_ACW_Missile1Flames_Vertex_Shader_VS_OUTPUT ACW_ACW_Missile1Flames_Vertex_Shader_vs_main(ACW_ACW_Missile1Flames_Vertex_Shader_VS_INPUT Input)
{
   ACW_ACW_Missile1Flames_Vertex_Shader_VS_OUTPUT Output;
   
   float t = frac(Input.Position.z  + ACW_ACW_Missile1Flames_Vertex_Shader_PSpeed * ACW_ACW_Missile1Flames_Vertex_Shader_time);
   float s = pow(t, ACW_ACW_Missile1Flames_Vertex_Shader_PSysShape);
   
   float3 pos;
   
   if(ACW_ACW_Missile1Flames_Vertex_Shader_time%30 > 20)
   {
      pos.x = -(ACW_ACW_Missile1Flames_Vertex_Shader_PSHeight * t);
      pos.z = ACW_ACW_Missile1Flames_Vertex_Shader_PSpread * s * cos(62*Input.Position.z);
      pos.y = ACW_ACW_Missile1Flames_Vertex_Shader_PSpread * s * sin(163*Input.Position.z);   
   
   
      pos +=  ACW_ACW_Missile1Flames_Vertex_Shader_Missile1Pos;
      pos.x += ACW_ACW_Missile1Flames_Vertex_Shader_PSPos.x;
      
      float3 onePercent = (distance(pos.xyz, ACW_ACW_Missile1Flames_Vertex_Shader_TankPos)/100);
      
      pos.x -= onePercent.x * ((20-ACW_ACW_Missile1Flames_Vertex_Shader_time%30)*10);
      
      pos += (ACW_ACW_Missile1Flames_Vertex_Shader_PSize * (Input.Position.x * ACW_ACW_Missile1Flames_Vertex_Shader_matViewTranspose[0] + Input.Position.y * ACW_ACW_Missile1Flames_Vertex_Shader_matViewTranspose[1]));
   }
   else
   {
      pos *= 0;
   }
   
   Output.Position = mul(float4(pos.xyz,1.0), ACW_ACW_Missile1Flames_Vertex_Shader_matViewProjection);
   Output.TexCoord = Input.Position.xy;
   Output.Colour = 1 - t;
   
   return Output;
}
sampler2D ACW_ACW_Missile1Flames_Pixel_Shader_Flame = sampler_state
{
   Texture = (Flame_Tex);
};
float ACW_ACW_Missile1Flames_Pixel_Shader_PSysShape
<
   string UIName = "ACW_ACW_Missile1Flames_Pixel_Shader_PSysShape";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.92 );

struct ACW_ACW_Missile1Flames_Pixel_Shader_PS_INPUT
{
   float2 TexCoord : TEXCOORD0;
   float Colour : TEXCOORD1;
};

float4 ACW_ACW_Missile1Flames_Pixel_Shader_ps_main(ACW_ACW_Missile1Flames_Pixel_Shader_PS_INPUT Input) : COLOR
{  
   float fade = pow(dot(Input.TexCoord, Input.TexCoord), ACW_ACW_Missile1Flames_Pixel_Shader_PSysShape);
   return (1-fade) * tex2D(ACW_ACW_Missile1Flames_Pixel_Shader_Flame, (float2(Input.Colour, 0.5)));
}
//--------------------------------------------------------------//
// Explosion
//--------------------------------------------------------------//
string ACW_ACW_Explosion_QuadArray : ModelData = "..\\..\\..\\Program Files (x86)\\AMD\\RenderMonkey 1.82\\Examples\\Media\\Models\\QuadArray.3ds";

float4x4 ACW_ACW_Explosion_Vertex_Shader_matViewProjection : ViewProjection;
float4x4 ACW_ACW_Explosion_Vertex_Shader_matViewTranspose : ViewTranspose;
float ACW_ACW_Explosion_Vertex_Shader_PSpeed
<
   string UIName = "ACW_ACW_Explosion_Vertex_Shader_PSpeed";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 0.97 );
float ACW_ACW_Explosion_Vertex_Shader_PSysShape
<
   string UIName = "ACW_ACW_Explosion_Vertex_Shader_PSysShape";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 0.26 );
float ACW_ACW_Explosion_Vertex_Shader_PSpread
<
   string UIName = "ACW_ACW_Explosion_Vertex_Shader_PSpread";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 24.25 );
float ACW_ACW_Explosion_Vertex_Shader_PSHeight
<
   string UIName = "ACW_ACW_Explosion_Vertex_Shader_PSHeight";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 10.63 );
float ACW_ACW_Explosion_Vertex_Shader_PSize
<
   string UIName = "ACW_ACW_Explosion_Vertex_Shader_PSize";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float( 2.18 );
float4 ACW_ACW_Explosion_Vertex_Shader_PSPos
<
   string UIName = "ACW_ACW_Explosion_Vertex_Shader_PSPos";
   string UIWidget = "Direction";
   bool UIVisible =  false;
   float4 UIMin = float4( -10.00, -10.00, -10.00, -10.00 );
   float4 UIMax = float4( 10.00, 10.00, 10.00, 10.00 );
   bool Normalize =  false;
> = float4( 153.40, 0.00, 0.00, 1.00 );
float ACW_ACW_Explosion_Vertex_Shader_time : Time0_X;
float ACW_ACW_Explosion_Vertex_Shader_JetFlyRadius;
float ACW_ACW_Explosion_Vertex_Shader_JetFlyAngle;
float3 ACW_ACW_Explosion_Vertex_Shader_Missile1Pos
<
   string UIName = "ACW_ACW_Explosion_Vertex_Shader_Missile1Pos";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 1.00;
> = float3( -46.12, 20.00, 0.00 );
float3 ACW_ACW_Explosion_Vertex_Shader_TankPos;
struct VS_INPUT{
   float4 Position : POSITION;
   
};

struct ACW_ACW_Explosion_Vertex_Shader_VS_OUTPUT {
   float4 Position : POSITION;  
   float2 TexCoord : TEXCOORD0;
   float Colour : TEXCOORD1; 
};

ACW_ACW_Explosion_Vertex_Shader_VS_OUTPUT ACW_ACW_Explosion_Vertex_Shader_vs_main(ACW_ACW_Explosion_Vertex_Shader_VS_INPUT Input)
{
   ACW_ACW_Explosion_Vertex_Shader_VS_OUTPUT Output;
   
   float t = frac(Input.Position.z  + ACW_ACW_Explosion_Vertex_Shader_PSpeed * ACW_ACW_Explosion_Vertex_Shader_time);
   float s = pow(t, ACW_ACW_Explosion_Vertex_Shader_PSysShape);
   
   float3 pos;
   
   if(ACW_ACW_Explosion_Vertex_Shader_time%30 < 0.5)
   {
      pos.x = ACW_ACW_Explosion_Vertex_Shader_PSpread * s * sin(163*Input.Position.z);   
      pos.z = ACW_ACW_Explosion_Vertex_Shader_PSpread * s * cos(62*Input.Position.z);
      pos.y = (ACW_ACW_Explosion_Vertex_Shader_PSHeight * t);
   
   
      pos +=  ACW_ACW_Explosion_Vertex_Shader_Missile1Pos;
      pos += ACW_ACW_Explosion_Vertex_Shader_PSPos;
      
      pos += (ACW_ACW_Explosion_Vertex_Shader_PSize * (Input.Position.x * ACW_ACW_Explosion_Vertex_Shader_matViewTranspose[0] + Input.Position.y * ACW_ACW_Explosion_Vertex_Shader_matViewTranspose[1]));
   }
   else
   {
      pos = 0;
   }
   
   Output.Position = mul(float4(pos.xyz,1.0), ACW_ACW_Explosion_Vertex_Shader_matViewProjection);
   Output.TexCoord = Input.Position.xy;
   Output.Colour = 1 - t;
   
   return Output;
}
sampler2D ACW_ACW_Explosion_Pixel_Shader_Flame = sampler_state
{
   Texture = (Flame_Tex);
};
float ACW_ACW_Explosion_Pixel_Shader_PSysShape
<
   string UIName = "ACW_ACW_Explosion_Pixel_Shader_PSysShape";
   string UIWidget = "Numeric";
   bool UIVisible =  false;
   float UIMin = -1.00;
   float UIMax = 0.00;
> = float( 0.26 );

struct ACW_ACW_Explosion_Pixel_Shader_PS_INPUT
{
   float2 TexCoord : TEXCOORD0;
   float Colour : TEXCOORD1;
};

float4 ACW_ACW_Explosion_Pixel_Shader_ps_main(ACW_ACW_Explosion_Pixel_Shader_PS_INPUT Input) : COLOR
{  
   float fade = pow(dot(Input.TexCoord, Input.TexCoord), ACW_ACW_Explosion_Pixel_Shader_PSysShape);
   return (1-fade) * tex2D(ACW_ACW_Explosion_Pixel_Shader_Flame, (float2(Input.Colour, 0.5)));
}
//--------------------------------------------------------------//
// Technique Section for ACW
//--------------------------------------------------------------//
technique ACW
{
   pass Environment
   {
      CULLMODE = CW;
      ZWRITEENABLE = FALSE;

      VertexShader = compile vs_2_0 ACW_ACW_Environment_Vertex_Shader_vs_main();
      PixelShader = compile ps_2_0 ACW_ACW_Environment_Pixel_Shader_ps_main();
   }

   pass Terrain
   {
      CULLMODE = CCW;
      ZWRITEENABLE = TRUE;

      VertexShader = compile vs_3_0 ACW_ACW_Terrain_Vertex_Shader_vs_main();
      PixelShader = compile ps_3_0 ACW_ACW_Terrain_Pixel_Shader_ps_main();
   }

   pass ShinyJet
   {
      CULLMODE = CCW;
      ZWRITEENABLE = TRUE;
      ALPHABLENDENABLE = FALSE;
      ZENABLE = TRUE;

      VertexShader = compile vs_3_0 ACW_ACW_ShinyJet_Vertex_Shader_vs_main();
      PixelShader = compile ps_3_0 ACW_ACW_ShinyJet_Pixel_Shader_ps_main();
   }

   pass MetalVehicle
   {
      CULLMODE = CCW;
      ZWRITEENABLE = TRUE;
      ALPHABLENDENABLE = FALSE;
      ZENABLE = TRUE;

      VertexShader = compile vs_3_0 ACW_ACW_MetalVehicle_Vertex_Shader_vs_main();
      PixelShader = compile ps_3_0 ACW_ACW_MetalVehicle_Pixel_Shader_ps_main();
   }

   pass BumpyCreature
   {
      CULLMODE = CCW;
      ZWRITEENABLE = TRUE;

      VertexShader = compile vs_3_0 ACW_ACW_BumpyCreature_Vertex_Shader_vs_main();
      PixelShader = compile ps_3_0 ACW_ACW_BumpyCreature_Pixel_Shader_ps_main();
   }

   pass TextureMapBird
   {
      CULLMODE = CCW;
      ZWRITEENABLE = TRUE;

      VertexShader = compile vs_2_0 ACW_ACW_TextureMapBird_Vertex_Shader_vs_main();
      PixelShader = compile ps_2_0 ACW_ACW_TextureMapBird_Pixel_Shader_ps_main();
   }

   pass Missile1
   {
      VertexShader = compile vs_3_0 ACW_ACW_Missile1_Vertex_Shader_vs_main();
      PixelShader = compile ps_3_0 ACW_ACW_Missile1_Pixel_Shader_ps_main();
   }

   pass JetFlamesSmoke
   {
      CULLMODE = NONE;
      SRCBLEND = ONE;
      DESTBLEND = ONE;
      ZWRITEENABLE = FALSE;
      ZENABLE = TRUE;
      ALPHABLENDENABLE = TRUE;

      VertexShader = compile vs_2_0 ACW_ACW_JetFlamesSmoke_Vertex_Shader_vs_main();
      PixelShader = compile ps_2_0 ACW_ACW_JetFlamesSmoke_Pixel_Shader_ps_main();
   }

   pass JetFlames
   {
      VertexShader = compile vs_2_0 ACW_ACW_JetFlames_Vertex_Shader_vs_main();
      PixelShader = compile ps_2_0 ACW_ACW_JetFlames_Pixel_Shader_ps_main();
   }

   pass Missile1Flames
   {
      CULLMODE = NONE;
      SRCBLEND = ONE;
      DESTBLEND = ONE;
      ZWRITEENABLE = FALSE;
      ZENABLE = TRUE;
      ALPHABLENDENABLE = TRUE;

      VertexShader = compile vs_2_0 ACW_ACW_Missile1Flames_Vertex_Shader_vs_main();
      PixelShader = compile ps_2_0 ACW_ACW_Missile1Flames_Pixel_Shader_ps_main();
   }

   pass Explosion
   {
      CULLMODE = NONE;
      SRCBLEND = ONE;
      DESTBLEND = ONE;
      ZWRITEENABLE = FALSE;
      ZENABLE = TRUE;
      ALPHABLENDENABLE = TRUE;

      VertexShader = compile vs_2_0 ACW_ACW_Explosion_Vertex_Shader_vs_main();
      PixelShader = compile ps_2_0 ACW_ACW_Explosion_Pixel_Shader_ps_main();
   }

}

