//
//  Shaders.metal
//  Iyan3DEngine
//
//  Created by Vivek on 23/03/14.
//  Copyright (c) 2014 Vivek. All rights reserved.
//



#include <metal_stdlib>
#include <metal_geometric>
#include <simd/simd.h>

using namespace metal;



typedef struct
{
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texCoord1;
    packed_float4 optionalData1;
} vertex_t;

typedef struct
{
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texCoord1;
    packed_float4 optionalData1;
    packed_float4 optionalData2;
    packed_float4 optionalData3;
    packed_float4 optionalData4;
} vertex_heavy_t;


typedef struct
{
    packed_float3 data;
}float3Struct;

typedef struct
{
    packed_float4 data;
}float4Struct;


typedef struct {
    float isLighting;
    float vertexDepth,reflection;
    float shadowDarkness,transparency;
    float2 uv,texture2UV;
    float4 position [[position]] , vertexPosCam;
    float4 normal,eyeVec,lightDir,lightColor,perVertexColor;
} ColorInOut;



typedef struct {
    matrix_float4x4 JointTransform;
} JointData;

typedef struct {
    float3 lightPosition;
} LightPosData;

// CommonSkinVertex
#define SHADER_COMMON_SKIN_mvp 1
#define SHADER_COMMON_SKIN_transparency 2
#define SHADER_COMMON_SKIN_world 3
#define SHADER_COMMON_SKIN_isLighting 4
#define SHADER_COMMON_SKIN_refraction 5
#define SHADER_COMMON_SKIN_reflection 6
#define SHADER_COMMON_SKIN_shadowDarkness 7
#define SHADER_COMMON_SKIN_lightPos 8
#define SHADER_COMMON_SKIN_eyePos 9
#define SHADER_COMMON_SKIN_lightColor 10
#define SHADER_COMMON_SKIN_lightViewProjMatrix 11
#define SHADER_COMMON_SKIN_jointData 12
#define SHADER_COMMON_SKIN_ViewMatrix 13
#define SHADER_COMMON_SKIN_VertexColor 14
#define SHADER_COMMON_SKIN_texture1 0
#define SHADER_COMMON_SKIN_texture2 1

#define SHADER_COMMON_isVertexColored 21

vertex ColorInOut Common_Skin_Vertex(device vertex_heavy_t* vertex_array [[ buffer(0) ]],
                                     constant matrix_float4x4& mvp [[ buffer(SHADER_COMMON_SKIN_mvp) ]],
                                     constant JointData* Joint_Data [[ buffer(SHADER_COMMON_SKIN_jointData) ]],
                                     constant float& transparency [[ buffer(SHADER_COMMON_SKIN_transparency) ]],
                                     constant matrix_float4x4& world [[ buffer(SHADER_COMMON_SKIN_world) ]],
                                     constant int& isLighting [[ buffer(SHADER_COMMON_SKIN_isLighting) ]],
                                     constant float& reflection [[ buffer(SHADER_COMMON_SKIN_reflection) ]],
                                     constant float& shadowDarkness [[ buffer(SHADER_COMMON_SKIN_shadowDarkness) ]],
                                     constant packed_float3& eyePos [[ buffer(SHADER_COMMON_SKIN_eyePos) ]],
                                     constant matrix_float4x4& lightViewProjMatrix [[ buffer(SHADER_COMMON_SKIN_lightViewProjMatrix) ]],
                                     unsigned int vid [[ vertex_id ]],
                                     constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]],
                                     constant float3Struct *vertColor [[buffer(SHADER_COMMON_SKIN_VertexColor)]]
                                     )
{
    
    // Vertex Position & normal calculatino from joint transformation---------
    ColorInOut out;
    float4 in_position = float4(float3(vertex_array[vid].position), 1.0);
    float4 in_normal = float4(float3(vertex_array[vid].normal), 0.0);
    float4 optionalData1 = vertex_array[vid].optionalData1;
    float4 optionalData2 = vertex_array[vid].optionalData2;
    float4 optionalData3 = vertex_array[vid].optionalData3;
    float4 optionalData4 = vertex_array[vid].optionalData4;
    float4 pos = float4(0.0);
    float4 nor = float4(0.0);
    
    out.perVertexColor = (int(isVertexColored) == 0) ? float4(1.0) : float4(float3(vertColor[0].data),1.0);
    
    int jointId = int(optionalData1.x);
    float strength = optionalData2.x ;
    if(jointId > 0){
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
        nor = nor + (Joint_Data[jointId - 1].JointTransform * in_normal) * strength;
    }else{
        pos = in_position;
        nor = in_normal;
    }
    
    jointId = int(optionalData1.y);
    strength = optionalData2.y ;
    if(jointId > 0){
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
        nor = nor + (Joint_Data[jointId - 1].JointTransform * in_normal) * strength;
    }
    
    jointId = int(optionalData1.z);
    strength = optionalData2.z ;
    if(jointId > 0){
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
        nor = nor + (Joint_Data[jointId - 1].JointTransform * in_normal) * strength;
    }
    
    jointId = int(optionalData1.w);
    strength = optionalData2.w;
    if(jointId > 0){
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
        nor = nor + (Joint_Data[jointId - 1].JointTransform * in_normal) * strength;
    }
    
    jointId = int(optionalData3.x);
    strength = optionalData4.x;
    if(jointId > 0){
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
        nor = nor + (Joint_Data[jointId - 1].JointTransform * in_normal) * strength;
    }
    
    jointId = int(optionalData3.y);
    strength = optionalData4.y;
    if(jointId > 0){
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
        nor = nor + (Joint_Data[jointId - 1].JointTransform * in_normal) * strength;
    }
    
    jointId = int(optionalData3.z);
    strength = optionalData4.z;
    if(jointId > 0){
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
        nor = nor + (Joint_Data[jointId - 1].JointTransform * in_normal) * strength;
    }
    
    jointId = int(optionalData3.w);
    strength = optionalData4.w;
    if(jointId > 0){
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
        nor = nor + (Joint_Data[jointId - 1].JointTransform * in_normal) * strength;
    }
    nor = normalize(nor);
    //-----------
    
    float4 vertex_position_objectspace = pos;
    float4 vertex_position_cameraspace = world * pos;
    out.vertexPosCam = vertex_position_cameraspace;
    
    out.transparency = transparency;
    out.position = mvp * vertex_position_objectspace;
    float2 uv = (int(isVertexColored) == 0) ? vertex_array[vid].texCoord1 : float2(0.0,0.0);
    out.uv.x = uv.x;
    out.uv.y = uv.y;
    
    
    //Shadow Coords Calculation -----------
    float4 vertexLightCoord = (lightViewProjMatrix * world) * vertex_position_objectspace;
    float4 texCoords = vertexLightCoord/vertexLightCoord.w;
    out.texture2UV = float4((texCoords / 2.0) + 0.5).xy;
    out.texture2UV.y = (1.0 - out.texture2UV.y); // need to flip metal texture vertically
    out.vertexDepth = texCoords.z;
    //----------
    
    // Lighting Calculation-----------
    if(isLighting == 1){
        out.isLighting = 1.0;
        float4 eye_position_cameraspace = float4(float3(eyePos),1.0);
        
        out.normal = normalize(world * float4(float3(nor.xyz),0.0));
        out.eyeVec = normalize(eye_position_cameraspace - vertex_position_cameraspace);
        out.reflection = reflection;
        out.shadowDarkness = shadowDarkness;
    }else{
        out.isLighting = 0.0;
        out.shadowDarkness = 0.0;
    }
    //--------------
    return out;
}

#define SHADER_PARTICLE_vp 1
#define SHADER_PARTICLE_sColor 2
#define SHADER_PARTICLE_mColor 3
#define SHADER_PARTICLE_eColor 4
#define SHADER_PARTICLE_props 5
#define SHADER_PARTICLE_positions 6
#define SHADER_PARTICLE_rotations 7
#define SHADER_PARTICLE_texture1 8


vertex ColorInOut Particle_Vertex(device vertex_t* vertex_array [[ buffer(0) ]],
                                  constant matrix_float4x4& vp [[ buffer(SHADER_PARTICLE_vp) ]],
                                  constant packed_float4& sColor [[ buffer(SHADER_PARTICLE_sColor) ]],
                                  constant packed_float4& mColor [[ buffer(SHADER_PARTICLE_mColor) ]],
                                  constant packed_float4& eColor [[ buffer(SHADER_PARTICLE_eColor) ]],
                                  constant packed_float4& props [[ buffer(SHADER_PARTICLE_props) ]],
                                  constant float4Struct *positions [[ buffer(SHADER_PARTICLE_positions) ]],
                                  constant float4Struct *rotations [[ buffer(SHADER_PARTICLE_rotations) ]],
                                  constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]],
                                  unsigned int vid [[ vertex_id ]],
                                  unsigned int iid [[instance_id]]
                                  )
{
    float4 vertex_position_objectspace = float4(float3(vertex_array[vid].position), 1.0);
    
    ColorInOut out;
    
    float2 uv = vertex_array[vid].texCoord1;
    out.uv.x = uv.x;
    out.uv.y = uv.y;
    
    float percent = (positions[iid].data[3]/props[0]);
    float phase = (percent > 0.5);
    
    float4 s = mix(sColor, mColor, phase);
    float4 e = mix(mColor, eColor, phase);
    float age = mix(percent, float(percent - 0.5), phase) * 2.0;
    out.perVertexColor = (int(isVertexColored) == 0) ? float4(mix(s, e, age)) : float4(sColor);
    float scale = float(props[1] + (props[2] * positions[iid].data[3]));
    
    matrix_float4x4 translation = matrix_float4x4(1);
    translation[3][0] = positions[iid].data[0];
    translation[3][1] = positions[iid].data[1];
    translation[3][2] = positions[iid].data[2];
    
    matrix_float4x4 rotationMat = matrix_float4x4(1);
    float cr = cos(rotations[iid].data[0]);
    float sr = sin(rotations[iid].data[0]);
    float cp = cos(rotations[iid].data[1]);
    float sp = sin(rotations[iid].data[1]);
    float cy = cos(rotations[iid].data[2]);
    float sy = sin(rotations[iid].data[2]);
    
    rotationMat[0][0] = (cp * cy);
    rotationMat[0][1] = (cp * sy);
    rotationMat[0][2] = (-sp);
    
    float srsp = sr * sp;
    float crsp = cr * sp;
    
    rotationMat[1][0] = (srsp * cy - cr * sy);
    rotationMat[1][1] = (srsp * sy + cr * cy);
    rotationMat[1][2] = (sr * cp);
    
    rotationMat[2][0] = (crsp * cy + sr * sy);
    rotationMat[2][1] = (crsp * sy - sr * cy);
    rotationMat[2][2] = (cr * cp);

    matrix_float4x4 scaleMat = matrix_float4x4(1);
    scaleMat[0][0] = scale;
    scaleMat[1][1] = scale;
    scaleMat[2][2] = scale;
    
    float live = float(positions[iid].data[3] > 0.0 && positions[iid].data[3] <= props[0]);
    translation = translation * live;
    
    matrix_float4x4 model = translation * rotationMat;
    out.position = vp * model * vertex_position_objectspace;
    
    return out;
}

vertex ColorInOut Particle_Vertex_RTT(device vertex_t* vertex_array [[ buffer(0) ]],
                                  constant matrix_float4x4& vp [[ buffer(SHADER_PARTICLE_vp) ]],
                                  constant packed_float4& sColor [[ buffer(SHADER_PARTICLE_sColor) ]],
                                  constant packed_float4& mColor [[ buffer(SHADER_PARTICLE_mColor) ]],
                                  constant packed_float4& eColor [[ buffer(SHADER_PARTICLE_eColor) ]],
                                  constant packed_float4& props [[ buffer(SHADER_PARTICLE_props) ]],
                                  constant float4Struct *positions [[ buffer(SHADER_PARTICLE_positions) ]],
                                  constant float4Struct *rotations [[ buffer(SHADER_PARTICLE_rotations) ]],
                                  constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]],
                                  unsigned int vid [[ vertex_id ]],
                                  unsigned int iid [[instance_id]]
                                  )
{
    float4 vertex_position_objectspace = float4(float3(vertex_array[vid].position), 1.0);
    
    ColorInOut out;
    
    float2 uv = vertex_array[vid].texCoord1;
    out.uv.x = uv.x;
    out.uv.y = uv.y;
    
    float percent = (positions[iid].data[3]/props[0]);
    float phase = (percent > 0.5);
    
    float4 s = mix(sColor, mColor, phase);
    float4 e = mix(mColor, eColor, phase);
    float age = mix(percent, float(percent - 0.5), phase) * 2.0;
    out.perVertexColor = (int(isVertexColored) == 0) ? float4(mix(s, e, age)) : float4(sColor);
    float scale = float(props[1] + (props[2] * positions[iid].data[3]));
    
    matrix_float4x4 translation = matrix_float4x4(1);
    translation[3][0] = positions[iid].data[0];
    translation[3][1] = positions[iid].data[1];
    translation[3][2] = positions[iid].data[2];
    
    matrix_float4x4 rotationMat = matrix_float4x4(1);
    float cr = cos(rotations[iid].data[0]);
    float sr = sin(rotations[iid].data[0]);
    float cp = cos(rotations[iid].data[1]);
    float sp = sin(rotations[iid].data[1]);
    float cy = cos(rotations[iid].data[2]);
    float sy = sin(rotations[iid].data[2]);
    
    rotationMat[0][0] = (cp * cy);
    rotationMat[0][1] = (cp * sy);
    rotationMat[0][2] = (-sp);
    
    float srsp = sr * sp;
    float crsp = cr * sp;
    
    rotationMat[1][0] = (srsp * cy - cr * sy);
    rotationMat[1][1] = (srsp * sy + cr * cy);
    rotationMat[1][2] = (sr * cp);
    
    rotationMat[2][0] = (crsp * cy + sr * sy);
    rotationMat[2][1] = (crsp * sy - sr * cy);
    rotationMat[2][2] = (cr * cp);
    
    matrix_float4x4 scaleMat = matrix_float4x4(1);
    scaleMat[0][0] = scale;
    scaleMat[1][1] = scale;
    scaleMat[2][2] = scale;
    
    float live = float(positions[iid].data[3] > 0.0 && positions[iid].data[3] <= props[0]);
    translation = translation * live;
    
    matrix_float4x4 model = translation * rotationMat;
    out.position = vp * model * vertex_position_objectspace;
    
    return out;
}


fragment float4 Particle_Fragment(ColorInOut in [[stage_in]], texture2d<half>  tex2D [[texture(SHADER_PARTICLE_texture1)]])
{
    float4 color = in.perVertexColor;
    constexpr sampler quad_sampler(address::repeat,filter::linear);
    color[3] =  tex2D.sample(quad_sampler,in.uv)[0];
    return color;
}

fragment float4 Particle_Fragment_RTT(ColorInOut in [[stage_in]], texture2d<half>  tex2D [[texture(SHADER_PARTICLE_texture1)]])
{
    float4 color = in.perVertexColor;
    return color;
}


#define SHADER_COMMON_mvp 1
#define SHADER_COMMON_transparency 2
#define SHADER_COMMON_world 3
#define SHADER_COMMON_isLighting 4
#define SHADER_COMMON_refraction 5
#define SHADER_COMMON_reflection 6
#define SHADER_COMMON_shadowDarkness 7
#define SHADER_COMMON_lightPos 8
#define SHADER_COMMON_eyePos 9
#define SHADER_COMMON_lightColor 10
#define SHADER_COMMON_lightViewProjMatrix 11
#define SHADER_COMMON_viewMatrix 12
#define SHADER_COMMON_lightFadeDistance 20
#define SHADER_COMMON_texture1 0
#define SHADER_COMMON_texture2 1

vertex ColorInOut Common_Vertex(device vertex_t* vertex_array [[ buffer(0) ]],
                                constant matrix_float4x4& mvp [[ buffer(SHADER_COMMON_mvp) ]],
                                constant float& transparency [[ buffer(SHADER_COMMON_transparency) ]],
                                constant matrix_float4x4& world [[ buffer(SHADER_COMMON_world) ]],
                                constant matrix_float4x4& lightViewProjMatrix [[ buffer(SHADER_COMMON_lightViewProjMatrix) ]],
                                constant int& isLighting [[ buffer(SHADER_COMMON_isLighting) ]],
                                constant float& reflection [[ buffer(SHADER_COMMON_reflection) ]],
                                constant packed_float3& eyePos [[ buffer(SHADER_COMMON_eyePos) ]],
                                constant float& shadowDarkness [[ buffer(SHADER_COMMON_shadowDarkness) ]],
                                unsigned int vid [[ vertex_id ]],
                                constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]],
                                constant float3Struct *vertColor [[buffer(SHADER_COMMON_SKIN_VertexColor)]]
                                )
{
    float4 vertex_position_objectspace = float4(float3(vertex_array[vid].position), 1.0);
    float4 vertex_position_cameraspace = world * float4(float3(vertex_array[vid].position), 1.0);
    
    ColorInOut out;
    out.vertexPosCam = vertex_position_cameraspace;
    out.transparency = transparency;
    out.position = mvp * vertex_position_objectspace;
    float2 uv = (int(isVertexColored) == 0) ? vertex_array[vid].texCoord1 : float2(0.0,0.0);
    out.uv.x = uv.x;
    out.uv.y = uv.y;
    //Shadow Coords Calculation -----------
    float4 vertexLightCoord = (lightViewProjMatrix * world) * vertex_position_objectspace;
    float4 texCoords = vertexLightCoord/vertexLightCoord.w;
    out.texture2UV = float4((texCoords / 2.0) + 0.5).xy;
    out.texture2UV.y = (1.0 - out.texture2UV.y); // need to flip metal texture vertically
    out.vertexDepth = texCoords.z;
    out.perVertexColor = (int(isVertexColored) == 0) ? float4(1.0) : float4(float3(vertColor[0].data),1.0);
    //----------
    
    // Lighting Calculation-----------
    if(isLighting == 1){
        out.isLighting = 1.0;
        float4 eye_position_cameraspace =  float4(float3(eyePos),1.0);
        
        out.normal = normalize(world * float4(float3(vertex_array[vid].normal),0.0));
        out.eyeVec = normalize(eye_position_cameraspace - vertex_position_cameraspace);
        out.reflection = reflection;
        out.shadowDarkness = shadowDarkness;
    }else{
        out.isLighting = 0.0;
        out.shadowDarkness = 0.0;
        out.lightColor = float4(1.0);
    }
    //--------------
    return out;
}

// Fragment shader function
fragment half4 Common_Fragment_L1(ColorInOut in [[stage_in]],texture2d<half>  tex2D [[texture(SHADER_COMMON_texture1)]],
                               depth2d<float> shadow_texture [[texture(SHADER_COMMON_texture2)]],
                               constant packed_float3* lightPos [[ buffer(SHADER_COMMON_lightPos) ]],
                               constant packed_float3* lightColor [[ buffer(SHADER_COMMON_lightColor) ]],
                               constant float* lightFadeDistance[[ buffer(SHADER_COMMON_lightFadeDistance)]],
                               constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]])
{
    
    // Shadow Calculation----------
    float shadowBias = 0.005,shadowValue = 0.0,maxSpecular = 30.0;
    if(in.shadowDarkness > 0.0){
        constexpr sampler linear_sampler(min_filter::linear, mag_filter::linear);
        float depth = shadow_texture.sample(linear_sampler,in.texture2UV);
        if((depth + shadowBias) < in.vertexDepth)
            shadowValue = in.shadowDarkness;
    }
    //------------------
    
    half4 diffuse_color = half4(in.perVertexColor);
    
    if(isVertexColored == 0.0) {
        constexpr sampler quad_sampler(address::repeat,filter::linear);
        diffuse_color =  tex2D.sample(quad_sampler,in.uv);
    }

    
    // Lighting Calculation----------
    
    
    half4 specular = half4(0.0), colorOfLight = half4(1.0);
    
    if(in.isLighting != 0.0){
        colorOfLight = half4(0.0);
        
        //getColorOfLight(0,lightPos[0],lightColor[0],lightFadeDistance[0],specular, colorOfLight);
        
        float4 light_position_cameraspace = float4(float3(lightPos[0]),1.0);
        float4 lightDir = normalize(light_position_cameraspace - in.vertexPosCam);
        half distanceFromLight = distance(light_position_cameraspace , in.vertexPosCam);
        
        
        float4 normal = normalize(in.normal);
        float4 eyeVec = normalize(in.eyeVec);
        float n_dot_l = saturate(dot(normal,lightDir));
        half4 diffuse = half4(half3(n_dot_l),1.0);
        
        float4 reflectValue = -lightDir + 2.0f * n_dot_l * normal;
        float e_dot_r = saturate(dot(eyeVec,reflectValue));
        specular = half4(in.reflection * pow(e_dot_r,maxSpecular));
        
        float e_dot_l = dot(lightDir,eyeVec);
        if(e_dot_l < -0.8)
            specular = half4(0.0);
        colorOfLight += half4(half3(lightColor[0]),1.0) * (1.0 - saturate(distanceFromLight/lightFadeDistance[0])) * diffuse;
        }
    //-------------
    
    half4 finalColor = half4(diffuse_color + specular) * colorOfLight;
    finalColor = finalColor + (half4(0.0,0.0,0.0,0.0) - finalColor) * (shadowValue);
    return half4(half3(finalColor.xyz) , in.transparency);
}

fragment half4 Common_Fragment_L2(ColorInOut in [[stage_in]],texture2d<half>  tex2D [[texture(SHADER_COMMON_texture1)]],
                                  depth2d<float> shadow_texture [[texture(SHADER_COMMON_texture2)]],
                                  constant packed_float3* lightPos [[ buffer(SHADER_COMMON_lightPos) ]],
                                  constant packed_float3* lightColor [[ buffer(SHADER_COMMON_lightColor) ]],
                                  constant float* lightFadeDistance[[ buffer(SHADER_COMMON_lightFadeDistance)]],
                                  constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]])
{
    
    // Shadow Calculation----------
    float shadowBias = 0.005,shadowValue = 0.0,maxSpecular = 30.0;
    if(in.shadowDarkness > 0.0){
        constexpr sampler linear_sampler(min_filter::linear, mag_filter::linear);
        float depth = shadow_texture.sample(linear_sampler,in.texture2UV);
        if((depth + shadowBias) < in.vertexDepth)
            shadowValue = in.shadowDarkness;
    }
    //------------------
    
    half4 diffuse_color = half4(in.perVertexColor);
    
    if(isVertexColored == 0.0) {
        constexpr sampler quad_sampler(address::repeat,filter::linear);
        diffuse_color =  tex2D.sample(quad_sampler,in.uv);
    }
    
    
    // Lighting Calculation----------
    
    
    half4 specular = half4(0.0), colorOfLight = half4(1.0);
    
    if(in.isLighting != 0.0){
        colorOfLight = half4(0.0);
        
        for(int i = 0 ; i < 2; i++) {
            float4 light_position_cameraspace = float4(float3(lightPos[i]),1.0);
            float4 lightDir = normalize(light_position_cameraspace - in.vertexPosCam);
            half distanceFromLight = distance(light_position_cameraspace , in.vertexPosCam);
            
            
            float4 normal = normalize(in.normal);
            float4 eyeVec = normalize(in.eyeVec);
            float n_dot_l = saturate(dot(normal,lightDir));
            half4 diffuse = half4(half3(n_dot_l),1.0);
            
            float4 reflectValue = -lightDir + 2.0f * n_dot_l * normal;
            float e_dot_r = saturate(dot(eyeVec,reflectValue));
            specular = half4(in.reflection * pow(e_dot_r,maxSpecular));
            
            float e_dot_l = dot(lightDir,eyeVec);
            if(e_dot_l < -0.8)
                specular = half4(0.0);
            colorOfLight += half4(half3(lightColor[i]),1.0) * (1.0 - saturate(distanceFromLight/lightFadeDistance[i])) * diffuse;
            if(i == 0)
                colorOfLight = colorOfLight + (half4(0.0,0.0,0.0,0.0) - colorOfLight) * (shadowValue);
        }
    }
    //-------------
    
    half4 finalColor = half4(diffuse_color + specular) * colorOfLight;
//    finalColor = finalColor + (half4(0.0,0.0,0.0,0.0) - finalColor) * (shadowValue);
    return half4(half3(finalColor.xyz) , in.transparency);
}

fragment half4 Common_Fragment_L3(ColorInOut in [[stage_in]],texture2d<half>  tex2D [[texture(SHADER_COMMON_texture1)]],
                                  depth2d<float> shadow_texture [[texture(SHADER_COMMON_texture2)]],
                                  constant packed_float3* lightPos [[ buffer(SHADER_COMMON_lightPos) ]],
                                  constant packed_float3* lightColor [[ buffer(SHADER_COMMON_lightColor) ]],
                                  constant float* lightFadeDistance[[ buffer(SHADER_COMMON_lightFadeDistance)]],
                                  constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]])
{
    
    // Shadow Calculation----------
    float shadowBias = 0.005,shadowValue = 0.0,maxSpecular = 30.0;
    if(in.shadowDarkness > 0.0){
        constexpr sampler linear_sampler(min_filter::linear, mag_filter::linear);
        float depth = shadow_texture.sample(linear_sampler,in.texture2UV);
        if((depth + shadowBias) < in.vertexDepth)
            shadowValue = in.shadowDarkness;
    }
    //------------------
    
    half4 diffuse_color = half4(in.perVertexColor);
    
    if(isVertexColored == 0.0) {
        constexpr sampler quad_sampler(address::repeat,filter::linear);
        diffuse_color =  tex2D.sample(quad_sampler,in.uv);
    }
    
    
    // Lighting Calculation----------
    
    
    half4 specular = half4(0.0), colorOfLight = half4(1.0);
    
    if(in.isLighting != 0.0){
        colorOfLight = half4(0.0);
        
        for(int i = 0 ; i < 3; i++) {
            float4 light_position_cameraspace = float4(float3(lightPos[i]),1.0);
            float4 lightDir = normalize(light_position_cameraspace - in.vertexPosCam);
            half distanceFromLight = distance(light_position_cameraspace , in.vertexPosCam);
            
            
            float4 normal = normalize(in.normal);
            float4 eyeVec = normalize(in.eyeVec);
            float n_dot_l = saturate(dot(normal,lightDir));
            half4 diffuse = half4(half3(n_dot_l),1.0);
            
            float4 reflectValue = -lightDir + 2.0f * n_dot_l * normal;
            float e_dot_r = saturate(dot(eyeVec,reflectValue));
            specular = half4(in.reflection * pow(e_dot_r,maxSpecular));
            
            float e_dot_l = dot(lightDir,eyeVec);
            if(e_dot_l < -0.8)
                specular = half4(0.0);
            colorOfLight += half4(half3(lightColor[i]),1.0) * (1.0 - saturate(distanceFromLight/lightFadeDistance[i])) * diffuse;
            if(i == 0)
                colorOfLight = colorOfLight + (half4(0.0,0.0,0.0,0.0) - colorOfLight) * (shadowValue);
        }
    }
    //-------------
    
    half4 finalColor = half4(diffuse_color + specular) * colorOfLight;
//    finalColor = finalColor + (half4(0.0,0.0,0.0,0.0) - finalColor) * (shadowValue);
    return half4(half3(finalColor.xyz) , in.transparency);
}

fragment half4 Common_Fragment_L4(ColorInOut in [[stage_in]],texture2d<half>  tex2D [[texture(SHADER_COMMON_texture1)]],
                                  depth2d<float> shadow_texture [[texture(SHADER_COMMON_texture2)]],
                                  constant packed_float3* lightPos [[ buffer(SHADER_COMMON_lightPos) ]],
                                  constant packed_float3* lightColor [[ buffer(SHADER_COMMON_lightColor) ]],
                                  constant float* lightFadeDistance[[ buffer(SHADER_COMMON_lightFadeDistance)]],
                                  constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]])
{
    
    // Shadow Calculation----------
    float shadowBias = 0.005,shadowValue = 0.0,maxSpecular = 30.0;
    if(in.shadowDarkness > 0.0){
        constexpr sampler linear_sampler(min_filter::linear, mag_filter::linear);
        float depth = shadow_texture.sample(linear_sampler,in.texture2UV);
        if((depth + shadowBias) < in.vertexDepth)
            shadowValue = in.shadowDarkness;
    }
    //------------------
    
    half4 diffuse_color = half4(in.perVertexColor);
    
    if(isVertexColored == 0.0) {
        constexpr sampler quad_sampler(address::repeat,filter::linear);
        diffuse_color =  tex2D.sample(quad_sampler,in.uv);
    }
    
    
    // Lighting Calculation----------
    
    
    half4 specular = half4(0.0), colorOfLight = half4(1.0);
    
    if(in.isLighting != 0.0){
        colorOfLight = half4(0.0);
        
        for(int i = 0 ; i < 4; i++) {
            float4 light_position_cameraspace = float4(float3(lightPos[i]),1.0);
            float4 lightDir = normalize(light_position_cameraspace - in.vertexPosCam);
            half distanceFromLight = distance(light_position_cameraspace , in.vertexPosCam);
            
            
            float4 normal = normalize(in.normal);
            float4 eyeVec = normalize(in.eyeVec);
            float n_dot_l = saturate(dot(normal,lightDir));
            half4 diffuse = half4(half3(n_dot_l),1.0);
            
            float4 reflectValue = -lightDir + 2.0f * n_dot_l * normal;
            float e_dot_r = saturate(dot(eyeVec,reflectValue));
            specular = half4(in.reflection * pow(e_dot_r,maxSpecular));
            
            float e_dot_l = dot(lightDir,eyeVec);
            if(e_dot_l < -0.8)
                specular = half4(0.0);
            colorOfLight += half4(half3(lightColor[i]),1.0) * (1.0 - saturate(distanceFromLight/lightFadeDistance[i])) * diffuse;
            if(i == 0)
                colorOfLight = colorOfLight + (half4(0.0,0.0,0.0,0.0) - colorOfLight) * (shadowValue);
        }
    }
    //-------------
    
    half4 finalColor = half4(diffuse_color + specular) * colorOfLight;
//    finalColor = finalColor + (half4(0.0,0.0,0.0,0.0) - finalColor) * (shadowValue);
    return half4(half3(finalColor.xyz) , in.transparency);
}

fragment half4 Common_Fragment_L5(ColorInOut in [[stage_in]],texture2d<half>  tex2D [[texture(SHADER_COMMON_texture1)]],
                                  depth2d<float> shadow_texture [[texture(SHADER_COMMON_texture2)]],
                                  constant packed_float3* lightPos [[ buffer(SHADER_COMMON_lightPos) ]],
                                  constant packed_float3* lightColor [[ buffer(SHADER_COMMON_lightColor) ]],
                                  constant float* lightFadeDistance[[ buffer(SHADER_COMMON_lightFadeDistance)]],
                                  constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]])
{
    
    // Shadow Calculation----------
    float shadowBias = 0.005,shadowValue = 0.0,maxSpecular = 30.0;
    if(in.shadowDarkness > 0.0){
        constexpr sampler linear_sampler(min_filter::linear, mag_filter::linear);
        float depth = shadow_texture.sample(linear_sampler,in.texture2UV);
        if((depth + shadowBias) < in.vertexDepth)
            shadowValue = in.shadowDarkness;
    }
    //------------------
    
    half4 diffuse_color = half4(in.perVertexColor);
    
    if(isVertexColored == 0.0) {
        constexpr sampler quad_sampler(address::repeat,filter::linear);
        diffuse_color =  tex2D.sample(quad_sampler,in.uv);
    }
    
    
    // Lighting Calculation----------
    
    
    half4 specular = half4(0.0), colorOfLight = half4(1.0);
    
    if(in.isLighting != 0.0){
        colorOfLight = half4(0.0);
        
        for(int i = 0 ; i < 5; i++) {
            float4 light_position_cameraspace = float4(float3(lightPos[i]),1.0);
            float4 lightDir = normalize(light_position_cameraspace - in.vertexPosCam);
            half distanceFromLight = distance(light_position_cameraspace , in.vertexPosCam);
            
            
            float4 normal = normalize(in.normal);
            float4 eyeVec = normalize(in.eyeVec);
            float n_dot_l = saturate(dot(normal,lightDir));
            half4 diffuse = half4(half3(n_dot_l),1.0);
            
            float4 reflectValue = -lightDir + 2.0f * n_dot_l * normal;
            float e_dot_r = saturate(dot(eyeVec,reflectValue));
            specular = half4(in.reflection * pow(e_dot_r,maxSpecular));
            
            float e_dot_l = dot(lightDir,eyeVec);
            if(e_dot_l < -0.8)
                specular = half4(0.0);
            colorOfLight += half4(half3(lightColor[i]),1.0) * (1.0 - saturate(distanceFromLight/lightFadeDistance[i])) * diffuse;
            if(i == 0)
                colorOfLight = colorOfLight + (half4(0.0,0.0,0.0,0.0) - colorOfLight) * (shadowValue);
        }
    }
    //-------------
    
    half4 finalColor = half4(diffuse_color + specular) * colorOfLight;
//    finalColor = finalColor + (half4(0.0,0.0,0.0,0.0) - finalColor) * (shadowValue);
    return half4(half3(finalColor.xyz) , in.transparency);
}


#define SHADER_TOON_SKIN_mvp 1
#define SHADER_TOON_SKIN_transparency 2
#define SHADER_TOON_SKIN_world 3
#define SHADER_TOON_SKIN_isLighting 4
#define SHADER_TOON_SKIN_refraction 5
#define SHADER_TOON_SKIN_reflection 6
#define SHADER_TOON_SKIN_shadowDarkness 7
#define SHADER_TOON_SKIN_lightPos 8
#define SHADER_TOON_SKIN_eyePos 9
#define SHADER_TOON_SKIN_lightColor 10
#define SHADER_TOON_SKIN_lightViewProjMatrix 11
#define SHADER_TOON_SKIN_jointData 12
#define SHADER_TOON_SKIN_texture1 0
#define SHADER_TOON_SKIN_texture2 1

#define SHADER_TOON_mvp 1
#define SHADER_TOON_transparency 2
#define SHADER_TOON_world 3
#define SHADER_TOON_isLighting 4
#define SHADER_TOON_refraction 5
#define SHADER_TOON_reflection 6
#define SHADER_TOON_shadowDarkness 7
#define SHADER_TOON_lightPos 8
#define SHADER_TOON_eyePos 9
#define SHADER_TOON_lightColor 10
#define SHADER_TOON_lightViewProjMatrix 11
#define SHADER_TOON_texture1 0
#define SHADER_TOON_texture2 1

fragment half4 Common_Toon_Fragment(ColorInOut in [[stage_in]],texture2d<half>  tex2D [[texture(SHADER_TOON_SKIN_texture1)]],
                                    depth2d<float> shadow_texture [[texture(SHADER_TOON_SKIN_texture2)]],
                                    constant packed_float3* lightPos [[ buffer(SHADER_COMMON_lightPos) ]],
                                    constant packed_float3* lightColor [[ buffer(SHADER_COMMON_lightColor) ]],
                                    constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]])
{
    // Shadow Calculation----------
    float shadowBias = 0.005,shadowValue = 0.0,maxSpecular = 30.0;
    if(in.shadowDarkness > 0.0){
        constexpr sampler linear_sampler(min_filter::linear, mag_filter::linear);
        float depth = shadow_texture.sample(linear_sampler,in.texture2UV);
        if((depth + shadowBias) < in.vertexDepth)
            shadowValue = in.shadowDarkness;
    }
    //------------------
    
    
    // Lighting Calculation----------
    half4 diffuse_color = half4(in.perVertexColor);
    
    if(isVertexColored == 0.0) {
        constexpr sampler quad_sampler(address::repeat,filter::linear);
        diffuse_color =  tex2D.sample(quad_sampler,in.uv);
    }

    half4 specular;
    half4 finalColor;
    if(in.isLighting != 0.0){
        
        float4 light_position_cameraspace = float4(float3(lightPos[0]),1.0);
        float4 lightDir = normalize(light_position_cameraspace - in.vertexPosCam);
        float distanceFromLight = distance(light_position_cameraspace , in.vertexPosCam);

        float4 normal = normalize(in.normal);
        float4 eyeVec = normalize(in.eyeVec);
        
        float n_dot_l = saturate(dot(normal,lightDir));
        float4 diffuse = float4(float3(n_dot_l),1.0);
        diffuse_color = half4(diffuse) * half4(diffuse_color);
        
        float4 reflectValue = -lightDir + 2.0f * n_dot_l * normal;
        float e_dot_r =  saturate(dot(eyeVec,reflectValue));
        specular = half4(in.reflection * pow(e_dot_r,maxSpecular));
        float e_dot_l = dot(lightDir,eyeVec);
        if(e_dot_l < -0.8)
            specular = half4(0.0);
        
        //Toon Calculation----------
        half4 toonColor = half4(diffuse_color + specular);
        if(n_dot_l > 0.95)
            toonColor = half4(1.0,1.0,1.0,1.0) * toonColor;
        else if(n_dot_l > 0.6)
            toonColor = half4(0.8,0.8,0.8,1.0) * toonColor;
        else if(n_dot_l > 0.2)
            toonColor = half4(0.6,0.6,0.6,1.0) * toonColor;
        else
            toonColor = half4(0.4,0.4,0.4,1.0) * toonColor;
        //----------------
        finalColor = toonColor * half4(half3(lightColor[0]),1.0);
    }else{
        specular = half4(0.0);
        finalColor = half4(diffuse_color);
    }
    //-------------
    finalColor = finalColor + (half4(0.0,0.0,0.0,0.0) - finalColor) * (shadowValue);
    return half4(half3(finalColor.xyz) , in.transparency);
}

#define SHADER_COLOR_mvp 1
#define SHADER_COLOR_vertexColor 2
#define SHADER_COLOR_transparency 3
// Color_Vertex
vertex ColorInOut Color_Vertex(device vertex_t* vertex_array [[ buffer(0) ]],
                               constant matrix_float4x4& mvp [[buffer(SHADER_COLOR_mvp)]],
                               constant float3Struct *vertColor [[buffer(SHADER_COLOR_vertexColor)]],
                               constant float& transparency [[ buffer(SHADER_COLOR_transparency) ]],
                               unsigned int vid [[ vertex_id ]]
                               )
{
    ColorInOut out;
    out.position = (mvp) * float4(float3(vertex_array[vid].position), 1.0);
    out.perVertexColor = float4(float3(vertColor[0].data),transparency);
    return out;
}
// Fragment shader function
fragment half4 Color_Fragment(ColorInOut in [[stage_in]])
{
    half4 color = half4(in.perVertexColor);
    return color;
}


#define SHADER_COLOR_SKIN_mvp 1
#define SHADER_COLOR_SKIN_vertexColor 2
#define SHADER_COLOR_SKIN_jointData 3
#define SHADER_COLOR_SKIN_transparency 4
// Color_Skin_Vertex
vertex ColorInOut Color_Skin_Vertex(device vertex_heavy_t* vertex_array [[ buffer(0) ]],
                                    constant matrix_float4x4& mvp [[ buffer(SHADER_COLOR_SKIN_mvp) ]],
                                    constant float3Struct *vertColor [[buffer(SHADER_COLOR_SKIN_vertexColor)]],
                                    constant JointData* Joint_Data [[ buffer(SHADER_COLOR_SKIN_jointData) ]],
                                    constant float& transparency [[ buffer(SHADER_COLOR_SKIN_transparency) ]],
                                    unsigned int vid [[ vertex_id ]]
                                    )
{
    ColorInOut out;
    float4 in_position = float4(float3(vertex_array[vid].position), 1.0);
    float4 optionalData1 = vertex_array[vid].optionalData1;
    float4 optionalData2 = vertex_array[vid].optionalData2;
    float4 optionalData3 = vertex_array[vid].optionalData3;
    float4 optionalData4 = vertex_array[vid].optionalData4;
    float4 pos = float4(0.0);
    
    int jointId = int(optionalData1.x);
    float strength = optionalData2.x ;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    else
        pos = in_position;
    
    jointId = int(optionalData1.y);
    strength = optionalData2.y ;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData1.z);
    strength = optionalData2.z ;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData1.w);
    strength = optionalData2.w;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData3.x);
    strength = optionalData4.x;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData3.y);
    strength = optionalData4.y;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData3.z);
    strength = optionalData4.z;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData3.w);
    strength = optionalData4.w;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    out.position = mvp * pos;
    out.perVertexColor = float4(float3(vertColor[0].data),transparency);
    return out;
}


#define SHADER_PERVERTEXCOLOR_mvp 1
#define SHADER_PERVERTEXCOLOR_transparency 2
#define SHADER_PERVERTEXCOLOR_isLighting 3
#define SHADER_PERVERTEXCOLOR_refraction 4
#define SHADER_PERVERTEXCOLOR_reflection 5
#define SHADER_PERVERTEXCOLOR_shadowDarkness 6
#define SHADER_PERVERTEXCOLOR_lightPos 7
#define SHADER_PERVERTEXCOLOR_eyePos 8
#define SHADER_PERVERTEXCOLOR_world 9
#define SHADER_PERVERTEXCOLOR_lightViewProjMatrix 10
#define SHADER_PERVERTEXCOLOR_lightColor 11
#define SHADER_PERVERTEXCOLOR_viewMatrix 12
#define SHADER_PERVERTEXCOLOR_texture1 1
#define SHADER_PERVERTEXCOLOR_jointData 13
// Color_Vertex
vertex ColorInOut Per_Vertex_Color(device vertex_t* vertex_array [[ buffer(0) ]],
                                   constant matrix_float4x4& mvp [[buffer(SHADER_COLOR_mvp)]],
                                   constant float& transparency [[ buffer(SHADER_PERVERTEXCOLOR_transparency) ]],
                                   constant matrix_float4x4& world [[ buffer(SHADER_PERVERTEXCOLOR_world) ]],
                                   constant int& isLighting [[ buffer(SHADER_PERVERTEXCOLOR_isLighting) ]],
                                   constant float& reflection [[ buffer(SHADER_PERVERTEXCOLOR_reflection) ]],
                                   constant packed_float3& eyePos [[ buffer(SHADER_PERVERTEXCOLOR_eyePos) ]],
                                   constant matrix_float4x4& lightViewProjMatrix [[ buffer(SHADER_PERVERTEXCOLOR_lightViewProjMatrix) ]],
                                   constant float& shadowDarkness [[ buffer(SHADER_PERVERTEXCOLOR_shadowDarkness) ]],
                                   unsigned int vid [[ vertex_id ]]
                                   )
{
    float4 vertex_position_objectspace = float4(float3(vertex_array[vid].position), 1.0);
    float4 vertex_position_cameraspace = world * float4(float3(vertex_array[vid].position), 1.0);
    
    ColorInOut out;
    out.vertexPosCam = vertex_position_cameraspace;
    out.transparency = transparency;
    out.position = mvp * vertex_position_objectspace;
    out.perVertexColor = vertex_array[vid].optionalData1;
    
    out.texture2UV = float2(0.0);
    out.vertexDepth = 0.0;
    
    //Shadow Coords Calculation -----------
    float4 vertexLightCoord = (lightViewProjMatrix * world) * vertex_position_objectspace;
    float4 texCoords = vertexLightCoord/vertexLightCoord.w;
    out.texture2UV = float4((texCoords / 2.0) + 0.5).xy;
    out.texture2UV.y = (1.0 - out.texture2UV.y); // need to flip metal texture vertically
    out.vertexDepth = texCoords.z;
    //----------
    
    // Lighting Calculation-----------
    if(isLighting == 1){
        out.isLighting = 1.0;
        float4 eye_position_cameraspace = float4(float3(eyePos),1.0);
        out.normal = normalize(world * float4(float3(vertex_array[vid].normal),0.0));
        out.eyeVec = normalize(eye_position_cameraspace - vertex_position_cameraspace);
        out.reflection = reflection;
        out.shadowDarkness = shadowDarkness;
    }else{
        out.isLighting = 0.0;
        out.shadowDarkness = 0.0;
    }
    //--------------
    return out;
}

vertex ColorInOut Per_Vertex_Color_Skin(device vertex_heavy_t* vertex_array [[ buffer(0) ]],
                                   constant matrix_float4x4& mvp [[buffer(SHADER_COLOR_mvp)]],
                                   constant float& transparency [[ buffer(SHADER_PERVERTEXCOLOR_transparency) ]],
                                   constant matrix_float4x4& world [[ buffer(SHADER_PERVERTEXCOLOR_world) ]],
                                   constant int& isLighting [[ buffer(SHADER_PERVERTEXCOLOR_isLighting) ]],
                                   constant float& reflection [[ buffer(SHADER_PERVERTEXCOLOR_reflection) ]],
                                   constant packed_float3& eyePos [[ buffer(SHADER_PERVERTEXCOLOR_eyePos) ]],
                                   constant matrix_float4x4& lightViewProjMatrix [[ buffer(SHADER_PERVERTEXCOLOR_lightViewProjMatrix) ]],
                                   constant float& shadowDarkness [[ buffer(SHADER_PERVERTEXCOLOR_shadowDarkness) ]],
                                   unsigned int vid [[ vertex_id ]],
                                   constant JointData* Joint_Data [[ buffer(SHADER_PERVERTEXCOLOR_jointData) ]],
                                   constant float& isVertexColored[[ buffer(SHADER_COMMON_isVertexColored)]],
                                   constant float3Struct *vertColor [[buffer(SHADER_COMMON_SKIN_VertexColor)]]
                                   )
{
    ColorInOut out;
    
    float4 in_position = float4(float3(vertex_array[vid].position), 1.0);
    float4 in_normal = float4(float3(vertex_array[vid].normal), 0.0);
    float4 optionalData1 = vertex_array[vid].optionalData1;
    float4 optionalData2 = vertex_array[vid].optionalData2;
    out.transparency = transparency;
    //out.perVertexColor = vertex_array[vid].optionalData4;
    
    
    out.perVertexColor = (int(isVertexColored) == 0) ? float4(1.0) : float4(float3(vertColor[0].data),1.0);
    float2 uv = (int(isVertexColored) == 0) ? vertex_array[vid].texCoord1 : float2(0.0,0.0);
    out.uv.x = uv.x;
    out.uv.y = uv.y;

    out.texture2UV = float2(0.0);
    out.vertexDepth = 0.0;
    
    
    float4 pos = float4(0.0);
    float4 nor = float4(0.0);
    
    int jointId = int(optionalData1.x);
    float strength = optionalData2.x ;
    if(jointId > 0){
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
        nor = nor + (Joint_Data[jointId - 1].JointTransform * in_normal) * strength;
    }else{
        pos = in_position;
        nor = in_normal;
    }
    
    float4 vertex_position_objectspace = pos;
    float4 vertex_position_cameraspace = world * pos;
    out.vertexPosCam = vertex_position_cameraspace;
    out.transparency = transparency;
    out.position = mvp * vertex_position_objectspace;

    //Shadow Coords Calculation -----------
    float4 vertexLightCoord = (lightViewProjMatrix * world) * vertex_position_objectspace;
    float4 texCoords = vertexLightCoord/vertexLightCoord.w;
    out.texture2UV = float4((texCoords / 2.0) + 0.5).xy;
    out.texture2UV.y = (1.0 - out.texture2UV.y); // need to flip metal texture vertically
    out.vertexDepth = texCoords.z;
    //----------
    
    // Lighting Calculation-----------
    if(isLighting == 1){
        out.isLighting = 1.0;
        float4 eye_position_cameraspace = float4(float3(eyePos),1.0);
        
        out.normal = normalize(world * nor);
        out.eyeVec = normalize(eye_position_cameraspace - vertex_position_cameraspace);
        out.reflection = reflection;
        out.shadowDarkness = shadowDarkness;
    }else{
        out.isLighting = 0.0;
        out.shadowDarkness = 0.0;
    }

    
    return out;
}

fragment half4 Per_Vertex_Color_Shadow_Fragment(ColorInOut in [[stage_in]],depth2d<float> shadow_texture [[texture(SHADER_PERVERTEXCOLOR_texture1)]],
                                                constant packed_float3* lightPos [[ buffer(SHADER_PERVERTEXCOLOR_lightPos) ]],
                                                constant packed_float3* lightColor [[ buffer(SHADER_PERVERTEXCOLOR_lightColor) ]],
                                                constant float* lightFadeDistance[[ buffer(SHADER_COMMON_lightFadeDistance)]],
                                                constant float& numberOfLights[[ buffer(SHADER_COMMON_isVertexColored)]])
{
    // Shadow Calculation----------
    float shadowBias = 0.005,shadowValue = 0.0,maxSpecular = 30.0;
    if(in.shadowDarkness > 0.0){
        constexpr sampler linear_sampler(min_filter::linear, mag_filter::linear);
        float depth = shadow_texture.sample(linear_sampler,in.texture2UV);
        if((depth + shadowBias) < in.vertexDepth)
            shadowValue = in.shadowDarkness;
    }
    //------------------

    
    // Lighting Calculation----------
    float4 diffuse_color = in.perVertexColor,specular,colorOfLight = float4(1.0);
    if(in.isLighting != 0.0){
        colorOfLight = float4(0.0);
        
        int lightsCount = int(numberOfLights);
        for(int i = 0; i < lightsCount; i++) {

        float4 light_position_cameraspace = float4(float3(lightPos[i]),1.0);
        float4 lightDir = normalize(light_position_cameraspace - in.vertexPosCam);
        float distanceFromLight = distance(light_position_cameraspace , in.vertexPosCam);
        
        float4 normal = normalize(in.normal);
        float4 eyeVec = normalize(in.eyeVec);
        float n_dot_l = saturate(dot(normal,lightDir));
        float4 diffuse = float4(float3(n_dot_l),1.0);
        
        float4 reflectValue = -lightDir + 2.0f * n_dot_l * normal;
        float e_dot_r =  saturate(dot(eyeVec,reflectValue));
        specular = float4(in.reflection * pow(e_dot_r,maxSpecular));
        
        float e_dot_l = dot(lightDir,eyeVec);
        if(e_dot_l < -0.8)
            specular = float4(0.0);
        colorOfLight += float4(float3(lightColor[i]),1.0) * (1.0 - saturate(distanceFromLight/lightFadeDistance[i])) * diffuse;
        }
        
    }else{
        diffuse_color = in.perVertexColor;
        specular = float4(0.0);
    }
    //-------------
    
    half4 finalColor = half4(diffuse_color + specular) * half4(colorOfLight);
    finalColor = finalColor + (half4(0.0,0.0,0.0,0.0) - finalColor) * (shadowValue);
    return half4(half3(finalColor.xyz) , in.transparency);
}
fragment half4 Per_Vertex_Color_Toon_Fragment(ColorInOut in [[stage_in]],depth2d<float> shadow_texture [[texture(SHADER_PERVERTEXCOLOR_texture1)]],
                                              constant packed_float3* lightPos [[ buffer(SHADER_PERVERTEXCOLOR_lightPos) ]],
                                              constant packed_float3* lightColor [[ buffer(SHADER_PERVERTEXCOLOR_lightColor) ]])
{
    // Shadow Calculation----------
    float shadowBias = 0.005,shadowValue = 0.0,maxSpecular = 30.0;
    if(in.shadowDarkness > 0.0){
        constexpr sampler linear_sampler(min_filter::linear, mag_filter::linear);
        float depth = shadow_texture.sample(linear_sampler,in.texture2UV);
        if((depth + shadowBias) < in.vertexDepth)
            shadowValue = in.shadowDarkness;
    }
    //------------------
    
    // Lighting Calculation----------
    float4 diffuse_color,specular;
    half4 finalColor;
    if(in.isLighting != 0.0){
        
        float4 light_position_cameraspace = float4(float3(lightPos[0]),1.0);
        float4 lightDir = normalize(light_position_cameraspace - in.vertexPosCam);
        float distanceFromLight = distance(light_position_cameraspace , in.vertexPosCam);

        float4 normal = normalize(in.normal);
        float4 eyeVec = normalize(in.eyeVec);
        
        float n_dot_l = saturate(dot(normal,lightDir));
        float4 diffuse = float4(float3(n_dot_l),1.0);
        diffuse_color = diffuse * in.perVertexColor;
        
        float4 reflectValue = -lightDir + 2.0f * n_dot_l * normal;
        float e_dot_r =  saturate(dot(eyeVec,reflectValue));
        specular = float4(in.reflection * pow(e_dot_r,maxSpecular));
        float e_dot_l = dot(lightDir,eyeVec);
        if(e_dot_l < -0.8)
            specular = float4(0.0);
        
        //Toon Calculation----------
        half4 toonColor = half4(diffuse_color + specular);
        if(n_dot_l > 0.95)
            toonColor = half4(1.0,1.0,1.0,1.0) * toonColor;
        else if(n_dot_l > 0.6)
            toonColor = half4(0.8,0.8,0.8,1.0) * toonColor;
        else if(n_dot_l > 0.2)
            toonColor = half4(0.6,0.6,0.6,1.0) * toonColor;
        else
            toonColor = half4(0.4,0.4,0.4,1.0) * toonColor;
        //----------------
        finalColor = toonColor * half4(half3(lightColor[0]),1.0);
    }else{
        diffuse_color = in.perVertexColor;
        specular = float4(0.0);
        finalColor = half4(diffuse_color);
    }
    //-------------
    finalColor = finalColor + (half4(0.0,0.0,0.0,0.0) - finalColor) * (shadowValue);
    return half4(half3(finalColor.xyz) , in.transparency);
}
fragment half4 Per_Vertex_Color_Skin_Fragment(ColorInOut in [[stage_in]],
                                              constant packed_float3* lightPos [[ buffer(SHADER_PERVERTEXCOLOR_lightPos) ]],
                                              constant packed_float3* lightColor [[ buffer(SHADER_PERVERTEXCOLOR_lightColor) ]],
                                              constant float* lightFadeDistance[[ buffer(SHADER_COMMON_lightFadeDistance)]],
                                              constant float& numberOfLights[[ buffer(SHADER_COMMON_isVertexColored)]])
{
    //------------------
    float maxSpecular = 30.0;

    // Lighting Calculation----------
    float4 diffuse_color = in.perVertexColor,specular , colorOfLight = float4(1.0);
    
    if(in.isLighting != 0.0){
        colorOfLight = float4(0.0);
        
        int lightsCount = int(numberOfLights);
        for(int i = 0; i < lightsCount; i++) {

            float4 light_position_cameraspace = float4(float3(lightPos[i]),1.0);
            float4 lightDir = normalize(light_position_cameraspace - in.vertexPosCam);
            float distanceFromLight = distance(light_position_cameraspace , in.vertexPosCam);

            float4 normal = normalize(in.normal);
            float4 eyeVec = normalize(in.eyeVec);
        
            float n_dot_l = saturate(dot(normal,lightDir));
            float4 diffuse = float4(float3(n_dot_l),1.0);
            
            float4 reflectValue = -lightDir + 2.0f * n_dot_l * normal;
            float e_dot_r =  saturate(dot(eyeVec,reflectValue));
            specular = float4(in.reflection * pow(e_dot_r,maxSpecular));
            float e_dot_l = dot(lightDir,eyeVec);
            if(e_dot_l < -0.8)
                specular = float4(0.0);
            colorOfLight += float4(float3(lightColor[i]),1.0) * (1.0 - saturate(distanceFromLight/lightFadeDistance[i])) * diffuse;
        }
    }else{
        diffuse_color = in.perVertexColor;
        specular = float4(0.0);
    }
    //-------------
    
    half4 finalColor = half4(diffuse_color + specular) * half4(colorOfLight);
    finalColor = finalColor;
    return half4(half3(finalColor.xyz) , in.transparency);
}

fragment half4 Per_Vertex_Color_Fragment(ColorInOut in [[stage_in]],
                                         constant packed_float3* lightPos [[ buffer(SHADER_PERVERTEXCOLOR_lightPos) ]],
                                         constant packed_float3* lightColor [[ buffer(SHADER_PERVERTEXCOLOR_lightColor) ]])
{
    half4 finalColor = half4(in.perVertexColor);
    return half4(half3(finalColor.xyz) , in.transparency);
}

#define SHADER_DRAW_2D_IMAGE_texture1 0
// Vertex shader function
vertex ColorInOut Draw2DImage_Vertex(device vertex_t* vertex_array [[ buffer(0) ]],
                                     unsigned int vid [[ vertex_id ]]
                                     )
{
    float2 uv = vertex_array[vid].texCoord1;
    ColorInOut out;
    out.position = float4(float3(vertex_array[vid].position), 1.0);
    out.uv.x = uv.x;
    out.uv.y = uv.y;
    out.perVertexColor = float4(1.0);
    return out;
}
// Fragment shader function
fragment half4 Draw2DImage_Fragment(ColorInOut in [[stage_in]],texture2d<half>  tex2D [[texture(0)]])
{
    constexpr sampler quad_sampler(address::repeat,filter::linear);
    half4 texColor = tex2D.sample(quad_sampler,in.uv);
    return texColor;
}
// Fragment shader depth
fragment half4 Draw2DImage_Fragment_Depth(ColorInOut in [[stage_in]],depth2d<float> shadow_texture [[texture(0)]])
{
    constexpr sampler linear_sampler(min_filter::linear, mag_filter::linear);
    float d = shadow_texture.sample(linear_sampler,in.uv.xy);
    half4 texColor = half4(d,d,d,1.0);
    return texColor;
}

#define SHADER_DEPTH_PASS_mvp 1
vertex ColorInOut Depth_Pass_vert(device vertex_t* vertex_array [[ buffer(0) ]],
                                  constant matrix_float4x4& mvp [[buffer(SHADER_DEPTH_PASS_mvp)]],
                                  unsigned int vid [[ vertex_id ]]
                                  )
{
    ColorInOut out;
    out.position = (mvp) * float4(float3(vertex_array[vid].position), 1.0);
    return out;
}
#define SHADER_DEPTH_PASS_SKIN_mvp 1
#define SHADER_DEPTH_PASS_SKIN_jointdata 2
vertex ColorInOut Depth_Pass_Skin_vert(device vertex_heavy_t* vertex_array [[ buffer(0) ]],
                                       constant matrix_float4x4& mvp [[buffer(SHADER_DEPTH_PASS_SKIN_mvp)]],
                                       constant JointData* Joint_Data [[ buffer(SHADER_DEPTH_PASS_SKIN_jointdata)]],
                                       unsigned int vid [[ vertex_id ]]
                                       )
{
    ColorInOut out;
    float4 in_position = float4(float3(vertex_array[vid].position), 1.0);
    float4 optionalData1 = vertex_array[vid].optionalData1;
    float4 optionalData2 = vertex_array[vid].optionalData2;
    float4 optionalData3 = vertex_array[vid].optionalData3;
    float4 optionalData4 = vertex_array[vid].optionalData4;
    float4 pos = float4(0.0);
    
    int jointId = int(optionalData1.x);
    float strength = optionalData2.x ;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    else
        pos = in_position;
    
    jointId = int(optionalData1.y);
    strength = optionalData2.y ;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData1.z);
    strength = optionalData2.z ;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData1.w);
    strength = optionalData2.w;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData3.x);
    strength = optionalData4.x;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData3.y);
    strength = optionalData4.y;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData3.z);
    strength = optionalData4.z;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    jointId = int(optionalData3.w);
    strength = optionalData4.w;
    if(jointId > 0)
        pos = pos + (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    
    out.position = mvp * pos;
    return out;
}

vertex ColorInOut Depth_Pass_Text_vert(device vertex_heavy_t* vertex_array [[ buffer(0) ]],
                                       constant matrix_float4x4& mvp [[buffer(SHADER_DEPTH_PASS_SKIN_mvp)]],
                                       constant JointData* Joint_Data [[ buffer(SHADER_DEPTH_PASS_SKIN_jointdata)]],
                                       unsigned int vid [[ vertex_id ]]
                                       )
{
    ColorInOut out;
    float4 in_position = float4(float3(vertex_array[vid].position), 1.0);
    float4 optionalData1 = vertex_array[vid].optionalData1;
    float4 optionalData2 = vertex_array[vid].optionalData2;
    float4 pos = float4(0.0);
    
    int jointId = int(optionalData1.x);
    float strength = optionalData2.x ;
    
    pos = (Joint_Data[jointId - 1].JointTransform * in_position) * strength;
    
    out.position = mvp * pos;
    return out;
}
